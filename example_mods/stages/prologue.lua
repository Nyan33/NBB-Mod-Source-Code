function onCreate()
	makeLuaSprite('moonlight1', 'plus/moonlight1', -600, -350);
	setLuaSpriteScrollFactor('moonlight1', 1.0, 1.0);
	setBlendMode('moonlight1', 'multiply');
	addLuaSprite('moonlight1', true);

	makeLuaSprite('moonlight2', 'plus/moonlight2', -600, -350);
	setLuaSpriteScrollFactor('moonlight2', 1.0, 1.0);
	setProperty('moonlight2.alpha', 0.4);
	setBlendMode('moonlight2', 'add');
	addLuaSprite('moonlight2', true);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end
