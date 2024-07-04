#INCLUDE "Wfc001.ch"
#include "FiveWin.ch"
#include "DbTree.ch"
#include "SIGAWF.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ WFC001  ³ Autor ³ 5055           ³ Data ³ 30.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gerenciador de mensagens                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void WFC001(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC cUser, cTask
STATIC aUsers
STATIC oFolder

Function WFA013()
	local nC
	local aAllUsers := AllUsers(.T.)
	
	PRIVATE aBrowsers, aFolders := {}
	
	aUsers := {}
	cUser := Subs( cUsuario,7,15 )
	
	ChkFile("WF6")

	for nC := 1 to len( aAllUsers )
		AAdd( aUsers, aAllUsers[ nC,1,2 ] )
	end
	
	ReLoadTasks()
	
	ShowDlg()
return

STATIC Function ShowDlg()
	local nC
	local lExit := .f.
	local aPrompts := {}
	local oDlg, oUser
	local bLine
	
	While !( lExit )
	
		DEFINE MSDIALOG oDlg TITLE "Gerenciador de Tarefas" From 8,0 To 36,80

		@ 0.7,  1 SAY "Usuário:" of oDlg 
		@ 0.5,  7 MSCOMBOBOX oUser VAR cUser ITEMS aUsers SIZE 92,50 OF oDlg
	
		if __cUserId <> "000000"
			oUser:SetDisable()
		end

		for nC := 1 to len( aFolders )
			AAdd( aPrompts, AllTrim( aFolders[ nC, 1 ] ) )
		next
	
		oFolder := TFolder():New( 20, 05, aPrompts, aPrompts, oDlg,,,,.T., .T., 307, 170,)
		aBrowsers := {}
	
		if len( aFolders ) > 0

			for nC := 1 to len( aFolders )
				oFolder:aDialogs[ nC ]:oFont := oDlg:oFont
				oFolder:aPrompts[ nC ] := aPrompts[ nC ]
				AAdd( aBrowsers, TWBrowse():New( 5, 5, 295, 150,{|| {}}, { "De", "Descricao", "Status", "Data", "Hora" },;
					{  100, 150, 40, 20, 20 }, oFolder:aDialogs[ nC ], , , , , , , , , , , , , , .T., , , , , ) )
				aBrowsers[ nC ]:lMChange := .T.
				aBrowsers[ nC ]:nClrBackFocus	:= GetSysColor( 13 )
				aBrowsers[ nC ]:nClrForeFocus	:= GetSysColor( 14 )
				aBrowsers[ nC ]:SetArray( aFolders[ nC,2 ] )
				bLine := "{|| { aFolders[" + str( nC ) + ",2,aBrowsers[" + str( nC ) + "]:nAt,1],"
				bLine += "aFolders[" + str( nC ) + ",2,aBrowsers[" + str( nC ) + "]:nAt,2],"
				bLine += "aFolders[" + str( nC ) + ",2,aBrowsers[" + str( nC ) + "]:nAt,3],"
				bLine += "aFolders[" + str( nC ) + ",2,aBrowsers[" + str( nC ) + "]:nAt,4],"
				bLine += "aFolders[" + str( nC ) + ",2,aBrowsers[" + str( nC ) + "]:nAt,5] } }"
				aBrowsers[ nC ]:bLine := &( bLine )
			next
		
		end
	
		@ 19.0, 64 BUTTON "Fechar" SIZE 55,15 OF oDlg ACTION ( lExit := .t., oDlg:End() )
		@ 19.0, 50 BUTTON "Abrir..." SIZE 55,15 OF oDlg ACTION ExecTask()

		ACTIVATE MSDIALOG oDlg CENTERED
	end
  
Return

STATIC FUNCTION ExecTask()
	local nActive := oFolder:nOption
	
	&(aFolders[ nActive,2,aBrowsers[ nActive ]:nAt,6 ] )
	
	
RETURN

STATIC FUNCTION ReLoadTasks()
	if cUser <> NIL
		Processa({|lEnd| LoadTasks()},OemToAnsi("Aguarde"),OemToAnsi("Verificando Tarefas..."), .F.)
	end
Return .T.

STATIC Function LoadTasks()
	local nC
	local aLines
	local cGrupo := "", cStatus, cKey
	
	DbSelectArea( "WF6" )
	DbSetOrder( 1 )
	
	cKey := xFilial( "WF6" ) + Upper( AllTrim( cUser ) )
	aFolders := {}	
	
	if DbSeek( cKey )

		while !Eof() .and. ( WF6_FILIAL + Upper( AllTrim( WF6_PROPRI ) ) ) == cKey
		
			if Upper( WF6_GRUPO ) <> Upper( cGrupo )
			
				if !Empty( cGrupo ) .and. len( aLines ) > 0
					AAdd( aFolders, { cGrupo, aLines } )
				end
				
				aLines := {}
				cGrupo := WF6_GRUPO
			end
			
			AAdd( aLines, {;
				WF6_REMET,;
				AllTrim( WF6_DESCR ),;
				if( WF6_STATUS == "1", "Pendente", if( WF6_STATUS == "2", "Finalizado", "Em execucao" ) ),;
				DtoC( WF6_DATA ),;
				WF6_HORA,;
				WF6_ACAO } )
				
			DbSkip()
		end
		
		if len( aLines ) > 0
			AAdd( aFolders, { cGrupo, aLines } )
		end
		
	end

Return .t.
                                       