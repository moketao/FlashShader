package gl3d 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	import gl3d.shaders.GLShader;
	import gl3d.shaders.PhongShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Material 
	{
		public var view:View3D;
		public var camera:Camera3D;
		public var node:Node3D;
		public var textureSets:Vector.<TextureSet>=new Vector.<TextureSet>;
		public var color:Vector.<Number> = Vector.<Number>([1, 1, 1, 1]);
		public var alpha:Number = 1;
		public var invalid:Boolean = true;
		public var shader:GLShader;
		
		
		public function Material() 
		{
			shader = new PhongShader(textureSets.length?textureSets[0]:null);
		}
		
		public function draw(node:Node3D,camera:Camera3D,view:View3D):void {
			this.view = view;
			this.camera = camera;
			this.node = node;
			if (node.drawable&&shader) {
				var context:Context3D = view.context;
				node.drawable.update(context);
				if (textureSets) {
					for each(var textureSet:TextureSet in textureSets) {
						textureSet.update(context);
					}
				}
				if (invalid) {
					shader.invalid = true;
					invalid = false;
				}
				shader.preUpdate(this);
				shader.update(this);
			}
		}
		
	}
}

