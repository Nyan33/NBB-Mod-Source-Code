package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['MENUPLAY', 'FREEPLAY', 'OPTIONS', 'CREDITS'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var nbb:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		WeekData.reloadWeekFiles(true);
		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('MENU/MENU-BG'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.scale.set(1.1,1.1);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		nbb = new FlxSprite();
		nbb.frames = Paths.getSparrowAtlas('MENU/MENU-NYN');
		nbb.antialiasing = ClientPrefs.globalAntialiasing;
		nbb.animation.addByPrefix('idle',"nyaan",24);	
		nbb.animation.play('idle');
		nbb.x -= 468;
		nbb.y -= 254;
		nbb.scale.set(1.3,1.3);
		FlxG.watch.add(nbb, "x");
		FlxG.watch.add(nbb, "y");		
		add(nbb);

		var bga:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('MENU/MENU-A'));
		bga.scrollFactor.set(0, 0);
		bga.updateHitbox();
		bga.scale.set(1.1,1.1);
		bga.screenCenter();
		bga.x += 300;
		bga.antialiasing = ClientPrefs.globalAntialiasing;
		add(bga);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('MENU/MENU-button');

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 160)  + 65);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + "-stop", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + "0", 24);
			menuItem.animation.addByPrefix('go', optionShit[i] + "-go", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			switch (i)
			{
				case 0:
					menuItem.x += 510;
					menuItem.y += 100;
				case 1:
					menuItem.x += 350;
					menuItem.y += 50;
				case 2:
					menuItem.x += 410;
					menuItem.y += 0;
				case 3:
					menuItem.x += 350;
					menuItem.y -= 60;
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected == 0)
							menuItems.members[0].x += 2;
						if (curSelected != 1)
							menuItems.members[1].x -= 1;
						else
							menuItems.members[1].x += 1;
						menuItems.members[0].x -= 2;
						menuItems.members[0].y -= 1;
						menuItems.members[0].scale.set(0.97,0.97);
						spr.animation.play('go');
						var daChoice:String = optionShit[curSelected];

						switch (daChoice)
						{
							case 'MENUPLAY':
								MusicBeatState.switchState(new StoryMenuState());
							case 'FREEPLAY':
								MusicBeatState.switchState(new FreeplayState());
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							case 'CREDITS':
								MusicBeatState.switchState(new CreditsState());
							case 'OPTIONS':
								MusicBeatState.switchState(new options.OptionsState());
						}
					});
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		switch (curSelected)
		{
			case 0:
				nbb.animation.play('idle');
			case 1:
				nbb.animation.play('idle');
			case 2:
				nbb.animation.play('idle');
			case 3:
				nbb.animation.play('idle');
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.x = 0;
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				switch (spr.ID)
				{
					case 0:
						spr.offset.x = 10;
						spr.offset.y = 5;
					case 1:
						spr.offset.x = 13;
						spr.offset.y = 7;
					case 3:
						spr.offset.x = 11;
						spr.offset.y = 3;
				}
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}