--[[
	@author: William J. Horn
	@written: 12/12/2024

	These are some comment convensions that I developed over the course of
	working on many, many projects.

	? FYI: These conventions are based on VSCode and the 'Better Comments' VSCode extension.

	TODO:
		Create a function later that can generate complex comment blocks, such as graphs or tables.

	-----------------------------
	---- COMMENT CONVENTIONS ---- 
	-----------------------------

	-----------
	| # Flags |
	-----------

		? = Bullet point, inline-code snippet, or FYI label
			# Common inline examples:
				- ? FYI: ...
				- ? note: ...
				- ? info: ...
				- ? print("Inline code")

			# A comment block version of this flag is:
			
				? --> FYI:
					...text
					...text
				? <--

			# Or if you just want to highlight the first part of the comment block:

				? --> This is some additional information...
					...
					...
				? <--

			# If you just need a one-off mult-line use, you can do:

				? FYI:

					...
					...

		! = Critical warning, if-then error cases, known bug issues
			# Common inline examples:
				- ! bug: ...
				- ! warning: ...
				- ! error: ...

			A comment block version of this flag is:
			
				! --> bug:
					...text
					...text
				! <--

			Or if you just want to highlight the first part of the comment block:

				! --> Some urgent message...
					...
					...
				! <--

			If you just need a one-off mult-line use, you can do:

				! bug:

					...
					...

		* = Function signature
			# Common examples:
				- * myMethod(param1<type>, param2<type>):

		@ = Document info pointers, function/method API info
				# Common inline examples:
					- @param name<type>: ...param description...
					- @return value<type>: ...return value description...
					- @desc: ...description...
					- @author: William J. Horn
					- @any: ...

				# Multi-line for @param:

					@param name<type>:
						...
						...

				# Multi-line for @return

					@return value<type>:
						...
						...

				# Multi-line for everything else:

					@any:
						...
						...

		# = Header or sub-header text
			# Common examples:
				- This

		TODO = Reminders of features to add, change, or remove
			# Common examples:
				- TODO: Add x feature later
				- TODO: Remove x feature later
				- TODO: Revisit this later

			# Multi-line example:

				TODO:
					...
					...

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