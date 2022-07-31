package;

import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.display.DisplayObject;
import openfl.text.TextField;
import openfl.text.TextFormat;


class Main extends Sprite {
	
	
	private static var PHYSICS_SCALE:Float = 1 / 30;
	private static var TIME_STEP:Float = 1 / 30;
	
	private var PhysicsDebug:Sprite;
	private var World:B2World;

	private var stageWidth:Int = Lib.current.stage.stageWidth;
	private var stageHeight:Int = Lib.current.stage.stageHeight;

	private static var WALL_WIDTH:Int = 20;

	private static var BOX_DENSITY:Float = 1;
	private static var BOX_FRICTION:Float = 0.2;

	private var placeholderBox:DisplayObject;

	private static var PLACEHOLDER_SPEED:Float = 8;
	private static var BOX_WIDTH_MIN:Int = 50;
	private static var BOX_WIDTH_MAX:Int = 200;

	private var movingLeft:Bool;
	private var movingRight:Bool;
	private var spawnBox:Bool;
	
	
	public function new () {
		
		super ();
		
		World = new B2World (new B2Vec2 (0, 10.0), true);
		
		PhysicsDebug = new Sprite ();
		addChild (PhysicsDebug);
		
		var debugDraw = new B2DebugDraw ();
		debugDraw.setSprite (PhysicsDebug);
		debugDraw.setDrawScale (1 / PHYSICS_SCALE);
		debugDraw.setFlags (B2DebugDraw.e_shapeBit);
		
		World.setDebugDraw (debugDraw);
		

		//Walls
		createBox (0, stageHeight / 2, WALL_WIDTH, stageHeight, false);
		createBox (stageWidth, stageHeight / 2, WALL_WIDTH, stageHeight, false);
		createBox (stageWidth / 2, stageHeight, stageWidth, WALL_WIDTH, false); // Floor
		
		// Player-controlled box
		placeholderBox = createPlaceholderBox(stageWidth / 2 - 100, 50, 200, 20);
		

		stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_onKeyUp);
		stage.addEventListener (Event.ENTER_FRAME, this_onEnterFrame);


		// Text
		var textFormat = new TextFormat("BroshK", 15, 0xD8D8D8);
		var textField = new TextField();

		textField.defaultTextFormat = textFormat;
		textField.embedFonts = true;
		textField.selectable = false;

		textField.x = 50;
		textField.y = 100;
		textField.width = 500;

		textField.text = "Use LEFT and RIGHT arrows to move block spawner \n
			Press SPACE BAR to spawn a block \n
			Try to stack blocks as high as you can \n";

		var nameFormat = new TextFormat("BroshK", 12, 0xB6B1B1);
		var name = new TextField();

		name.defaultTextFormat = nameFormat;
		name.embedFonts = true;
		name.selectable = false;

		name.x = 15;
		name.y = stageHeight - 30;
		name.width = 500;

		name.text = "nucron";

		addChild(textField);
		addChild(name);
		// END Text
	}
	
	
	private function createBox (x:Float, y:Float, width:Float, height:Float, dynamicBody:Bool):B2Body {
		
		var bodyDefinition = new B2BodyDef ();
		bodyDefinition.position.set (x * PHYSICS_SCALE, y * PHYSICS_SCALE);
		
		if (dynamicBody) {
			
			bodyDefinition.type = B2Body.b2_dynamicBody;
			
		}
		
		var polygon = new B2PolygonShape ();
		polygon.setAsBox ((width / 2) * PHYSICS_SCALE, (height / 2) * PHYSICS_SCALE);
		
		var fixtureDefinition = new B2FixtureDef ();
		fixtureDefinition.shape = polygon;
		fixtureDefinition.density = BOX_DENSITY;
		fixtureDefinition.friction = BOX_FRICTION;
		
		var body = World.createBody (bodyDefinition);
		body.createFixture (fixtureDefinition);

		return body;
	}

	private function createPlaceholderBox(x:Float, y:Float, width:Float, height:Float):DisplayObject {
		var boxShape = new Shape();
		boxShape.graphics.beginFill(0x251825);
		boxShape.graphics.drawRect(0, 0, width, height);
		boxShape.graphics.endFill();
		var box = new Sprite();
		box.addChild(boxShape);
		box.x = x;
		box.y = y;
		return addChild(box);
	}
	
	
	// Event Handlers
	
	private function this_onEnterFrame (event:Event):Void {
		
		World.step (TIME_STEP, 10, 10);
		World.clearForces ();
		World.drawDebugData ();
		
		if(movingLeft && placeholderBox.x > 0 + WALL_WIDTH)
		{
			placeholderBox.x -= PLACEHOLDER_SPEED;
		}
		if(movingRight && placeholderBox.x + placeholderBox.width < stageWidth - WALL_WIDTH)
		{
			placeholderBox.x += PLACEHOLDER_SPEED;
		}

		if(spawnBox) {
			spawnBox = false;
			var prevX = placeholderBox.x;
			var prevY = placeholderBox.y;
			createBox(placeholderBox.x + placeholderBox.width/2, placeholderBox.y + placeholderBox.height/2, 
				placeholderBox.width, placeholderBox.height, true);
			removeChild(placeholderBox);
			placeholderBox = createPlaceholderBox(prevX, prevY, BOX_WIDTH_MIN + Std.random(BOX_WIDTH_MAX - BOX_WIDTH_MIN), 20);
		}
	}

	private function stage_onKeyDown(event:KeyboardEvent):Void 
	{
		switch (event.keyCode)
		{
			case Keyboard.LEFT:
				movingLeft = true;
			case Keyboard.RIGHT:
				movingRight = true;
			case Keyboard.SPACE:
				spawnBox = true;
		}
	}
	
	private function stage_onKeyUp(event:KeyboardEvent):Void 
	{
		switch (event.keyCode)
		{
			case Keyboard.LEFT:
				movingLeft = false;
			case Keyboard.RIGHT:
				movingRight = false;
		}
	}
	
	
}