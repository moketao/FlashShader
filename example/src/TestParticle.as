package  
{
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.utils.getTimer;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	import gl3d.particle.Particle;
	import gl3d.shaders.particle.ParticleGLShader;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestParticle extends BaseExample
	{
		
		public function TestParticle() 
		{
			
		}
		
		override public function initNode():void 
		{
			//super.initNode();
			
			var particle:Particle = new Particle;
			particle.scaleX = particle.scaleY = particle.scaleZ =0.5;
			view.scene.addChild(particle);
		}
		
	}

}