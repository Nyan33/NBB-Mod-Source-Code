function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Stand Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'STANDNOTE_assets'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', 1);
		end
	end
	--debugPrint('Script started!')
end

-- Function called when you hit a note (after note hit calculations)
-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
-- noteType: The note type string/tag
-- isSustainNote: If it's a hold note, can be either true or false
function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Attack Note' then
		playShootAnimation();
	end
end

function playShootAnimation()
	characterPlayAnim('dad', 'stand', true);
	setProperty('dad.specialAnim', true);
end