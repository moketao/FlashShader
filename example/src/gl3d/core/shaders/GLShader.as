package gl3d.core.shaders 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import as3Shader.AGALByteCreator;
	import as3Shader.AS3Shader;
	import as3Shader.GLCodeCreator;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import gl3d.core.Camera3D;
	import gl3d.core.renders.GL;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.ProgramSet;
	import gl3d.core.TextureSet;
	import gl3d.util.Utils;
	import gl3d.core.VertexBufferSet;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLShader 
	{
		public var invalid:Boolean = true;
		public var vs:GLAS3Shader;
		public var fs:GLAS3Shader;
		public var programSet:ProgramSet;
		public var textureSets:Array=[];
		public var buffSets:Array;
		public var debug:Boolean = true;
		public static var PROGRAM_POOL:Object = { };
		public function GLShader() 
		{
			textureSets = [];
			buffSets = [];
		}
		
		public function getProgram(material:Material):ProgramSet {
			vs = getVertexShader(material);
			fs = getFragmentShader(material);
			
			if(vs&&fs){
				vs.creator = new AGALByteCreator(material.view.renderer.agalVersion);
				fs.creator = new AGALByteCreator(material.view.renderer.agalVersion);
				programSet = getProgramFromPool(vs.code as ByteArray, fs.code as ByteArray);
			}
			return programSet;
		}
		
		private function getProgramFromPool(vcode:ByteArray, fcode:ByteArray):ProgramSet {
			var classname:String = getQualifiedClassName(this);
			var ps:Vector.<ProgramSet> = PROGRAM_POOL[classname];
			if (ps) {
				for each(var p:ProgramSet in ps) {
					if (p.vcode.length!=vcode.length||p.fcode.length!=fcode.length) {
						continue;
					}
					var flag:Boolean = false;
					for (var i:int = p.vcode.length - 1; i >= 0;i-- ) {
						if (p.vcode[i] != vcode[i]) {
							flag = true;
							break;
						}
					}
					if (flag) {
						continue;
					}
					flag = false;
					for (i = p.fcode.length - 1; i >= 0;i-- ) {
						if (p.fcode[i] != fcode[i]) {
							flag = true;
							break;
						}
					}
					if (flag) {
						continue;
					}
					return p;
				}
			}else {
				ps=PROGRAM_POOL[classname]=new Vector.<ProgramSet>
			}
			ps.push(new ProgramSet(vcode, fcode));
			
			if (debug&&vs&&fs) {
				trace(this);
				//var code:String = vs.code as String;
				//trace("vcode "+vs+" numline",vs.lines.length);
				//trace(vs);
				vs.creator = new GLCodeCreator();
				trace(vs.code);
				//var code:String = fs.code as String;
				//trace("fcode "+fs+" numline",fs.lines.length);
				//trace(fs);
				fs.creator = new GLCodeCreator();
				trace(fs.code);
				trace();
			}
			return ps[ps.length-1];
		}
		
		public function getVertexShader(material:Material):GLAS3Shader {
			return null;
		}
		
		public function getFragmentShader(material:Material):GLAS3Shader {
			return null;
		}
		
		public function update(material:Material):void 
		{
			if (invalid) {
				programSet = getProgram(material);
				invalid = false;
			}
			if(programSet){
				vs.bind(this,material);
				fs.bind(this, material);
				
				material.view.renderer.gl3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				material.view.renderer.gl3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
			}
			if(textureSets)
			for (var i:int = 0; i < textureSets.length;i++ ) {
				var textureSet:TextureSet = textureSets[i];
				if (textureSet) {
					textureSet.update(material.view);
					textureSet.bind(material.view.renderer.gl3d, i);
				}
			}
			if(buffSets)
			for (i = 0; i < buffSets.length;i++ ) {
				var buffSet:VertexBufferSet = buffSets[i];
				if (buffSet) {
					buffSet.update(material.view.renderer.gl3d);
					buffSet.bind(material.view.renderer.gl3d, i);
				}
			}
			
			if (programSet) {
				programSet.update(material.view.renderer.gl3d);
				material.view.renderer.gl3d.setProgram(programSet.program);
				material.view.renderer.gl3d.setDepthTest(true, material.passCompareMode);
				material.view.renderer.gl3d.setBlendFactors(material.sourceFactor, material.destinationFactor);
				material.view.renderer.gl3d.setCulling(material.culling);
				material.view.renderer.gl3d.drawTriangles(material.node.drawable.index.buff);
			}
		}
	}

}