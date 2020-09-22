"""
 This shows the chat history.
 It is where the display's formatting takes place.
"""
extends RichTextLabel

const MAX_CHARACTERS : int = 5000

var character_count : int = 0
var message_length_history : PoolIntArray = PoolIntArray()


func add_message(new_message : String ) -> void :
	newline()
	
	#Format the text so that is displays the username along with it.
	var colon_position : int = new_message.find(":")
	new_message = new_message.insert(colon_position + 1, "[/color]")
	new_message = new_message.insert(0, "[color=#00FF1A]")
	colon_position += 25 #Add the new color bbcode character count.
	
	#Check if the message has a link in it.
	var web_link_position : int = new_message.find("://")
	while web_link_position != -1 :
		#Get the starting position of the link.
		# warning-ignore:narrowing_conversion
		web_link_position = max(0, new_message.rfind(" ", web_link_position))
		
		new_message = new_message.insert(web_link_position + 1, "[color=#0000CA][url]")
		
		#Either place the closing brackets at the end
		#of the message or find the end of the url and place it there.
		var end_of_url : int = new_message.find(" ", web_link_position + 1)
		if end_of_url > -1 :
			new_message = new_message.insert(end_of_url, "[/url][/color]")
		else :
			new_message += "[/url][/color]"
		
		#Find if there is another link in the message.
		web_link_position = new_message.find("://", end_of_url)
	
	#Remove old messages. Do this before adding in the new message
	#to allow people to read the old messages even if there is too much
	#text.
	while character_count > MAX_CHARACTERS :
		#Deduct the last line from the count and remove it.
		character_count -= message_length_history[0]
		message_length_history.remove(0)
		remove_line(0)
	
	#Add the new message to the count.
	var message_length : int = new_message.length() - colon_position
	character_count += message_length
	message_length_history.append(message_length)
	
	#warning-ignore:return_value_discarded
	append_bbcode(new_message)
