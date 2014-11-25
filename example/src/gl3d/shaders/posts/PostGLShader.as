package gl3d.shaders.posts 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	import gl3d.core.Camera3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.shaders.GLShader;
	import gl3d.shaders.PhongFragmentShader;
	import gl3d.shaders.PhongVertexShader;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PostGLShader extends GLShader
	{
		private var vshader:FlShader;
		private var fshader:FlShader;
		
		public function PostGLShader(vshader:FlShader=null,fshader:FlShader=null) 
		{
			this.fshader = fshader;
			this.vshader = vshader;
			
		}
		
		override public function getVertexShader(material:Material):FlShader {
			vshader=vshader||new PostVertexShader();
			return vshader;
		}
		
		override public function getFragmentShader(material:Material):FlShader {
			fshader=fshader||new PostFragmentShader();
			return fshader;
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			textureSets= material.textureSets;
			buffSets.length = 0;
			buffSets[0] = material.node.drawable.pos;
			buffSets[1] = material.node.drawable.uv;
		}
		
		override public function update(material:Material):void 
		{
			super.update(material);
			var context:Context3D = material.view.context;
			if (programSet) {
				var node:Node3D = material.node;
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([material.view.time,material.view.stage3dWidth,material.view.stage3dHeight,0]));
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vshader.constMemLen, Vector.<Number>(vshader.constPool));
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fshader.constMemLen, Vector.<Number>(fshader.constPool));
				//trace(fshader.constMemLen,fshader.constPool);
				context.drawTriangles(node.drawable.index.buff);
			}
		}
		
	}

}