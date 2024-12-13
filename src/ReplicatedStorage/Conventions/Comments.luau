--[[
	@author: William J. Horn
	@written: 12/12/2024
	TODO:
		Create a function later that can generate complex comment blocks, such as graphs or tables.

	-----------------------------
	---- COMMENT CONVENTIONS ---- 
	-----------------------------

	-----------
	| # Flags |
	-----------

		? = Bullet point, inline-code snippet, or FYI label
			# Common examples:
				- ? FYI: ...
				- ? note: ...
				- ? info: ...
				- ? print("Inline code")

			Our comment block version of this flag is:
			
				? --> FYI:
					...text
					...text
				? <--

			Or if you just want to highlight the first part of the comment block:

				? --> This is some additional information...
					...
					...
				? <--

		! = Critical warning, if-then error cases, known bug issues
			# Common examples:
				- ! bug: ...
				- ! warning: ...
				- ! throw error:
						...error case description
						...error case description

		* = Function signature
			# Common examples:
				- * myMethod(param1<type>, param2<type>):

		@ = Document info pointers, function/method API info
				# Common examples:
					- @param
					- @desc
					- @return
					- @author

		# = Header or sub-header text
			# Common examples:
				- This

		TODO = Reminders of features to add, change, or remove
			# Common examples:
				- TODO: Add x feature later
				- TODO: Remove x feature later
				- TODO: Revisit this later

	---------------------
	| # Section Markers |
	---------------------

		? <Script Chapter> 

			A sectioned-off area in the script that stands alone, or provides a complete idea. Looks like this:

				------------------------
				---- SCRIPT CHAPTER ---- 
				------------------------

			Each script chapter should be enclosed with exactly four dashes "----" on both sides, with one space character
			between the dashes and the chapter text. Chapter titles should be in all caps

			Common examples include sectioning-off global variable declarations, references to ROBLOX directories or instances,
			labeling utility functions, etc.

				Ex:

					--------------------------
					---- GLOBAL VARIABLES ---- 
					--------------------------

					...

					---------------------------
					---- UTILITY FUNCTIONS ---- 
					---------------------------
					
					...

			? <Chapter Title>

				Similar to <Script Chapter>, but one level down. Used to organize smaller-scoped ideas together, to label sub-sections
				in a <Script Chapter>, or as a heading. Example:

					-------------------
					| # Chapter Title |
					-------------------

				Like all other comment labels, this does not have to be used strictly inside <Script Chapter> blocks. However, if it
				is used in a chapter block, indentation after the <Chapter Title> is recommended. <Chapter Title> itself does
				not need to be indented under <Script Chapter>. Example:

					------------------------
					---- SCRIPT CHAPTER ---- 
					------------------------
					...
					...
					-------------------
					| # Chapter Title |
					-------------------
						...
						...

]]