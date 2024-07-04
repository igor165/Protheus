#INCLUDE "WFA009.ch"
#include "SIGAWF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ WFA009   ³ Autor ³ Yale                  ³ Data ³ 15.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Envio de Arquivos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void WFA009(void)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

function WFA009( cAlias, nReg, nOpc )

	DEFAULT cAlias := "WF5", nReg := 0, nOpc := 0

#IFDEF WNTX
	xDriver := "DBFNTX"
#ENDIF

	PRIVATE cCadastro := STR0001 //"Cadastro de Envio de Arquivos"
	PRIVATE aRotina := {	{ STR0002, "AxVisual", 0 , 2 },; //"Visualizar"
								{ STR0003, "AxInclui", 0 , 3 },; //"Incluir"
								{ STR0004, "AxAltera", 0 , 4 },; //"Alterar"
								{ STR0005, "AxDeleta", 0 , 5, 3 },; //"Excluir"
								{ "Executar", "WFA009EXE", 0 , 6, 3 }} //"Executar"
	mBrowse( 6, 1, 22, 75, cAlias )
	if Select( cAlias ) <> 0
		DbSelectArea( cAlias )
		DbCloseArea()
	end
Return nil

function WFA009EXE()
	local cMsg := "Deseja executar o envio de arquivos para o cadastro: %c?"
	if MsgYesNo( FormatStr( cMsg, alltrim(WF5->WF5_DESCR) ) )
		StartJob("WFLauncher", GetEnvServer(), .f., {"WFSndFiles",{ cEmpAnt, cFilAnt, WF5->WF5_COD }})
	end
return

Static Function ChkValidation()
	local lResult := .t.
	begin sequence
		if M->WF5_ARQUIV == "1"
			if Empty( M->WF5_NOMARQ )
				HELP(" ",1,"WFA009EARQ")
				break
			end
		end
		if M->WF5_ANTENV == "2"
			if Empty( M->WF5_ANTFUN ) .or. Empty( M->WF5_ANTAMB )
				HELP(" ",1,"WFA009FUSU")
				break
			end
		end
		if M->WF5_POSENV == "2"
			if Empty( M->WF5_POSFUN ) .or. Empty( M->WF5_POSAMB )
				HELP(" ",1,"WFA009FUSU")
				break
			end
		end
	recover
		lResult := .f.
	end
Return lResult
