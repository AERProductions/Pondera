mob/players/var//This is where the character variables take place.
	JournalEntries = 0//This is the variable that records how many Journal Entries the character has.
	JournalWriting = "You have not made any entries yet."//This is the variable that defines what the character has in his journal.
mob/players/verb//This is where the character commands will be called.
	Read_Journal()
		set hidden = 1//This is the character command 'View Journal'.
		var/JournalHTML//This is the variable that contains the HTML, and the Journal Writing in it.
		JournalHTML += {"<Title>Personal Journal -</Title>
						<body BGColor = #154812  Text = #4B7BDC link = #4B7BDC vlink = #C0C0C0 alink = #C0C0C0 Scroll = No>
						<table border="1" bordercolor="#4B7BDC" style="background-color:#154812" width="380" cellpadding="0" cellspacing="0">
						<Tr>
						<Td Width = "100%" Colspan="2">
						<Center><Font Color = "#4B7BDC">Personal Journal
						</Td>
						</Tr>
						</Table>
						<BR>
						<table border="1" bordercolor="#4B7BDC" style="background-color:#154812" width="380" cellpadding="0" cellspacing="0">
						<Tr>
						<Td Width = "100%" Colspan="2">
						<Center>[src.JournalWriting]<BR><BR><HR Width = 75%><BR>Currently Written : <B>[src.JournalEntries]</B>
						</Td>
						</Tr>
						</Table>
						<BR>
						<Center><A Href = "?Action=JournalEdit&src=\ref[src]">Edit</A>
						"}//This is where the writing is placed, and the HTML to make it look fancy.
		src << browse(JournalHTML,"window=Journal")//This is where the writing will pop up in a display box.
	Toss_Journal()
		set hidden = 1//This is the character command 'Delete Journal'.
		src.JournalEntries = 0//This sets the characters Journal Entries back to 0.
		src.JournalWriting = "You have not made any entries yet."//This sets the Journal Writing back to the default.
		alert("Journal was thrown out.","Personal Journal -")//This is a confirming message that the action has been completed.
	Write_in_Journal()
		set hidden = 1//This is the character command 'Edit Journal'.
		var/JournalEdit = input("What would you like to write in your Journal?","Personal Journal -","[src.JournalWriting]")as message//This is the pop up box that will let you edit your Journal Writing.
		if(JournalEdit == "")//This is where if the Journal Entry is blank, it'll bring an error.
			alert("You did not write anything in your Journal.","Personal Journal -")//This is to show that the action could not be completed.
		else//This is where if it is not blank, it'll bring the results.
			src.JournalWriting = JournalEdit//This turns the characters Journal Writing into Journal Edit
			src.JournalEntries ++//This makes the characters Journal Entries go up by 1.
			var/JournalHTML//This is the variable that contains the HTML, and the Journal Writing in it.
			JournalHTML += {"<Title>Personal Journal -</Title>
					<body BGColor = #154812  Text = #4B7BDC link = #4B7BDC vlink = #C0C0C0 alink = #C0C0C0 Scroll = No>
					<table border="1" bordercolor="#4B7BDC" style="background-color:#154812" width="380" cellpadding="0" cellspacing="0">
					<Tr>
					<Td Width = "100%" Colspan="2">
					<Center><Font Color = "#4B7BDC">Personal Journal
					</Td>
					</Tr>
					</Table>
					<BR>
					<table border="1" bordercolor="#4B7BDC" style="background-color:#154812" width="380" cellpadding="0" cellspacing="0">
					<Tr>
					<Td Width = "100%" Colspan="2">
					<Center>[src.JournalWriting]<BR><BR><HR Width = 75%><BR>Currently Written : <B>[src.JournalEntries]</B>
					</Td>
					</Tr>
					</Table>
					<BR>
					<Center><A Href = "?Action=JournalEdit&src=\ref[src]">Edit</A>
					"}//This is where the writing is placed, and the HTML to make it look fancy.
			src << browse(JournalHTML,"window=Journal")//This is where the writing will pop up in a display box.

mob/players/Topic(href,list[])//This is the client/Topic which will activate the link.
	switch(list["Action"])//This is the list in which the links are called from.
		if("JournalEdit")//This displays what link I am verifying.
			var/JournalEdit = input("What would you like to write in your Journal?","Personal Journal -","[src.JournalWriting]")as message//This is the pop up box that will let you edit your Journal Writing.
			if(JournalEdit == "")//This is where if the Journal Entry is blank, it'll bring an error.
				alert("You did not write anything into your Journal.","Personal Journal -")//This is to show that the action could not be completed.
			else//This is where if it is not blank, it'll bring the results.
				src.JournalWriting = JournalEdit//This turns the characters Journal Writing into Journal Edit
				src.JournalEntries ++//This makes the characters Journal Entries go up by 1.
				var/JournalHTML//This is the variable that contains the HTML, and the Journal Writing in it.
				JournalHTML += {"<Title>Personal Journal -</Title>
						<body BGColor = #154812  Text = #4B7BDC link = #4B7BDC vlink = #C0C0C0 alink = #C0C0C0 Scroll = No>
						<table border="1" bordercolor="#4B7BDC" style="background-color:#154812" width="380" cellpadding="0" cellspacing="0">
						<Tr>
						<Td Width = "100%" Colspan="2">
						<Center><Font Color = "#4B7BDC">Personal Journal
						</Td>
						</Tr>
						</Table>
						<BR>
						<table border="1" bordercolor="#4B7BDC" style="background-color:#154812" width="380" cellpadding="0" cellspacing="0">
						<Tr>
						<Td Width = "100%" Colspan="2">
						<Center>[src.JournalWriting]<BR><BR><HR Width = 75%><BR>Currently Written : <B>[src.JournalEntries]</B>
						</Td>
						</Tr>
						</Table>
						<BR>
						<Center><A Href = "?Action=JournalEdit&src=\ref[src]">Edit</A>
						"}//This is where the writing is placed, and the HTML to make it look fancy.
				src << browse(JournalHTML,"window=Journal")//This is where the writing will pop up in a display box.

