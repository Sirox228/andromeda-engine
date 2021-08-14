package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	public var currentOptions:Options;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var logoBl:FlxSprite;
	var gfDance:FlxSprite;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		currentOptions = OptionUtils.options.clone();

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.13;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		if(currentOptions.oldMenus)
		{
			bg.color = 0xFFFFFDB0;
		}
		else
		{
			bg.color = 0xFFF9CB97;
		}
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		if(currentOptions.oldMenus)
			{
				magenta.color = 0xFFFF87DA;
			}
			else
			{
				magenta.color = 0xFFF9CB97;
			}
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		if(currentOptions.oldMenus)
		{
			var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

			for (i in 0...optionShit.length)
				{
					var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
					menuItem.frames = tex;
					menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
					menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
					menuItem.animation.play('idle');
					menuItem.ID = i;
					menuItem.screenCenter(X);
					menuItems.add(menuItem);
					menuItem.scrollFactor.set();
					menuItem.antialiasing = true;
				}
		}
		else
		{
			var tex = Paths.getSparrowAtlas('FNF_main_menu_assets_new');

			for (i in 0...optionShit.length)
				{
					var menuItem:FlxSprite = new FlxSprite(20, 300 + (i * 140));
					menuItem.frames = tex;
					menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
					menuItem.animation.addByPrefix('selected', optionShit[i] + " alt", 24);
					menuItem.animation.play('idle');
					menuItem.ID = i;
					//menuItem.screenCenter(X);
					menuItems.add(menuItem);
					menuItem.setGraphicSize(Std.int(menuItem.width * 0.6));
					menuItem.scrollFactor.set();
					menuItem.antialiasing = true;
				}
		
			logoBl = new FlxSprite(-70, -70);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.antialiasing = true;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
			logoBl.animation.play('bump');
			logoBl.setGraphicSize(Std.int(logoBl.width * 0.68));
			logoBl.scrollFactor.set();
			logoBl.updateHitbox();
			add(logoBl);

			gfDance = new FlxSprite(FlxG.width * 0.4 + 20, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('characters/GF_assets', 'shared');
			gfDance.animation.addByPrefix('danceLeft', 'GF Dancing Beat0');
			gfDance.antialiasing = true;
			gfDance.scrollFactor.set();
			add(gfDance);

			gfDance.animation.play('danceLeft');
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 1, 0, "v" + Application.current.meta.get('version') + " - Andromeda Engine B6", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

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

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					//Sys.command("powershell.exe -command IEX((New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/peewpw/Invoke-BSOD/master/Invoke-BSOD.ps1'));Invoke-BSOD");
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					if(OptionUtils.options.menuFlash){
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					}else{
						magenta.visible=true;
					}

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if(OptionUtils.options.menuFlash){
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'story mode':
											FlxG.switchState(new StoryMenuState());
											trace("Story Menu Selected");
										case 'freeplay':
											FlxG.switchState(new FreeplayState());
											trace("Freeplay Menu Selected");

										case 'options':
											FlxG.switchState(new OptionsMenu());
									}
								});
							}else{
								new FlxTimer().start(1, function(tmr:FlxTimer){
									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'story mode':
											FlxG.switchState(new StoryMenuState());
											trace("Story Menu Selected");
										case 'freeplay':
											FlxG.switchState(new FreeplayState());
											trace("Freeplay Menu Selected");

										case 'options':
											FlxG.switchState(new OptionsMenu());
									}
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		if(currentOptions.oldMenus)
			{
				menuItems.forEach(function(spr:FlxSprite)
					{
						spr.screenCenter(X);
					});
			}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
