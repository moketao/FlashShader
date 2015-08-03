package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Material;
	import gl3d.core.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongVertexShader extends GLAS3Shader
	{
		private var material:Material;
		public var model:Var //= matrix();
		public var world2local:Var //= matrix();
		public var view:Var //= matrix();
		public var perspective:Var //= matrix();
		public var lightPos:Var //= uniform();
		public var joints:Var;
		
		
		public var pos:Var //= buff();
		public var norm:Var //= buff();
		public var uv:Var //= buff();
		public var tangent:Var //= buff();
		public var targetPosition:Var //= buff();
		public var weight:Var //= buff();
		public var joint:Var //= buff();
		public var weight2:Var //= buff();
		public var joint2:Var //= buff();
		
		public var eyeDirectionVarying:Var = varying();
		public var posLightVarying:Var = varying();
		public var normVarying:Var = varying();
		public var tangentVarying:Var = varying();
		public var uvVarying:Var = varying();
		public var targetPositionVarying:Var = varying();
		public var reflected:Var = varying();
		public function PhongVertexShader(material:Material) 
		{
			super(Context3DProgramType.VERTEX);
			this.material = material;
			
			pos = buffPos();
			norm = buffNorm();
			uv = buffUV();
			tangent = buffTangent();
			targetPosition = buffTargetPosition();
			weight = buffWeights();
			
			model = uniformModel();
			world2local = uniformWorld2Local();
			view = uniformView();
			perspective = uniformPerspective();
			lightPos = uniformLightPos(0);
		}
		
		override public function build():void {
			var norm:Var = this.norm;
			var pos:Var = this.pos;
			if (material.gpuSkin) {
				if (material.node.skin.useQuat) {
					joint = buffQuatJoints();
					joints = uniformJointsQuat(material.node.skin.joints.length);//= this.uniformAmbient//floatArray(material.node.skin.joints.length*2);
				}else {
					joint = buffJoints();
					joints = uniformJointsMatrix(material.node.skin.joints.length);//matrixArray(material.node.skin.joints.length);
				}
				var xyzw:String = "xyzw";
				for (var i:int = 0; i < material.node.skin.maxWeight; i++ ) {
					var c:String = xyzw.charAt(i % 4);
					if (material.node.skin.useQuat) {
						var joint:Var = i<4?this.joint.c(c):this.joint2.c(c);
						var value:Var = mul(i<4?weight.c(c):weight2.c(c), q44(pos, joints.c(joint),joints.c(joint,1)));
					}else {
						joint = i<4?this.joint.c(c):this.joint2.c(c);
						value = mul(i<4?weight.c(c):weight2.c(c), m44(pos, joints.c(joint)));
					}
					
					if (i==0) {
						var result:Var = value;
					}else {
						result = add(result, value);
					}
					if(material.lightAble){
						var valueNorm:Var = mul(weight.c(c), material.node.skin.useQuat?q33(norm,mov(joints.c(joint))):m33(norm, joints.c(joint)));
						if (i==0) {
							var resultNorm:Var = valueNorm;
						}else {
							resultNorm = add(resultNorm, valueNorm);
						}
					}
				}
				pos = result;
				if (material.lightAble) {
					norm = nrm(resultNorm);
				}
			}
			
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			m44(viewPos, perspective,op);
			
			if (material.lightAble||material.reflectTexture) {
				var worldNorm:Var = nrm(m33(norm, model));
				if(material.specularAble||material.reflectTexture){
					if (material.normalMapAble) {
						var eyeDirection:Var = nrm(m33(neg(viewPos),world2local));
					}else {
						eyeDirection = nrm(neg(viewPos));
					}
					mov(eyeDirection, eyeDirectionVarying);
				}
				if (material.normalMapAble) {
					var posLight:Var = nrm(m33(sub(m44(mov(lightPos),view), viewPos),world2local));
				}else {
					posLight = nrm(sub(m44(mov(lightPos),view), viewPos));
				}
				mov(posLight, posLightVarying);
				
				if (material.normalMapAble) {
					mov(nrm(m33(m33(worldNorm,view),world2local)),normVarying);
				}else {
					var viewNormal:Var = nrm(m33(worldNorm,view));
					mov(viewNormal, normVarying);
				}
				
				if (material.normalMapAble) {
					mov(tangent,tangentVarying)
				}
				if (material.reflectTexture) {
					var w2c:Var = nrm(sub(worldPos, uniformCameraPos()));
					//r=2n(n.l)-l
					mov(sub(w2c,mul2([2, worldNorm,dp3(worldNorm,w2c)])),reflected);
					
					//mov(norm, reflected);
				}
			}
			
			if (material.diffTexture) {
				mov(uv, uvVarying);
			}
			if (material.wireframeAble) {
				mov(targetPosition,targetPositionVarying);
			}
		}
		
		//http://molecularmusings.wordpress.com/2013/05/24/a-faster-quaternion-vector-multiplication/
		//t = 2 * cross(q.xyz, v)
		//v' = v + q.w * t + cross(q.xyz, t)
		public function q44(pos:Var, quas:Var, tran:Var):Var {
			var temp:Var = add(q33(pos, mov(quas)), tran);
			mov(1, temp.w);
			return temp.xyzw;
		}
		
		public function q33(pos:Var, quas:Var):Var {
			var t:Var = mul(2 , crs(quas, pos));
			return add2([pos , mul(quas.w , t) , crs(quas, t)]);
		}
	}

}