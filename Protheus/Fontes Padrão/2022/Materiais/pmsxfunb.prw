#include "PROTHEUS.CH"
#include "pmsxfunb.ch"
#include "pmsicons.ch"
#include "AP5MAIL.CH"
#include "MSGRAPHI.CH"
#include "report.ch"

Static __lTopConn	:= IfDefTopCTB()
Static __aComboSX3  := {}
STATIC aHeaderAJ7   := {}
STATIC cCpoCodPrj   := ""
STATIC cCpoCodRev   := ""
STATIC cModelCpo  	:= ""
STATIC cTipoObj   	:= ""
STATIC aHeadS		:= {}
STATIC aColsS		:= {}
STATIC lVersion		:= NIL

STATIC cEofF3AF2  	:= ''
STATIC cBofF3AF2  	:= ''
STATIC cEofF3AF5  	:= ''
STATIC cBofF3AF5  	:= ''
STATIC cEofF3AF9  	:= ''
STATIC cBofF3AF9  	:= ''
STATIC cEofF3AFC  	:= ''
STATIC cBofF3AFC  	:= ''
STATIC cRetSX1		:= ''
STATIC aExcecoes	:= {}
STATIC aProjets		:= {}
STATIC lNewCalend
#IFDEF TOP
	STATIC lDefTop := .T.
#ELSE
	STATIC lDefTop := .F.
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | ConvRGB   ³ Autor ³ Edson Maricate         ³ Data ³ 20-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte o valor numerico da cor em um array contendo os       ³±±
±±³          ³ valores RGB.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ConvRGB(nNumero)

nBlue := INT(nNumero/65536)
nResto := nNumero - (nBlue *65536)
nGreen := INT(nResto/256)
nResto := nResto - (nGreen *256)
nRed := INT(nResto)


Return {nRed,nGreen,nBlue}


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |OnePixBmp³ Autor ³ Edson Maricate           ³ Data ³ 20-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria um bitmap de 1 pixel com a cor RGB passada no array.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OnePixBmp(aColor,cFile,cDir)

Local nRed		:= aColor[1]
Local nGreen	:= aColor[2]
Local nBlue		:= aColor[3]
Local nX		:= 0

DEFAULT cDir	:= ""
DEFAULT cFile	:= Dec2Hex(nRed)+Dec2Hex(nGreen)+Dec2Hex(nBlue)+".BMP"

If !Empty(cDir)
	cDir := "\"+cDir+"\"
	MAKEDIR(cDir)
EndIf

If !File(cDir+cFile)
	aBmp := {	"42","4D","3A","00","00","00","00","00","00","00","36","00","00","00","28","00",;
				"00","00","01","00","00","00","01","00","00","00","01","00","18","00","00","00",;
				"00","00","04","00","00","00","29","00","00","00","00","00","00","00","00","00",;
				"00","00","00","00","00","00",Dec2Hex(nBlue),Dec2Hex(nGreen),Dec2Hex(nRed),"00"}

	nHandle := FCreate(cDir+cFile)
	cWrite := ""
	For nx := 1 to Len(aBmp)
		cWrite += Chr(Hex2Dec(aBmp[nx]))
	Next
	FWrite( nHandle, cWrite )
	FClose( nHandle )
EndIf

Return cDir+cFile
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Dec2Hex ³ Autor ³ Edson Maricate         ³ Data ³ 20/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Converte um numero decimal ate' 255 para hexadecimal        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpC1 := Dec2Hex( ExpN1 )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpN1 -> valor                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna	 ³ ExpC1 -> String de 2 bytes                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Dec2Hex(nVal)
Local cString := "0123456789ABCDEF"
Return(Substr(cString,Int(nVal/16)+1,1)+Substr(cString,nVal-(Int(nVal/16)*16)+1,1))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Hex2Dec ³ Autor ³ Edson Maricate         ³ Data ³ 20/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte um numero Hexadecimal para decimal ate' 65535     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpN1 := Hex2Dec( ExpC1 )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 -> String a converter ( ate 4 bytes )                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna	 ³ ExpN1 -> Numero decimal                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Hex2Dec(cVal)

Local cString:="0123456789ABCDEF", nVal:=0
If Len(cVal) < 4
	cVal:= Replicate("0", 4 - Len(cVal) ) + cVal
Endif
nVal := ( At( Left( cVal, 1 )   , cString ) - 1  ) * 4096
nVal += ( At( Substr( cVal, 2, 1 ), cString ) - 1  ) * 256
nVal += ( At( Substr( cVal, 3, 1 ), cString ) - 1  ) * 16
nVal += ( At( Substr( cVal, 4, 1 ), cString ) - 1  )
Return( nVal )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAF5Niv³ Autor ³  Adriano Ueda          ³ Data ³ 24-03-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para recalculo de nivel (orcamento)                   ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao recursiva recalcula o nivel das tarefas e EDTs   ³±±
±±³          ³ a partir de uma EDT.                                         ³±±
±±³          ³                                                              ³±±
±±³          ³ EDTs abaixo da EDT atual sao calculadas atraves de uma       ³±±
±±³          ³ chamada recursiva                                            ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcamento - codigo do orcamento                             ³±±
±±³          ³ cEdtAnt    - codigo da EDT                                   ³±±
±±³          ³ cNivel     - nivel da EDT                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSAF5Nivel(cOrcamento, cEdtAnt, cNivel)
	Local aAreaAF5 := AF5->(GetArea())
	Local aAreaAF2 := AF2->(GetArea())

	// recalcula o nivel das tarefas abaixo
	// da EDT atual (cEDT)
	dbSelectArea("AF2")
	AF2->(dbSetOrder(2)) // AF2_FILIAL + AF2_ORCAME + AF2_EDTPAI + AF2_ORDEM

	If AF2->(MsSeek(xFilial("AF2") + cOrcamento + cEdtAnt))
		While AF2->AF2_FILIAL == xFilial("AF2") .And. ;
		      AF2->AF2_ORCAME == cOrcamento     .And. ;
		      AF2->AF2_EDTPAI == cEdtAnt        .And. !AF2->(EoF())

			RecLock("AF2", .F.)
				AF2->AF2_NIVEL := StrZero(Val(cNivel) + 1, TamSX3("AF2_NIVEL")[1])
			MsUnlock()

			AF2->(dbSkip())
		End
	EndIf

	// recalcula o nivel das EDTs abaixo
	// da EDT atual (cEDT)
	dbSelectArea("AF5")
	AF5->(dbSetOrder(2))  // AF5_FILIAL + AF5_ORCAME + AF5_EDTPAI + AF5_ORDEM

	If MsSeek(xFilial("AF5") + cOrcamento + cEdtAnt)
		While AF5->AF5_FILIAL == xFilial("AF5") .And. ;
		      AF5->AF5_ORCAME == cOrcamento     .And. ;
		      AF5->AF5_EDTPAI == cEdtAnt        .And. !AF5->(EoF())

		  RecLock("AF5", .F.)
		  	AF5->AF5_NIVEL := StrZero(Val(cNivel) + 1, TamSX3("AF5_NIVEL")[1])
		  MsUnlock()

			// recalcula o nivel da EDT abaixo da atual
			PMSAF5Nivel(AF5->AF5_ORCAME, AF5->AF5_EDT, AF5->AF5_NIVEL)

			AF5->(dbSkip())
	  End
	EndIf

	RestArea(aAreaAF2)
	RestArea(aAreaAF5)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAFCNiv³ Autor ³  Adriano Ueda          ³ Data ³ 24-03-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para recalculo de nivel (projeto)                     ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao recursiva recalcula o nivel das tarefas e EDTs   ³±±
±±³          ³ a partir de uma EDT.                                         ³±±
±±³          ³                                                              ³±±
±±³          ³ EDTs abaixo da EDT atual sao calculadas atraves de uma       ³±±
±±³          ³ chamada recursiva                                            ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto - codigo do projeto                                 ³±±
±±³          ³ cEDT     - codigo da EDT                                     ³±±
±±³          ³ cNivel   - nivel da EDT                                      ³±±
±±³          ³ cRevisa  - revisao do projeto                                ³±±
±±³          ³            se a revisao nao for informada, utiliza a revisao ³±±
±±³          ³            corrente, obtida atraves da PMSAF8Ver()           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA200, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSAFCNivel(cProjeto, cEDT, cNivel, cRevisa)
	Local aAreaAFC := AFC->(GetArea())
	Local aAreaAF9 := AF9->(GetArea())

	Default cRevisa := PMSAF8Ver(cProjeto)

	// recalcula o nivel das tarefas abaixo
	// da EDT atual (cEDT)
	dbSelectArea("AF9")
	AF9->(dbSetOrder(2)) // AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI + AF9_ORDEM

	If AF9->(MsSeek(xFilial("AF9") + cProjeto + cRevisa + cEDT))
		While AF9->AF9_FILIAL == xFilial("AF9") .And. ;
		      AF9->AF9_PROJET == cProjeto       .And. ;
		      AF9->AF9_EDTPAI == cEDT           .And. ;
		      AF9->AF9_REVISA == cRevisa        .And. !AF9->(EoF())

			RecLock("AF9", .F.)
				AF9->AF9_NIVEL := StrZero(Val(cNivel) + 1, TamSX3("AF9_NIVEL")[1])
			MsUnlock()

			AF9->(dbSkip())
		End
	EndIf

	// recalcula o nivel das EDTs abaixo
	// da EDT atual (cEDT)
	dbSelectArea("AFC")
	AFC->(dbSetOrder(2))  // AFC_FILIAL + AFC_PROJET + AFC_REVISA + AFC_EDTPAI + AFC_ORDEM

	If MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
		While AFC->AFC_FILIAL == xFilial("AFC") .And. ;
		      AFC->AFC_PROJET == cProjeto       .And. ;
		      AFC->AFC_REVISA == cRevisa        .And. ;
		      AFC->AFC_EDTPAI == cEDT           .And. !AFC->(EoF())

		  RecLock("AFC", .F.)
		  	AFC->AFC_NIVEL := StrZero(Val(cNivel) + 1, TamSX3("AFC_NIVEL")[1])
		  MsUnlock()

			// recalcula o nivel da EDT abaixo da atual
			PMSAFCNivel(AFC->AFC_PROJET, AFC->AFC_EDT, AFC->AFC_NIVEL,AFC->AFC_REVISA)

			AFC->(dbSkip())
	  End
	EndIf

	RestArea(aAreaAF9)
	RestArea(aAreaAFC)
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAFCCod³ Autor ³  Adriano Ueda          ³ Data ³ 26-05-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para recodificacao de tarefas e EDTs                  ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao recursiva recalcula o codigo das tarefas e EDTs, ³±±
±±³          ³ a partir de uma EDT.                                         ³±±
±±³          ³                                                              ³±±
±±³          ³ Este procedimento e necessario quando e realizada a troca de ³±±
±±³          ³ uma EDT pai de um EDT.                                       ³±±
±±³          ³                                                              ³±±
±±³          ³ EDTs abaixo da EDT atual sao calculadas atraves de uma       ³±±
±±³          ³ chamada recursiva.                                           ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto - codigo do projeto                                 ³±±
±±³          ³ cEDT     - codigo da EDT de destino                          ³±±
±±³          ³ cEDTAnt  - codigo da EDT de origem                           ³±±
±±³          ³ cRevisa  - revisao do projeto                                ³±±
±±³          ³            se a revisao nao for informada, utiliza a revisao ³±±
±±³          ³            corrente, obtida atraves da PMSAF8Ver()           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA200, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSAFCCod(cProjeto, cEDT, cEDTAnt, cRevisa,aTabelas)
	Local aAreaAFC := AFC->(GetArea())
	Local aAreaAF9 := AF9->(GetArea())
	Local cEDTAnt2 := ""

	Local aNodes   := {}
	Local nNode    := 0

	Local cOldCode := ""

	Default cRevisa := PMSAF8Ver(cProjeto)

	dbSelectArea("AF9")
	AF9->(dbSetOrder(2)) // AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI + AF9_ORDEM
	AF9->(MsSeek(xFilial("AF9") + cProjeto + cRevisa + cEDTAnt))

	While AF9->AF9_FILIAL == xFilial("AF9") .And. ;
	      AF9->AF9_PROJET == cProjeto       .And. ;
	      AF9->AF9_REVISA == cRevisa        .And. ;
	      AF9->AF9_EDTPAI == cEDTAnt        .And. !AF9->(EoF())
		aAdd(aNodes, {PMS_TASK,;
		              AF9->(Recno()),;
		              If(Empty(AF9->AF9_ORDEM), "000", AF9->AF9_ORDEM),;
	  	            AF9->AF9_TAREFA;
		              })
		AF9->(dbSkip())
	End

	dbSelectArea("AFC")
	AFC->(dbSetOrder(2))  // AFC_FILIAL + AFC_PROJET + AFC_REVISA + AFC_EDTPAI + AFC_ORDEM
	AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDTAnt))

	While AFC->AFC_FILIAL == xFilial("AFC") .And. ;
			AFC->AFC_PROJET == cProjeto       .And. ;
			AFC->AFC_REVISA == cRevisa        .And. ;
			AFC->AFC_EDTPAI == cEDTAnt        .And. !AFC->(EoF())

		aAdd(aNodes, {PMS_WBS,;
						AFC->(Recno()),;
						If(Empty(AFC->AFC_ORDEM), "000", AFC->AFC_ORDEM),;
						AFC->AFC_EDT;
					})

		AFC->(dbSkip())
	End

	// ordenacao conjunta de tarefa/EDTs
	aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4] })

	For nNode := 1 To Len(aNodes)
		If aNodes[nNode][1] == PMS_TASK
			AF9->(dbGoto(aNodes[nNode][2]))

			cOldCode := AF9->AF9_TAREFA

			RecLock("AF9", .F.)
				AF9->AF9_TAREFA := PMSNumAF9(AF9->AF9_PROJET,;
				                             AF9->AF9_REVISA,;
				                             PMSGetNivel(AF9->AF9_PROJET, AF9->AF9_REVISA, cEDT),;
				                             cEDT)
				AF9->AF9_EDTPAI := cEDT
			MsUnlock()

			If GetMV("MV_PMSTCOD") == "2"	.Or. GetMV("MV_PMSTCOD") == "3"
				AF9RecRelTables(AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA, cOldCode, AF9->AF9_TAREFA,aTabelas)
			EndIf
		Else
			AFC->(dbGoto(aNodes[nNode][2]))

			cEDTAnt2 := AFC->AFC_EDT

			RecLock("AFC", .F.)
				AFC->AFC_EDT := PMSNumAFC(AFC->AFC_PROJET,;
				                          AFC->AFC_REVISA,;
				                          PMSGetNivel(AFC->AFC_PROJET, AFC->AFC_REVISA, cEDT),;
				                          cEDT)
				AFC->AFC_EDTPAI := cEDT
			MsUnlock()

			If GetMV("MV_PMSTCOD") == "2"	.Or. GetMV("MV_PMSTCOD") == "3"
				AFCRecRelTables(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cEDTAnt2, AFC->AFC_EDT,aTabelas)
			EndIf

			//recalcula o codigo da EDT abaixo da atual
			PMSAFCCod(AFC->AFC_PROJET, AFC->AFC_EDT, cEDTAnt2, AFC->AFC_REVISA,aTabelas)
		EndIf
	Next

	RestArea(aAreaAF9)
	RestArea(aAreaAFC)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAF5Cod³ Autor ³  Adriano Ueda          ³ Data ³ 26-05-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para recodificacao de tarefas e EDTs                  ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao recursiva recalcula o codigo das tarefas e EDTs, ³±±
±±³          ³ a partir de uma EDT.                                         ³±±
±±³          ³                                                              ³±±
±±³          ³ Este procedimento e necessario quando e realizada a troca de ³±±
±±³          ³ uma EDT pai de um EDT.                                       ³±±
±±³          ³                                                              ³±±
±±³          ³ EDTs abaixo da EDT atual sao calculadas atraves de uma       ³±±
±±³          ³ chamada recursiva.                                           ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcame - codigo do orcamento                                ³±±
±±³          ³ cEDT     - codigo da EDT de destino                          ³±±
±±³          ³ cEDTAnt  - codigo da EDT de origem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA200, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSAF5Cod(cOrcame, cEDT, cEDTAnt)
	Local aAreaAF5 := AF5->(GetArea())
	Local aAreaAF2 := AF2->(GetArea())
	Local cEDTAnt2 := ""

	Local aNodes   := {}
	Local nNode    := 0

	dbSelectArea("AF2")
	AF2->(dbSetOrder(2)) // AF2_FILIAL + AF2_ORCAME + AF2_EDTPAI + AF2_ORDEM
	AF2->(MsSeek(xFilial("AF2") + cOrcame + cEDTAnt))

	While !AF2->(Eof()) .And. AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_EDTPAI ==;
														xFilial("AF2") + cOrcame +  cEDTAnt
		aAdd(aNodes, {1,;
						AF2->(Recno()),;
						If(Empty(AF2->AF2_ORDEM), "000", AF2->AF2_ORDEM),;
						AF2->AF2_TAREFA;
	  	   })
		AF2->(dbskip())
	End

	dbSelectArea("AF5")
	AF5->(dbSetOrder(2))  // AF5_FILIAL + AF5_ORCAME + AF5_EDTPAI + AF5_ORDEM
	AF5->(MsSeek(xFilial("AF5") + cOrcame + cEDTAnt))

	While !AF5->(Eof()) .And. AF5->AF5_FILIAL + AF5->AF5_ORCAME + AF5->AF5_EDTPAI ==;
		xFilial("AF5") + cOrcame + cEDTAnt
		aAdd(aNodes, {2,;
                AF5->(Recno()),;
		              If(Empty(AF5->AF5_ORDEM), "000", AF5->AF5_ORDEM),;
		              AF5->AF5_EDT;
                })
  		AF5->(dbskip())
	End

	// ordenacao conjunta de tarefa/EDTs
	aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4] })

	For nNode := 1 To Len(aNodes)
		If aNodes[nNode][1] == 1
			AF2->(dbGoto(aNodes[nNode][2]))
			cOldCode := AF2->AF2_TAREFA

			RecLock("AF2", .F.)
				AF2->AF2_TAREFA := PMSNumAF2(AF2->AF2_ORCAME,;
											PMSGetNivOrc(AF2->AF2_ORCAME, cEDT),;
											cEDT)
				AF2->AF2_EDTPAI := cEDT
			MsUnlock()

			If GetMV("MV_PMSTCOD") == "2"	.Or. GetMV("MV_PMSTCOD") == "3"
				AF2RecRelTables(AF2->AF2_FILIAL, AF2->AF2_ORCAME, cOldCode, AF2->AF2_TAREFA)
			EndIf

		Else
			AF5->(dbGoto(aNodes[nNode][2]))

			cEDTAnt2 := AF5->AF5_EDT

			RecLock("AF5", .F.)
		  	AF5->AF5_EDT := PMSNumAF5(AF5->AF5_ORCAME,;
				                          PMSGetNivOrc(AF5->AF5_ORCAME, cEDT),;
				                          cEDT)
		  	AF5->AF5_EDTPAI := cEDT
			MsUnlock()

			//recalcula o codigo da EDT abaixo da atual
			PMSAF5Cod(AF5->AF5_ORCAME, AF5->AF5_EDT, cEDTAnt2)

			If GetMV("MV_PMSTCOD") == "2"	.Or. GetMV("MV_PMSTCOD") == "3"
				AF5RecRelTables(AF5->AF5_FILIAL, AF5->AF5_ORCAME, cEDTAnt2, AF5->AF5_EDT)
			EndIf

		EndIf
	Next nNode


	RestArea(aAreaAF2)
	RestArea(aAreaAF5)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSGetNiv³ Autor ³  Adriano Ueda          ³ Data ³ 26-05-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o codigo de nivel de uma EDT                         ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao retorna o codigo de nivel de uma EDT.            ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto - codigo do projeto                                 ³±±
±±³          ³ cRevisa  - revisao do projeto                                ³±±
±±³          ³            se a revisao nao for informada, utiliza a revisao ³±±
±±³          ³            corrente, obtida atraves da PMSAF8Ver()           ³±±
±±³          ³ cEDT     - codigo da EDT de destino                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo de nivel ou string vazia, caso nao seja encontrada a  ³±±
±±³          ³ EDT.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA200, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSGetNivel(cProjeto, cRevisa, cEDT)
Local cNivel := "000"
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())

Default cRevisa := PMSAF8Ver(cProjeto)

dbSelectArea("AFC")
AFC->(dbSetOrder(1))  // AFC_FILIAL + AFC_PROJET + AFC_REVISA + AFC_EDT + AFC_ORDEM

If MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDT)
	cNivel := AFC->AFC_NIVEL
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFC)

Return cNivel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSGetNivOrc³ Autor ³ Adriano Ueda         ³ Data ³ 26-05-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o codigo de nivel de uma EDT                          ³±±
±±³          ³                                                               ³±±
±±³          ³ Esta funcao retorna o codigo de nivel de uma EDT.             ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcame - codigo do projeto                                   ³±±
±±³          ³ cEDT     - codigo da EDT de destino                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo de nivel ou string vazia, caso nao seja encontrada a   ³±±
±±³          ³ EDT.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, SIGAPMS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSGetNivOrc(cOrcame, cEDT)
Local cNivel := "000"
Local aAreaAF5 := AF5->(GetArea())
Local aAreaAF2 := AF2->(GetArea())

dbSelectArea("AF5")
AF5->(dbSetOrder(1))  // AF5_FILIAL + AF5_ORCAME + AF5_EDT + AF5_ORDEM

If MsSeek(xFilial("AF5") + cOrcame + cEDT)
	cNivel := AF5->AF5_NIVEL
EndIf

RestArea(aAreaAF2)
RestArea(aAreaAF5)

Return cNivel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSSeekTr³ Autor ³  Adriano Ueda          ³ Data ³ 22-07-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para pesquisa na arvore do projeto/orcamento, atraves ³±±
±±³          ³ da descricao da tarefa/EDT.                                  ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao apenas apresenta a caixa de dialogo para         ³±±
±±³          ³ pesquisa. A pesquisa e realmente realizada através da funcao ³±±
±±³          ³ PMSFindText.                                                 ³±±
±±³          ³                                                              ³±±
±±³          ³ O texto e pesquisado a partir da posicao corrente do Tree    ³±±
±±³          ³ ate o final do Tree.                                         ³±±
±±³          ³                                                              ³±±
±±³          ³ Se o texto e encontrado, o Tree e reposicionado para refletir³±±
±±³          ³ a posicao do texto.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oTree       - objeto Tree a ser pesquisado, deve ser diferen ³±±
±±³          ³               te de Nil.                                     ³±±
±±³          ³ cSearchText - deve ser passada por referencia. esta variavel ³±±
±±³          ³               contera o valor digitado na caixa de dialogo e ³±±
±±³          ³               e podera ser utilizado em pesquisas futuras    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, PMSA200                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSSeekTree(oTree, cSearchText)
	If oTree == Nil
  	Return
  EndIf

  If PMSFindDlg(@cSearchText)
		If !PMSFindText(oTree, @cSearchText, .T., .F.)
			Aviso(STR0001, STR0002 + AllTrim(cSearchText) + "'", {"Ok"})  //"Procurar"###"Nao foi encontrada nenhuma ocorrencia para '"
		Else
			Eval(oTree:bChange)
		EndIf
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSFindDl³ Autor ³  Adriano Ueda          ³ Data ³ 02-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para pesquisa na arvore do projeto/orcamento, atraves ³±±
±±³          ³ da descricao da tarefa/EDT.                                  ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao apenas apresenta a caixa de dialogo para         ³±±
±±³          ³ pesquisa. A pesquisa e realmente realizada através da funcao ³±±
±±³          ³ PMSFindText.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSearchText - deve ser passada por referencia. esta variavel ³±±
±±³          ³               contera o valor digitado na caixa de dialogo e ³±±
±±³          ³               e podera ser utilizado em pesquisas futuras    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, PMSA200                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSFindDlg(cSearchText)
  Local oDlg := Nil
  Local lOk  := .F.

	Define MsDialog oDlg From 114, 150 To 180, 540 Title STR0003 Of oMainWnd Pixel //"Procurar texto"
		@ 005,  05 Say    STR0004 Of oDlg Pixel Size  35, 08 //"Procurar por:"
		@ 005,  45 MSGET  cSearchText     Of oDlg Pixel Size 145, 08

		@ 020, 110 Button STR0005 Size 35, 11 Font oDlg:oFont Action (lOk := .T., oDlg:End()) Of oDlg Pixel When !Empty(cSearchText) //"Procurar"
		@ 020, 150 Button STR0006 Size 35, 11 Font oDlg:oFont Action (lOk := .F., oDlg:End()) Of oDlg Pixel //"Cancelar"
	Activate Dialog oDlg Centered
Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSFindTex Autor ³  Adriano Ueda          ³ Data ³ 22-07-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para pesquisa de texto no Tree                        ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao recursiva faz a pesquisa de texto no objeto Tree,³±±
±±³          ³ atraves do arquivo de trabalho utilizado pelo Tree.          ³±±
±±³          ³                                                              ³±±
±±³          ³ EDTs abaixo da EDT atual sao calculadas atraves de uma       ³±±
±±³          ³ chamada recursiva                                            ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oTree       - Tree a ser pesquisada                          ³±±
±±³          ³ cFind       - texto a ser pesquisado                         ³±±
±±³          ³ lIgnoreCase - indica se o texto vai ser pesquisado utilizando³±±
±±³          ³               maiusculas ou minusculas:                      ³±±
±±³          ³               .T. - ignora maiusculas e minusculas           ³±±
±±³          ³               .F. - considera maiusculas e minusculas        ³±±
±±³          ³ lSkipCurrent - indica se o no atual do tree deve ser pulado  ³±±
±±³          ³                (se for .T., a procura comeca no proximo      ³±±
±±³          ³                 registro)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, PMSA200                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSFindText(oTree, cFind, lIgnoreCase, lSkipCurrent)
  Local cAlias := ""
  Local lRet := .F.
  Local lFound := .F.

  If oTree == Nil
  	Return lRet
  EndIf

	cAlias    := oTree:cArqTree

  dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(0))

	If lSkipCurrent
		(cAlias)->(dbSkip())
	EndIf

	While !(cAlias)->(Eof())
		If (Upper(AllTrim(cFind)) $ Upper((cAlias)->T_PROMPT) .And. lIgnoreCase) .Or.;
		   (AllTrim(cFind) $ (cAlias)->T_PROMPT .And. !lIgnoreCase)
			lFound := .T.
			Exit
		EndIf

		(cAlias)->(dbSkip())
	End

  If lFound
  	oTree:TreeSeek((cAlias)->T_CARGO)
		lRet := .T.
	EndIf

	//RestArea(aAreaTree)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSSeekNe³ Autor ³  Adriano Ueda          ³ Data ³ 22-07-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para pesquisa na arvore do projeto/orcamento, atraves ³±±
±±³          ³ da descricao da tarefa/EDT.                                  ³±±
±±³          ³                                                              ³±±
±±³          ³ Esta funcao apenas efetua a pesquisa a partir do proximo     ³±±
±±³          ³ pesquisa. A pesquisa e realmente realizada através da funcao ³±±
±±³          ³ PMSFindText.                                                 ³±±
±±³          ³                                                              ³±±
±±³          ³ O texto e pesquisado a partir da posicao corrente do Tree    ³±±
±±³          ³ ate o final do Tree.                                         ³±±
±±³          ³                                                              ³±±
±±³          ³ Se o texto e encontrado, o Tree e reposicionado para refletir³±±
±±³          ³ a posicao do texto.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oTree       - objeto Tree a ser pesquisado, deve ser diferen ³±±
±±³          ³               te de Nil.                                     ³±±
±±³          ³ cSearchText - texto a ser pesquisado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, PMSA200                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSSeekNext(oTree, cSearch)
	If oTree == Nil
		Return
	EndIf

	If Empty(cSearch)
		//PMSSeekTree(oTree, @cSearch)
		If !PMSFindDlg(@cSearch)
			Return
		End
	EndIf

	If !PMSFindText(oTree, cSearch, .T., .T.)
		Aviso(STR0001, STR0002 + AllTrim(cSearch) + "'", {"Ok"})  //"Procurar"###"Nao foi encontrada nenhuma ocorrencia para '"
	Else
		Eval(oTree:bChange)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSTRUNCA³ Autor ³ Daniel Sobreira        ³ Data ³ 09-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Truncamento ou Arredondamento dos Valores					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, PMSA200                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSTrunca(cTrunca, nValor, nCasasDec,nQuantTrf)
Local nValFin := 0
Local cPmsCust := SuperGetMv("MV_PMSCUST",.F.,"1") //Indica se utiliza o custo pela quantidade unitaria ou total

	If nQuantTrf <> Nil .And. cPmsCust <> "1"
		If cTrunca == "1"
			 // truncar
			nValFin := NoRound(nValor, nCasasDec)
		ElseIf cTrunca == "3"
			nValFin := NoRound(NoRound(nValor/nQuantTrf, nCasasDec)*nQuantTrf, nCasasDec)
		ElseIf cTrunca == "4"
			nValFin := Round(Round(nValor/nQuantTrf,nCasasDec)*nQuantTrf, nCasasDec)
		Else
			// arredondar
			nValFin := Round(nValor, nCasasDec)
		EndIf
	Else
		//
		// Truncar por Item ou Truncar por Tarefa
		If cTrunca $ "13"
			 // truncar
			nValFin := NoRound(nValor, nCasasDec)
		Else
			// arredondar
			nValFin := Round(nValor, nCasasDec)
		EndIf
	EndIf

Return nValFin


Function PmsOpenICS()
Local cTemp	   := CriaTrab(,.F.)+".ICS"
Local cDir 	   := GETTEMPPATH()
Local cArquivo := cDir+cTemp
Local nHandle

dbSelectArea("AF8")
dbSetOrder(1)
MsSeek(xFilial()+M->AF9_PROJET)

If empty(M->AF9_START) .or.  empty(M->AF9_HORAI) .or. empty(M->AF9_PROJET) .or. empty(M->AF9_TAREFA) .or. empty(M->AF9_DESCRI) .or. empty(AF8->AF8_DESCRI)
	Help( " ", 1, "PMSAUTOAF9",, STR0056, 1, 0 )
	Return
Endif


M->AF9_OBS := STRTRAN(M->AF9_OBS,Chr(13),"")
M->AF9_OBS := STRTRAN(M->AF9_OBS,Chr(10)," ")

nHandle := FCreate(cArquivo)

Sleep(1000)

fWrite(nHandle,"BEGIN:VCALENDAR"+CRLF)
fWrite(nHandle,"VERSION:2.0"+CRLF)
fWrite(nHandle,"BEGIN:VEVENT"+CRLF)
fWrite(nHandle,"DTSTART:"+dateToUTC(M->AF9_START, M->AF9_HORAI)+CRLF)
fWrite(nHandle,"DTEND:"+dateToUTC(M->AF9_FINISH, M->AF9_HORAF)+CRLF)
fWrite(nHandle,"UID:"+AllTrim(SM0->M0_CGC)+AllTrim(M->AF9_PROJET)+Alltrim(M->AF9_TAREFA)+CRLF)
fWrite(nHandle,"LOCATION;ENCODING=QUOTED-PRINTABLE:"+"Protheus 8 - SIGAPMS"+CRLF)
fWrite(nHandle,"DESCRIPTION;ENCODING=QUOTED-PRINTABLE:"+"Tarefa : "+AllTrim(M->AF9_TAREFA)+"-"+Alltrim(M->AF9_DESCRI) + " " + AllTrim(M->AF9_OBS) + CRLF )
fWrite(nHandle,"SUMMARY;ENCODING=QUOTED-PRINTABLE:"+STR0015+AllTrim(M->AF9_PROJET)+"-"+AllTrim(AF8->AF8_DESCRI)+STR0016+AllTrim(M->AF9_TAREFA)+"-"+Alltrim(M->AF9_DESCRI)+CRLF) //"Projeto : "###" Tarefa : "
fWrite(nHandle,"PRIORITY:3"+CRLF)
fWrite(nHandle,"END:VEVENT"+CRLF)
fWrite(nHandle,"END:VCALENDAR"+CRLF)
Sleep(1000)
fClose(nHandle)

Sleep(1000)

ShellExecute("open",cArquivo,"",cDir, 1 )

Return

Function dateToUTC(dDate, cTime)
Local nTime := Val(Substr(cTime,1,2))
// calculo necessario para acerto de fuso horario... outlook sempre converte o valor passado para GMT (-2 horas)
nTime += 2
cNewTime := StrZero(nTime,2)
cTime:= cNewTime+Substr(cTime,3)

Return cRet := StrZero(YEAR(dDate),4,0)+StrZero(Month(dDate),2,0)+StrZero(Day(dDate),2,0)+"T"+Substr(cTime,1,2)+Substr(cTime,4,2)+"00Z"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsDlgFS³ Autor ³ Daniel Sobreira         ³ Data ³ 25-11-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao cria uma janela para configuracao e apontamentos  ³±±
±±³          ³de Despesas Financeiras do Projeto na substituicao de titulos.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsDlgFS(nOpcao,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja,lGetDados)
Local bSavSetKey	:= SetKey(VK_F4,Nil)
Local bSavKeyF5     := SetKey(VK_F5,Nil)
Local bSavKeyF6     := SetKey(VK_F6,Nil)
Local bSavKeyF7     := SetKey(VK_F7,Nil)
Local bSavKeyF8     := SetKey(VK_F8,Nil)
Local bSavKeyF9     := SetKey(VK_F9,Nil)
Local bSavKeyF10    := SetKey(VK_F10,Nil)
Local oGetDados
Local ny
Local lOk
Local oDlg,oBold
Local nPosRat		:= aScan(aRatAFR,{|x| x[1] == "01"})

PRIVATE aCols	:= {}
PRIVATE aHeader	:= {}

DEFAULT lGetDados		:= .T.

If nOpcao == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("AFR")
	While !EOF() .And. (x3_arquivo == "AFR")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
	aHeaderAFR	:= aClone(aHeader)
	If nPosRat > 0
		aCols	:= aClone(aRatAFR[nPosRat][2])
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aCols,Array(Len(aHeader)+1))
		For ny := 1 to Len(aHeader)
			If Trim(aHeader[ny][2]) == "AFR_ITEM"
				aCols[1][ny] 	:= "01"
			Else
				aCols[1][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[1][Len(aHeader)+1] := .F.
		Next ny
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("AFR")
	While !EOF() .And. (x3_arquivo == "AFR")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
	aHeaderAFR	:= aClone(aHeader)
	dbSelectArea("AFR")
	dbSetOrder(1)
	If nPosRat == 0
		If ! lF050Auto // Carrega os apontamentos dos titulos originais
			dbSelectArea("__SUBS")
			dbGoTop()
			While !Eof()
				If __SUBS->E2_OK == cMarca
					dbSelectArea("AFR")
					dbSetOrder(2)
					If MsSeek(xFilial()+__SUBS->E2_PREFIXO+__SUBS->E2_NUM+__SUBS->E2_PARCELA+__SUBS->E2_TIPO+__SUBS->E2_FORNECE+__SUBS->E2_LOJA)
						While !Eof() .And. xFilial()+__SUBS->E2_PREFIXO+__SUBS->E2_NUM+__SUBS->E2_PARCELA+__SUBS->E2_TIPO+__SUBS->E2_FORNECE+__SUBS->E2_LOJA==;
											AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA
							If AFR->AFR_REVISA==PmsAF8Ver(AFR->AFR_PROJET)
								aADD(aCols,Array(Len(aHeader)+1))
								For ny := 1 to Len(aHeader)
									If ( aHeader[ny][10] != "V")
										aCols[Len(aCols)][ny] := FieldGet(ColumnPos(aHeader[ny][2]))
									Else
										aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
									EndIf
									aCols[Len(aCols)][Len(aHeader)+1] := .F.
								Next ny
							EndIf
							dbSkip()
						End
					EndIf
				Endif
				dbSelectArea("__SUBS")
				dbSkip()
			Enddo
		Else
			dbSelectArea("AFR")
			dbSetOrder(2)
			If MsSeek(xFilial()+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
				While !Eof() .And. xFilial()+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA==;
									AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA
					If AFR->AFR_REVISA==PmsAF8Ver(AFR->AFR_PROJET)
						aADD(aCols,Array(Len(aHeader)+1))
						For ny := 1 to Len(aHeader)
							If ( aHeader[ny][10] != "V")
								aCols[Len(aCols)][ny] := FieldGet(ColumnPos(aHeader[ny][2]))
							Else
								aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
							EndIf
							aCols[Len(aCols)][Len(aHeader)+1] := .F.
						Next ny
					EndIf
					dbSkip()
				End
			EndIf
		Endif
		If Empty(aCols)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a montagem de uma linha em branco no aCols.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aCols,Array(Len(aHeader)+1))
			For ny := 1 to Len(aHeader)
				If Trim(aHeader[ny][2]) == "AFR_ITEM"
					aCols[1][ny] 	:= "01"
				Else
					aCols[1][ny] := CriaVar(aHeader[ny][2])
				EndIf
				aCols[1][Len(aHeader)+1] := .F.
			Next ny
		EndIf
	Else
		aCols := aClone(aRatAFR[nPosRat][2])
	EndIf
EndIf

If lGetDados
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	DEFINE MSDIALOG oDlg FROM 88,22  TO 350,619 TITLE STR0009 Of oMainWnd PIXEL //'Assistente de Apontamentos : Gerenciamento de Projetos - Despesas'
		@ 16 ,3   TO 18 ,310 LABEL '' OF oDlg PIXEL
		@ 6,10 SAY STR0008+cPrefixo+"-"+cNum+cParcela SIZE 150,7 OF oDlg PIXEL //"Documento : "
		oGetDados := MSGetDados():New(23,3,112,296,nOpcao,'PMSAFRLOK','PMSAFRTOK','+AFR_ITEM',.T.,,,,100,'PMSAFRFOK')
		@ 118,249 BUTTON STR0007 SIZE 35 ,9   FONT oDlg:oFont ACTION {||If(oGetDados:TudoOk(),(lOk:=.T.,oDlg:End()),(lOk:=.F.))}  OF oDlg PIXEL  //'Confirma'
		@ 118,210 BUTTON STR0006 SIZE 35 ,9   FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'Cancelar'
      If ExistBlock("PMSFSSCR")
         ExecBlock("PMSFSSCR",.F.,.F.,{oDlg,nOpcao})
      Endif
	ACTIVATE MSDIALOG oDlg
EndIf

If nOpcao <> 2 .And. lOk
	If nPosRat > 0
		aRatAFR[nPosRat][2]	:= aClone(aCols)
	Else
		aADD(aRatAFR,{"01",aClone(aCols)})
	EndIf

	If ExistBlock("PMSDLGFS")
		U_PMSDLGFS(aCols,aHeader)
	EndIf
EndIf


SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsDlgRS³ Autor ³ Daniel Sobreira         ³ Data ³ 26-11-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao cria uma janela para configuracao e apontamentos  ³±±
±±³          ³de Receitas Financeiras do Projeto.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsDlgRS(nOpcao,cPrefixo,cNum,cParcela,cTipo,cCliente,cLoja)

Local bSavSetKey	:= SetKey(VK_F4,Nil)
Local bSavKeyF5     := SetKey(VK_F5,Nil)
Local bSavKeyF6     := SetKey(VK_F6,Nil)
Local bSavKeyF7     := SetKey(VK_F7,Nil)
Local bSavKeyF8     := SetKey(VK_F8,Nil)
Local bSavKeyF9     := SetKey(VK_F9,Nil)
Local bSavKeyF10    := SetKey(VK_F10,Nil)

Local ny
Local lOk
Local oDlg,oBold
Local nPosRat		:= aScan(aRatAFT,{|x| x[1] == "01"})
Local lGetDados		:= .T.

PRIVATE aCols	:= {}
PRIVATE aHeader	:= {}

If nOpcao == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("AFT")
	While !EOF() .And. (x3_arquivo == "AFT")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
	aHeaderAFT	:= aClone(aHeader)
	If nPosRat > 0
		aCols	:= aClone(aRatAFT[nPosRat][2])
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aCols,Array(Len(aHeader)+1))
		For ny := 1 to Len(aHeader)
			If Trim(aHeader[ny][2]) == "AFT_ITEM"
				aCols[1][ny] 	:= "01"
			Else
				aCols[1][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[1][Len(aHeader)+1] := .F.
		Next ny
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("AFT")
	While !EOF() .And. (x3_arquivo == "AFT")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
	aHeaderAFT	:= aClone(aHeader)
	dbSelectArea("AFT")
	dbSetOrder(1)
	If nPosRat == 0
		dbGotop()
		While !Eof()
			If AFT->AFT_REVISA==PmsAF8Ver(AFT->AFT_PROJET) .And. AFT_TIPO=="PR ";
				.And. xFilial()+cCliente+cLoja==AFT_FILIAL+AFT_CLIENT+AFT_LOJA
				SE1->(dbSetOrder(1))
				If SE1->(MsSeek(PmsFilial("SE1","AFT")+AFT->AFT_PREFIXO+AFT->AFT_NUM+AFT->AFT_PARCELA+AFT->AFT_TIPO));
					.And. SE1->E1_OK!="  " .And. SE1->(!Deleted())
					aADD(aCols,Array(Len(aHeader)+1))
					For ny := 1 to Len(aHeader)
						If ( aHeader[ny][10] != "V")
							aCols[Len(aCols)][ny] := FieldGet(ColumnPos(aHeader[ny][2]))
						Else
							aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
						EndIf
						aCols[Len(aCols)][Len(aHeader)+1] := .F.
					Next ny
				EndIf
			EndIf
			dbSkip()
		End
		If Empty(aCols)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a montagem de uma linha em branco no aCols.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aCols,Array(Len(aHeader)+1))
			For ny := 1 to Len(aHeader)
				If Trim(aHeader[ny][2]) == "AFT_ITEM"
					aCols[1][ny] 	:= "01"
				Else
					aCols[1][ny] := CriaVar(aHeader[ny][2])
				EndIf
				aCols[1][Len(aHeader)+1] := .F.
			Next ny
		EndIf
	Else
		aCols := aClone(aRatAFT[nPosRat][2])
	EndIf
EndIf

If lGetDados
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	DEFINE MSDIALOG oDlg FROM 88,22  TO 350,619 TITLE STR0010 Of oMainWnd PIXEL  //'Apontamentos : Gerenciamento de Projetos - Receitas'
		@ 16 ,3   TO 18 ,310 LABEL '' OF oDlg PIXEL
		@ 6,010 SAY STR0008+cPrefixo+"-"+cNum+cParcela SIZE 150,7 OF oDlg PIXEL //"Documento : "
		oGetDados := MSGetDados():New(23,3,112,296,nOpcao,'PMSAFTLOK','PMSAFTTOK','+AFT_ITEM',.T.,,,,100,'PMSAFTFOK')
		@ 118,249 BUTTON STR0007 SIZE 35 ,9   FONT oDlg:oFont ACTION {||If(oGetDados:TudoOk(),(lOk:=.T.,oDlg:End()),(lOk:=.F.))}  OF oDlg PIXEL  //'Confirma'
		@ 118,210 BUTTON STR0006 SIZE 35 ,9   FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'Cancelar'
      If ExistBlock("PMSRSSCR")
         ExecBlock("PMSRSSCR",.F.,.F.,{oDlg,nOpcao})
      Endif
	ACTIVATE MSDIALOG oDlg
EndIf

If nOpcao <> 2 .And. lOk
	If nPosRat > 0
		aRatAFT[nPosRat][2]	:= aClone(aCols)
	Else
		aADD(aRatAFT,{"01",aClone(aCols)})
	EndIf

	If ExistBlock("PMSDLGRC")
		ExecBlock("PMSDLGRC", .F., .F.)
	EndIf
EndIf

SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PMS103IPC ³ Autor ³Edson Maricate         ³ Data ³22/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Avalia se a mercadoria ira para o estoque ou requisitado    ³±±
±±³          ³automaticamente para o projeto. Era implementada através    ³±±
±±³          ³do ponto de entrada MT103IPC e incorporada ao padrão        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³n - Numero do item                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS103IPC(n,lPreNota)
Local aArea     := GetArea()
Local aAreaTmp  := {}
Local nPosItem  := 0
Local aSavCols  := aClone(aCols)
Local aSavHeader:= aClone(aHeader)
Local nPosRat   := 0
Local nPosPc    := 0
Local nPosItemPc:= 0
Local ny        := 0
Local nAcuAFN   := 0
Local cFilSC1   := xFilial("SC1")
Local cFilAFG   := xFilial("AFG")
Local lOk 		:= .T.
Local aAreaSC7  := {}//Nao recebe a area aqui, apenas se for rotina automatica (l103Auto == .T.)
Local aRetorno	:= {}
Local lRotAuto 	:= IIf(Type("l103Auto") <> "L", .F., l103Auto)
Local lMsFilAFG	:= AFG->(ColumnPos("AFG_MSFIL")) > 0
Local lExistAJ7	:= .F.

Default lPreNota := .F.

If lRotAuto
	nPosItem :=	aScan(aAutoItens[n], {|x| Alltrim(x[1]) == "D1_ITEM"})
	nPosRat  := aScan(aRatAFN, {|x| x[1] == aAutoItens[n][nPosItem][2]})
	nPosPc     := aScan(aAutoItens[n],{|x| AllTrim(x[1])=="D1_PEDIDO"})
	nPosItemPc := aScan(aAutoItens[n],{|x| AllTrim(x[1])=="D1_ITEMPC"})
Else
	nPosItem :=	aScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEM"})
	nPosRat := aScan(aRatAFN, {|x| x[1] == aCols[n][nPosItem]})
EndIf

If nPosRat == 0
	Iif(lRotAuto,aAdd(aRatAFN,{aAutoItens[n][nPosItem][2],{}}),aAdd(aRatAFN,{aCols[n][nPosItem],{}}))
	nPosRat := Len(aRatAFN)
Else
	aRatAFN[nPosRat][2] := {}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
FillGetDados(3,"AFN",1,,,,,,,,{||.T.},.T.,aHeader)

If lRotAuto .And. (nPosPc == 0 .Or. nPosItemPc == 0)
	lOk := .F.
EndIf

//Se estiver executando rotina automatica
//Posiciono o SC7
If lRotAuto .And. lOk
	dbSelectArea("SC7")
	aAreaSC7 := SC7->(GetArea())//Recebo a area do SC7 APENAS se for rotina automatica
	dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	If !dbSeek(xFilial("SC7") + aAutoItens[n][nPosPc][2] + aAutoItens[n][nPosItemPc][2])
		lOk := .F.
	EndIf
EndIf

If lOk //Se o SC7 nao estiver posicionado no PC correto quando for rotina automatica, aborto o preenchimento do aRatAFN
	//
	// Se registro posicionado da tabela SC7 - PEDIDO DE VENDA estiver com o campo
	// C7_NUMSC- Numero da solicitacao de compra preenchido
	//
	dbSelectArea("AJ7")
	dbSetOrder(2)
	If !Empty(SC7->C7_NUMSC) .And.;
			 (SC7->C7_TIPO == 1 .Or. !MsSeek(xFilial()+SC7->C7_NUM+SC7->C7_ITEM))	// Verifica se o tipo é 2 (autorização de entrega)
																					// e se a amarração ao PMS foi feita pela autorização de entrega
																					// Neste caso deve ir para o Else e verificar se existe amarração direto no pedido de compras
		// Se trata de um pedido de compra
		If SC7->C7_TIPO == 1
			//sem cotacao
			If Empty(SC7->C7_NUMCOT)
				// busca pelo numero e item da solicitacao de compra gravado no
				// item do pedido de compra na tabela de solicitacoes de compra
				
				If cPaisLoc == "MEX" .And. FindFunction("LxIntPMSPc")
					nPosRat := Iif(lRotAuto,aScan(aRatAFN,{|x| x[1] == aAutoItens[n][nPosItem][2]}),aScan(aRatAFN,{|x| x[1] == aCols[n][nPosItem]}))
					lExistAJ7 := LxIntPMSPc(SC7->C7_NUM, SC7->C7_ITEM, @aRatAFN, aHeader, nPosRat, lPreNota)
				EndIf
				
				dbSelectArea("SC1")
				dbSetOrder(1)//C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
								
				If !lExistAJ7 .And. MsSeek(cFilSC1 + SC7->C7_NUMSC + SC7->C7_ITEMSC)

					nPosRat := Iif(lRotAuto,aScan(aRatAFN,{|x| x[1] == aAutoItens[n][nPosItem][2]}),aScan(aRatAFN,{|x| x[1] == aCols[n][nPosItem]}))
					
					// Busca na amarracao da solicitacao de compra com a tarefa do projeto
					dbSelectArea("AFG")
					dbSetOrder(2) //AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC+AFG_PROJET+AFG_REVISA+AFG_TAREFA
					
					If DbSeek(xFilial("AFG") + SC1->C1_NUM + SC1->C1_ITEM)
						
						//Verifica se a origem da amarracao esta na Solicitacao de Compra
						While !Eof() .And. xFilial() + SC1->C1_NUM + SC1->C1_ITEM==;
							               AFG->(AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC)
							If AFG->AFG_REVISA==PmsAF8Ver(AFG->AFG_PROJET)
								If !lMsFilAFG .Or. (lMsFilAFG .And. AFG->AFG_MSFIL == cFilAnt)
									nAcuAFN := 0
									
									// Busca na amarracao do documento de entrada com a tarefa do projeto
									AFN->(dbSetOrder(3)) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD
									SD1->(dbSetOrder(1))
									AFN->(MsSeek(xFilial("AFN")+AFG->(AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_COD)))
									While AFN->(!Eof()) .AND. AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD) == ;
													   xFilial("AFN")+AFG->(AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_COD)
										// busca no documento de entrada o item que foi atrelado a tarefa do projeto pra obter
										// o numero e item da solicitacao de compra q foi gerado
										If SD1->(MsSeek(xFilial("SD1")+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM)))
											// se o item do documento de entrada foi gerado a partir do processo de solicitacao de
											// compra passando pelo pedido de compra.
											// Caso positivo, deve acumular as quantidades associadas a tarefa do projeto
											If (SD1->D1_PEDIDO == SC1->C1_PEDIDO .AND. SD1->D1_ITEMPC == SC1->C1_ITEMPED).And.!lPreNota
												nAcuAFN += AFN->AFN_QUANT
											EndIf

										EndIf
										dbSelectArea("AFN")
										dbSkip()
									EndDo

									// Se a quantidade lancado na amaracao de documento de entrada
									// com tarefa do projeto for menor que a quantidade amarrada ao pedido de compra,
									// deve incluir a amarracao com a diferenca
									If nAcuAFN < AFG->AFG_QUANT
										aADD(aRatAFN[nPosRat][2],Array(Len(aHeader)+1))
										For ny := 1 To Len(aHeader)
											Do Case
												Case Alltrim(aHeader[ny][2]) == "AFN_PROJET"
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_PROJET
												Case Alltrim(aHeader[ny][2]) == "AFN_TAREFA"
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_TAREFA
												Case Alltrim(aHeader[ny][2]) == "AFN_REVISA"
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_REVISA
												Case Alltrim(aHeader[ny][2]) == "AFN_QUANT"
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_QUANT - nAcuAFN
												Case Alltrim(aHeader[ny][2]) == "AFN_TRT"
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_TRT
												Case Alltrim(aHeader[ny][2]) == "AFN_ALI_WT"
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := "AFN"
												Case AllTrim(aHeader[ny,2]) == "AFN_REC_WT"
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := 0
												OtherWise
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := CriaVar(Alltrim(aHeader[ny][2]))
											EndCase
										Next ny
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][Len(aHeader)+1] := .F.
									EndIf
								EndIf
							EndIf
							dbSelectArea("AFG")
							dbSkip()
						EndDo
					//
					// Caso não encontre a amarracao da tarefa do projeto com o numero e item da solicitacao de compra,
					// provavelmente é uma solicitacao de armazem
					//	
					ElseIf !lExistAJ7
						//Verifica se a origem da amarracao esta na Solicitacao ao Armazem(Almoxarifado)
						//Verifica se a origem da amarracao esta na Solicitacao ao Armazem(Almoxarifado)
						aRetorno:= COMPosDHN({3,{'1',cFilSC1,SC1->C1_NUM,SC1->C1_ITEM}})
						If (aRetorno[1])
							While !(aRetorno[2])->(Eof())
								// se o numero e item da solicitacao armazem está amarrada
									// ao numero e item da solicitacao de compras
									If (aRetorno[2])->(DHN_DOCDES+DHN_ITDES) == SC1->(C1_NUM+C1_ITEM)
									
									// busca a tarefa do projeto que a solicitacao de armazem está amarrada.
									AFH->(DbSetOrder(2))
									AFH->(DbSeek(xFilial("AFH")+(aRetorno[2])->(DHN_DOCDES+DHN_ITDES)))
									While AFH->(!Eof()) .AND. AFH->(AFH_FILIAL+AFH_NUMSA+AFH_ITEMSA) == xFilial("AFH")+(aRetorno[2])->(DHN_DOCORI+DHN_ITORI)
										//DEVE PEGAR A ULTIMA REVISAO SEMPRE
										If AFH->AFH_REVISA==PmsAF8Ver(AFH->AFH_PROJET)

											aAreaTmp := SC1->(GetArea())
											// busca pelo numero e item da solicitacao de compra gravado no
											// item da solicitacao armazem,
											dbSelectArea("SC1")
											dbSetOrder(1)
											MsSeek(xFilial("SC1")+(aRetorno[2])->(DHN_DOCORI+DHN_ITORI))
											While SC1->(!Eof()) .AND. SC1->(C1_FILIAL+C1_NUM+C1_ITEM) == xFilial("SC1")+(aRetorno[2])->(DHN_DOCORI+DHN_ITORI)
												nAcuAFN := 0
												// Busca na amarracao do documento de entrada com a tarefa do projeto informada comparando
												// com a tarefa do projeto associada da solicitacao de armazem
												dbSelectArea("AFN")
												dbSetOrder(3) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD
												dbSeek(xFilial("AFN")+AFH->(AFH_PROJET+AFH_REVISA+AFH_TAREFA+AFH_COD))
												While !Eof() .AND. AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD) == ;
																xFilial("AFN")+AFH->(AFH_PROJET+AFH_REVISA+AFH_TAREFA+AFH_COD)
													// busca no documento de entrada o item que foi atrelado a tarefa do projeto
													// e acumula a quantidade utilizada
													dbSelectArea("SD1")
													dbSetOrder(1)
													If dbSeek(xFilial("SD1")+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM))
														// se o item do documento de entrada foi gerado pelo pedido de compra
														// Caso positivo, deve fazer a busca pela amarracao de tarefa de projeto
														If (SC1->C1_PEDIDO==SD1->D1_PEDIDO .AND. SC1->C1_ITEMPED==SD1->D1_ITEMPC).And.!lPreNota
															nAcuAFN += AFN->AFN_QUANT

														EndIf
													EndIf
													dbSelectArea("AFN")


													dbSkip()
												EndDo
												dbSelectArea("SC1")
												dbSkip()
											EndDo
											RestArea(aAreaTmp)

											// Se a quantidade lancado na amaracao de documento de entrada
											// com tarefa do projeto for menor que a quantidade amarrada a solicitacao de compra,
											// deve incluir a amarracao com a diferenca
											If nAcuAFN < AFH->AFH_QUANT
												aADD(aRatAFN[nPosRat][2],Array(Len(aHeader)+1))
												For ny := 1 To Len(aHeader)
													Do Case
														Case Alltrim(aHeader[ny][2]) == "AFN_PROJET"
															aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_PROJET
														Case Alltrim(aHeader[ny][2]) == "AFN_TAREFA"
															aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_TAREFA
														Case Alltrim(aHeader[ny][2]) == "AFN_REVISA"
															aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_REVISA
														Case Alltrim(aHeader[ny][2]) == "AFN_QUANT"
															aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_QUANT - nAcuAFN
														Case Alltrim(aHeader[ny][2]) == "AFN_ALI_WT"
															aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := "AFN"
														Case AllTrim(aHeader[ny,2]) == "AFN_REC_WT"
															aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := 0
														OtherWise
															aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := CriaVar(Alltrim(aHeader[ny][2]))
													EndCase
												Next ny
												aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][Len(aHeader)+1] := .F.
											EndIf
										EndIF
										AFH->(dbSkip())
									EndDo
									//
									// encerra a busca, pois não existe 2 numero/item de solicitacoes de armazem para um
									// numero/item da solicitacao de compra
									//
									Exit
								EndIf
								(aRetorno[2])->(dbSkip())
							EndDo
							(aRetorno[2])->(DbCloseArea())						
						EndIf
					EndIf
				EndIf
			// Com o campo SC7->C7_NUMCOT significa que se trata de um pedido de compra com cotacao.
			Else
				// tabela de cotacao, busca atraves do pedido de compra se tem cotacao
				dbSelectArea("SC8")
				dbSetOrder(3) //C8_FILIAL+C8_NUM+C8_PRODUTO+C8_FORNECE+C8_LOJA+C8_NUMPED+C8_ITEMPED
				If MsSeek(xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM)
					// se houver cotacao, busca a solicitacao de compra com cotacao
					dbSelectArea("SC1")
					dbSetOrder(5) //C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT
					MsSeek(cFilSC1+SC8->C8_NUM+SC8->C8_PRODUTO+SC8->C8_IDENT)
					While ( !Eof() .And. cFilSC1 == SC1->C1_FILIAL .And.;
									SC8->C8_NUM     == SC1->C1_COTACAO .And.;
									SC8->C8_PRODUTO == SC1->C1_PRODUTO .And.;
									SC8->C8_IDENT   == SC1->C1_IDENT )

	                    // busca na amarracao da tarefa do projeto com o pedide compra
						dbSelectArea("AFG")
						dbSetOrder(2) //AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC+AFG_PROJET+AFG_REVISA+AFG_TAREFA
						If DbSeek(cFilAFG+SC1->C1_NUM+SC1->C1_ITEM)
							nAcuAFN := 0
							//Verifica se a origem da amarracao esta na Solicitacao de Compra
							While !Eof() .And. cFilAFG+SC1->C1_NUM+SC1->C1_ITEM==;
								AFG->(AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC)
								If AFG->AFG_REVISA==PmsAF8Ver(AFG->AFG_PROJET)
									If !lMsFilAFG .Or. (lMsFilAFG .And. AFG->AFG_MSFIL == cFilAnt)
										// Busca na amarracao do documento de entrada com a tarefa do projeto
										dbSelectArea("AFN")
										dbSetOrder(3) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD
										dbSeek(xFilial("AFN")+AFG->(AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_COD))
										While !Eof() .AND. AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD) == ;
														   xFilial("AFN")+AFG->(AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_COD)
											// busca no documento de entrada o item que foi atrelado a tarefa do projeto pra obter
											// o numero e item da solicitacao de compra q foi gerado
											dbSelectArea("SD1")
											dbSetOrder(1)
											If dbSeek(xFilial("SD1")+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM))
												// se o item do documento de entrada foi gerado a partir do processo de solicitacao de
												// compra passando pelo pedido de compra.
												// Caso positivo, deve acumular as quantidades associadas a tarefa do projeto
												If (SD1->D1_PEDIDO == SC1->C1_PEDIDO .AND. SD1->D1_ITEMPC == SC1->C1_ITEMPED).And.!lPreNota
													nAcuAFN += AFN->AFN_QUANT
												EndIf

											EndIf
											dbSelectArea("AFN")
											dbSkip()
										EndDo

										// Se a quantidade lancado na amaracao de documento de entrada
										// com tarefa do projeto for menor que a quantidade amarrada a solicitacao de compra,
										// deve incluir a amarracao com a diferenca
										If nAcuAFN < AFG->AFG_QUANT
											aADD(aRatAFN[nPosRat][2],Array(Len(aHeader)+1))
											For ny := 1 To Len(aHeader)
												Do Case
													Case Alltrim(aHeader[ny][2]) == "AFN_PROJET"
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_PROJET
													Case Alltrim(aHeader[ny][2]) == "AFN_TAREFA"
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_TAREFA
													Case Alltrim(aHeader[ny][2]) == "AFN_REVISA"
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_REVISA
													Case Alltrim(aHeader[ny][2]) == "AFN_QUANT"
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_QUANT-nAcuAFN
													Case Alltrim(aHeader[ny][2]) == "AFN_TRT"
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFG->AFG_TRT
													Case Alltrim(aHeader[ny][2]) == "AFN_ALI_WT"
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := "AFN"
													Case AllTrim(aHeader[ny,2]) == "AFN_REC_WT"
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := 0
													OtherWise
														aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := CriaVar(Alltrim(aHeader[ny][2]))
												EndCase
											Next ny
											aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][Len(aHeader)+1] := .F.
										EndIf
									EndIf
								EndIf
								dbSelectArea("AFG")
								dbSkip()
							EndDo
						//
	                    // Caso contrario, pode ser uma solicitacao Armazem
	                    //
						Else
							nAcuAFN := 0
							//Verifica se a origem da amarracao esta na Solicitacao ao Armazem(Almoxarifado)
							aRetorno:= COMPosDHN({3,{'1',cFilSC1,SC1->C1_NUM,SC1->C1_ITEM}})
							If (aRetorno[1])
								While !(aRetorno[2])->(Eof()) 	
									// se o numero e item da solicitacao armazem está amarrada
									// ao numero e item da solicitacao de compras
									If (aRetorno[2])->(DHN_DOCDES+DHN_ITDES) == SC1->(C1_NUM+C1_ITEM)
										AFH->(DbSetOrder(2))
										AFH->(DbSeek(xFilial("AFH")+(aRetorno[2])->(DHN_DOCDES+DHN_ITDES)))
										While AFH->(!Eof()) .AND. AFH->(AFH_FILIAL+AFH_NUMSA+AFH_ITEMSA) == xFilial("AFH")+(aRetorno[2])->(DHN_DOCORI+DHN_ITORI)
											//DEVE PEGAR A ULTIMA REVISAO SEMPRE
											If AFH->AFH_REVISA==PmsAF8Ver(AFH->AFH_PROJET)
												aAreaTmp := SC1->(GetArea())
												// busca pelo numero e item da solicitacao de compra gravado no
												// item da solicitacao armazem,
												dbSelectArea("SC1")
												dbSetOrder(1)
												MsSeek(xFilial("SC1")+(aRetorno[2])->(DHN_DOCORI+DHN_ITORI))
												While SC1->(!Eof()) .AND. SC1->(C1_FILIAL+C1_NUM+C1_ITEM) == xFilial("SC1")+(aRetorno[2])->(DHN_DOCORI+DHN_ITORI)

													// Busca na amarracao do documento de entrada com a tarefa do projeto informada comparando
													// com a tarefa do projeto associada da solicitacao de armazem
													dbSelectArea("AFN")
													dbSetOrder(3) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD
													dbSeek(xFilial("AFN")+AFH->(AFH_PROJET+AFH_REVISA+AFH_TAREFA+AFH_COD))
													While !Eof() .AND. AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD) == ;
													                   xFilial("AFN")+AFH->(AFH_PROJET+AFH_REVISA+AFH_TAREFA+AFH_COD)
														// busca no documento de entrada o item que foi atrelado a tarefa do projeto
														// e acumula a quantidade utilizada
														dbSelectArea("SD1")
														dbSetOrder(1)
														If dbSeek(xFilial("SD1")+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM))
															// se o item do documento de entrada foi gerado pelo pedido de compra
															// Caso positivo, deve fazer a busca pela amarracao de tarefa de projeto
															If (SC1->C1_PEDIDO==SD1->D1_PEDIDO .AND. SC1->C1_ITEMPED==SD1->D1_ITEMPC).And.!lPreNota
																nAcuAFN += AFN->AFN_QUANT
															EndIf
														EndIf
														dbSelectArea("AFN")
														dbSkip()
													EndDo
													dbSelectArea("SC1")
													dbSkip()
												EndDo
												RestArea(aAreaTmp)
												// Se a quantidade lancado na amaracao de documento de entrada
												// com tarefa do projeto for menor que a quantidade amarrada a solicitacao de compra,
												// deve incluir a amarracao com a diferenca
											    If nAcuAFN < AFH->AFH_QUANT
													aADD(aRatAFN[nPosRat][2],Array(Len(aHeader)+1))
													For ny := 1 To Len(aHeader)
														Do Case
															Case Alltrim(aHeader[ny][2]) == "AFN_PROJET"
																aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_PROJET
															Case Alltrim(aHeader[ny][2]) == "AFN_TAREFA"
																aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_TAREFA
															Case Alltrim(aHeader[ny][2]) == "AFN_REVISA"
																aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_REVISA
															Case Alltrim(aHeader[ny][2]) == "AFN_QUANT"
																aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFH->AFH_QUANT-nAcuAFN
															Case Alltrim(aHeader[ny][2]) == "AFN_ALI_WT"
																aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := "AFN"
															Case AllTrim(aHeader[ny,2]) == "AFN_REC_WT"
																aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := 0
															OtherWise
																aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := CriaVar(Alltrim(aHeader[ny][2]))
														EndCase
													Next ny
													aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][Len(aHeader)+1] := .F.
		                                        EndIf
											EndIf
											AFH->(dbSkip())
										EndDo
									EndIf
									(aRetorno[2])->(dbSkip())
								EndDo
								(aRetorno[2])->(DbCloseArea())
							EndIf
						EndIf
						dbSelectArea("SC1")
						dbSkip()
					EndDo
				EndIf
			EndIf
		//
		// Caso contrario, é uma autorizacao de entrega feito atraves do pedido de compra
		//
		Else
			//
			// Busca pelo contrato de parceria que gerou o pedido de compras
			// Obs.: O numero e item do contrato de parceria é gravado no mesmo campo
			// que o numero e item da solicitacao de compra, o que difere entre eles é o campo SC7->C7_TIPO
			//
			dbSelectArea("SC3")
			dbSetOrder(1)
			If MsSeek(xFilial("SC3")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
				nPosRat := Iif(lRotAuto,aScan(aRatAFN,{|x| x[1] == aAutoItens[n][nPosItem][2]}),aScan(aRatAFN,{|x| x[1] == aCols[n][nPosItem]}))
				nAcuAFN:=0
				// Contrato de Parceria x projeto
				dbSelectArea("AFL")
				dbSetOrder(2)
				MsSeek(xFilial()+SC3->C3_NUM+SC3->C3_ITEM)
				While !Eof() .And. xFilial()+SC3->C3_NUM+SC3->C3_ITEM==;
					AFL->(AFL_FILIAL+AFL_NUMCP+AFL_ITEMCP)
					If AFL->AFL_REVISA==PmsAF8Ver(AFL->AFL_PROJET)

						// Busca na amarracao do documento de entrada com a tarefa do projeto
						dbSelectArea("AFN")
						dbSetOrder(3) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD
						dbSeek(xFilial("AFN")+AFL->(AFL_PROJET+AFL_REVISA+AFL_TAREFA+AFL_COD))
						While !Eof() .AND. AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD) == ;
						                   xFilial("AFN")+AFL->(AFL_PROJET+AFL_REVISA+AFL_TAREFA+AFL_COD)
							// busca no documento de entrada o item que foi atrelado a tarefa do projeto pra obter
							// o numero e item da solicitacao de compra q foi gerado
							dbSelectArea("SD1")
							dbSetOrder(1)
							If dbSeek(xFilial("SD1")+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM))

								aAreaTmp := SC7->(GetArea())
								// busca no pedido de compra o item que foi atrelado a tarefa do projeto pra obter
								// o numero e item do contrato de parceria q foi gerado
								dbSelectArea("SC7")
								dbSetOrder(1)
								If dbSeek(xFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC))
									// se o item do pedido de compra foi gerado a partir do contrato de parceria
									// Caso positivo, deve acumular as quantidades associadas a tarefa do projeto
									If (SC7->C7_NUMSC == AFL->AFL_NUMCP  .AND. SC7->C7_ITEMSC == AFL->AFL_ITEMCP).And.!lPreNota
										nAcuAFN += AFN->AFN_QUANT
									EndIf
								EndIf
								RestArea(aAreaTmp)

							EndIf
							dbSelectArea("AFN")
							dbSkip()
						EndDo

						// Se a quantidade lancado na amaracao de documento de entrada
						// com tarefa do projeto for menor que a quantidade amarrada a solicitacao de compra,
						// deve incluir a amarracao com a diferenca
					    If nAcuAFN < AFL->AFL_QUANT
							aADD(aRatAFN[nPosRat][2],Array(Len(aHeader)+1))
							For ny := 1 to Len(aHeader)
								Do Case
									Case Alltrim(aHeader[ny][2]) == "AFN_PROJET"
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFL->AFL_PROJET
									Case Alltrim(aHeader[ny][2]) == "AFN_TAREFA"
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFL->AFL_TAREFA
									Case Alltrim(aHeader[ny][2]) == "AFN_REVISA"
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFL->AFL_REVISA
									Case Alltrim(aHeader[ny][2]) == "AFN_QUANT"
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFL->AFL_QUANT-nAcuAFN
									Case Alltrim(aHeader[ny][2]) == "AFN_TRT"
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AFL->AFL_TRT
									Case Alltrim(aHeader[ny][2]) == "AFN_ALI_WT"
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := "AFN"
									Case AllTrim(aHeader[ny,2]) == "AFN_REC_WT"
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := 0
									OtherWise
										aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := CriaVar(Alltrim(aHeader[ny][2]))
								EndCase
							Next ny
							aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][Len(aHeader)+1] := .F.
						EndIf
					EndIf
					dbSelectArea("AFL")
					dbSkip()
				End
			EndIf
		EndIf

	//
	// Como o pedido de compra não foi originado a partir de uma Solicitacao de Compra ou Solicitacao ao Almoxarifado
	// deve verificar se existe amarração direta no pedido de compras
	//
	Else
		nPosRat := Iif(lRotAuto,aScan(aRatAFN,{|x| x[1] == aAutoItens[n][nPosItem][2]}),aScan(aRatAFN,{|x| x[1] == aCols[n][nPosItem]}))
		nAcuAFN := 0
		//item do pedido de compra amarrado a tarefa do projeto
		dbSelectArea("AJ7")
		dbSetOrder(2)
		MsSeek(xFilial()+SC7->C7_NUM+SC7->C7_ITEM)
		While !Eof() .And. xFilial()+SC7->C7_NUM+SC7->C7_ITEM==;
			               AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC
			If AJ7->AJ7_REVISA==PmsAF8Ver(AJ7->AJ7_PROJET)
				nAcuAFN := 0
				// Busca na amarracao do documento de entrada com a tarefa do projeto
				dbSelectArea("AFN")
				dbSetOrder(3) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD
				dbSeek(xFilial("AFN")+AJ7->(AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA+AJ7_COD))
				While !Eof() .AND. AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD) == ;
				                   xFilial("AFN")+AJ7->(AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA+AJ7_COD)
					// busca no documento de entrada o item que foi atrelado a tarefa do projeto
					// e acumula a quantidade utilizada
					dbSelectArea("SD1")
					dbSetOrder(1)
					If dbSeek(xFilial("SD1")+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM))
						// se o item do documento de entrada foi gerado pelo pedido de compra
						// Caso positivo, deve fazer a busca pela amarracao de tarefa de projeto
						If (AJ7->AJ7_NUMPC==SD1->D1_PEDIDO .AND. AJ7->AJ7_ITEMPC==SD1->D1_ITEMPC).And.!lPreNota
							nAcuAFN += AFN->AFN_QUANT
						EndIf
					EndIf
					dbSelectArea("AFN")
					dbSkip()
				EndDo

				// Se a quantidade lancado na amaracao de documento de entrada
				// com tarefa do projeto for menor que a quantidade amarrada ao pedido de compra,
				// deve incluir a amarracao com a diferenca
			    If nAcuAFN < AJ7->AJ7_QUANT
					aADD(aRatAFN[nPosRat][2],Array(Len(aHeader)+1))
					For nY := 1 to Len(aHeader)
						Do Case
							Case Alltrim(aHeader[ny][2]) == "AFN_PROJET"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AJ7->AJ7_PROJET
							Case Alltrim(aHeader[ny][2]) == "AFN_TAREFA"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AJ7->AJ7_TAREFA
							Case Alltrim(aHeader[ny][2]) == "AFN_REVISA"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AJ7->AJ7_REVISA
							Case Alltrim(aHeader[ny][2]) == "AFN_QUANT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AJ7->AJ7_QUANT - nAcuAFN
							Case Alltrim(aHeader[ny][2]) == "AFN_TRT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := AJ7->AJ7_TRT
							Case Alltrim(aHeader[ny][2]) == "AFN_ALI_WT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := "AFN"
							Case AllTrim(aHeader[ny,2]) == "AFN_REC_WT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := 0
							OtherWise
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][ny] := CriaVar(Alltrim(aHeader[ny][2]))
						EndCase
					Next nY
					aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][Len(aHeader)+1] := .F.
				EndIf

			EndIf
			dbSelectArea("AJ7")
			dbSkip()
		EndDo
	EndIf
EndIf

If Type("l103Class") <> "U" .AND. l103Class == .T.
	aRatAFN := {}
EndIf

aCols   := aClone(aSavCols)
aHeader := aClone(aSavHeader)

If lRotAuto .And. lOk
	RestArea(aAreaSC7)
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PMSTimeDif³ Autor ³Adriano Ueda           ³ Data ³29/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a diferença entre dois horários.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTimeFin  - horário final                                   ³±±
±±³          ³cTimeIni  - horário inicial (deve ser <= cTimeFin)          ³±±
±±³          ³nUnitDiff - 1 - retorna a diferença em horas                ³±±
±±³          ³          - 2 - retorna a diferença em minutos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³A diferença entre os horários cTimeFin e cTimeIni,          ³±±
±±³          ³arredondada para horas ou minutos (conforme o especificado  ³±±
±±³          ³por nUnitDiff).                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSTimeDiff(cTimeFin, cTimeIni, nUnitDiff)
	Local   aUnitDiff := {3600, 60} // diferenças em horas, minutos
	Default nUnitDiff := 1          // a diferença resultante é em horas

	// devolve a diferença das datas na unidade especificada
Return (TimeToSec(cTimeFin) - TimeToSec(cTimeIni)) / aUnitDiff[nUnitDiff]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TimeToSec ³ Autor ³Adriano Ueda           ³ Data ³29/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte um horário (string) em segundos (inteiro).         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTime     - horário em dos seguintes formatos:              ³±±
±±³          ³            HHHH:MM                                         ³±±
±±³          ³            HH:MM                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³O horário (cTime) quantificado em segundos.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TimeToSec(cTime)
	Local nHours   := 0  // horas
	Local nMinutes := 0  // minutos

	// converte de horas e minutos para valores numéricos
	If Len(cTime) > 5

		// formato "HHHH:MM"
		nHours   := Val(Substr(cTime, 1, 4))
		nMinutes := Val(Substr(cTime, 6, 2))
	Else

		// formato "HH:MM"
		nHours   := Val(Substr(cTime, 1, 2))
		nMinutes := Val(Substr(cTime, 4, 2))
	EndIf
Return (nHours * 3600)	+ (nMinutes * 60)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ToXlsForm³ Autor ³  Adriano Ueda          ³ Data ³ 19/05/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Função para formato um valor para exportar para um arquivo   ³±±
±±³          ³ .CSV                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ xValue - valor a ser formato                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ O valor formatado (em string) para a gravação no arquivo.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ToXlsFormat(xValue,cCampoSX3)
Local cComboSX3
Local aAreaSX3
Local aArea
Local nTamCpo
Local nPos
If cCampoSX3 <> Nil
	nPos := aScan(__aComboSX3,{|x| x[1] == cCampoSX3})
	If nPos > 0
		cComboSX3 := __aComboSX3[nPos,2]
		nTamCpo	 := __aComboSX3[nPos,3]
	Else
		aArea	:= GetArea()
		aAreaSX3:= SX3->(GetArea())
		dbSelectArea("SX3")
		dbSetOrder(2)
		If MsSeek(cCampoSX3)
			cComboSX3:= X3cBox()
			nTamCpo	:= SX3->X3_TAMANHO
			aAdd(__aComboSX3,{cCampoSX3,cComboSX3,nTamCpo})
		EndIf
		RestArea(aAreaSX3)
		RestArea(aArea)
	EndIf
EndIf

Do Case
	Case ValType(xValue) == "C"
		xValue := AllTrim(xValue)
		If cComboSX3<>Nil .And. !Empty(cComboSX3)
			aX3cBox	:= RetSx3Box(cComboSX3,Nil,Nil,nTamCpo)
			nPos := Ascan(aX3cBox,{|x| xValue $ x[2]})
			If nPos > 0
				xValue := aX3cBox[nPos][3]
			/*	xValue := StrTran(xValue, Chr(34), Chr(34) + Chr(34))
				xValue := AllTrim(xValue)
			Else
				xValue := StrTran(xValue, Chr(34), Chr(34) + Chr(34))
				xValue := Chr(34) + AllTrim(xValue) + Chr(34)*/
			EndIf
		EndIf
	Case ValType(xValue) == "N"
		If ( UPPER(AllTrim(GetSrvProfString("PictFormat", ""))) == "AMERICAN" .And. AllTrim(GetMV("MV_PAISLOC",,"BRA")) <>  "BRA" )
	    	xValue := AllTrim(Str(xValue))
	    Else
			xValue := Strtran(AllTrim(Str(xValue)),".",",")
		EndIf
	Case ValType(xValue) == "D"
		xValue := DToC(xValue)
	Case ValType(xValue) == "L"
		xValue := If(xValue, ".T.", ".F.")
	Case ValType(xValue) == "U"
		xValue := ""
	OtherWise
		xValue := ""
EndCase

	// dobra a quantidade de aspas existentes
	xValue := StrTran(xValue, Chr(34), Chr(34) + Chr(34))

	// adiciona as aspas como delimitador
	xValue := Chr(34) + xValue + Chr(34)

Return xValue

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³DlgToExcel³ Autor ³  Edson Maricate       ³ Data ³ 24/08/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Funcao que exporta os valores da tela para o Microsoft Excel  ³±±
±±³          ³no formato .CSV                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ Array contendo os objetos a serem exportados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Genérico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DlgToExcel(aExport)

Local aArea		 := GetArea()
Local cDirDocs  := MsDocPath()
Local cPath		  := AllTrim(GetTempPath())
Local ny			 := 0
Local nX        := 0
Local nz			 := 0
Local cBuffer   := ""
Local oExcelApp := Nil
Local nHandle   := 0
Local cArquivo  := CriaTrab(,.F.)
Local aCfgTab	:= {50}
Local aHeader	:= {}
Local aCols		:= {}
Local aGets     := {}
Local aTela     := {}
Local cAuxTxt
Local aParamBox	:= {}
LOcal aRet		:= {}
Local aList
Local cGetDb
Local cTabela
Local lRet	:=	.T.
Local lArqLocal := ExistBlock("DIRDOCLOC")
Local nPosPrd	:= 0

If !VerSenha(170)
	Help(" ",1,"SEMPERM")
	Return
Endif

If ExistBlock("DLGEXCEL")
   	lRet := ExecBlock("DLGEXCEL",.F.,.F.,aExport)
	If ValType(lRet) == "L" .And. !lRet
		Return
   	Endif
Endif

If Type("cCadastro") == "U"
	cCadastro := ""
EndIf


For nz := 1 to Len(aExport)
	cAuxTxt := If(nz==1,STR0035,"") //"Selecione os dados :"
	Do Case
		Case aExport[nz,1] == "CABECALHO"
			aCols	:= aExport[nz,4]
			If !Empty(aCols)
				If Empty(aExport[nz,2])
					aAdd(aParamBox,{4,cAuxTxt,.T.,STR0036,90,,.F.}) //"Cabecalho"
				Else
					aAdd(aParamBox,{4,cAuxTxt,.T.,AllTrim(aExport[nz,2]),90,,.F.})
				EndIf
			EndIf
		Case aExport[nz,1] == "ENCHOICE"
			If Empty(aExport[nz,2])
				aAdd(aParamBox,{4,cAuxTxt,.T.,STR0037,90,,.F.}) //"Campos"
			Else
				aAdd(aParamBox,{4,cAuxTxt,.T.,AllTrim(aExport[nz,2]),90,,.F.})
			EndIf
		Case aExport[nz,1] == "GETDADOS"
			aCols	:= aExport[nz,4]
			If !Empty(aCols)
				If Empty(aExport[nz,2])
					aAdd(aParamBox,{4,cAuxTxt,.T.,STR0038,90,,.F.}) //"Lista de Itens"
				Else
					aAdd(aParamBox,{4,cAuxTxt,.T.,AllTrim(aExport[nz,2]),90,,.F.})
				EndIf
			EndIf
		Case aExport[nz,1] == "ARRAY"
			aList		:= aExport[nz,4]
			If !Empty(aList)
				If Empty(aExport[nz,2])
					aAdd(aParamBox,{4,cAuxTxt,.T.,STR0039,90,,.F.}) //"Detalhes"
				Else
					aAdd(aParamBox,{4,cAuxTxt,.T.,AllTrim(aExport[nz,2]),90,,.F.})
				EndIf
			EndIf
		Case aExport[nz,1] == "GETDB"
			If Empty(aExport[nz,2])
				aAdd(aParamBox,{4,cAuxTxt,.T.,STR0040,90,,.F.}) // "Lista de Itens"
			Else
				aAdd(aParamBox,{4,cAuxTxt,.T.,AllTrim(aExport[nz,2]),90,,.F.})
			EndIf
		Case aExport[nz,1] == "TABELA"
			If Empty(aExport[nz,2])
				aAdd(aParamBox,{4,cAuxTxt,.T.,STR0040,90,,.F.}) // "Lista de Itens"
			Else
				aAdd(aParamBox,{4,cAuxTxt,.T.,AllTrim(aExport[nz,2]),90,,.F.})
			EndIf
	EndCase
Next nz

SAVEINTER()

If Len(aExport)==1 .Or. ParamBox(aParamBox,STR0041,aRet,,,,,,,,.F.)  //"Exportar para MS-Excel"
	// gera o arquivo em formato .CSV
	cArquivo += ".CSV"

	If lArqLocal
		nHandle := FCreate(cPath + "\" + cArquivo)
	Else
		nHandle := FCreate(cDirDocs + "\" + cArquivo)
	Endif

	If nHandle == -1
		MsgStop(STR0014) //"Erro na criacao do arquivo na estacao local. Contate o administrador do sistema"
		RESTINTER()
		Return
	EndIf

	For nz := 1 to Len(aExport)
		If Len(aExport)>1 .And. !aRet[nz]
			Loop
		EndIf
		Do Case
			Case aExport[nz,1] == "CABECALHO"
				cBuffer := AllTrim(cCadastro)
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				FWrite(nHandle, CRLF)
				cBuffer	:= ""
				aHeader	:= aExport[nz,3]
				aCols	:= aExport[nz,4]
				If !Empty(aCols)
					cBuffer := AllTrim(aExport[nz,2]	)
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					FWrite(nHandle, CRLF)
					cBuffer	:= ""
					For nx := 1 To Len(aHeader)
						If nx == Len(aHeader)
							cBuffer += ToXlsFormat(aHeader[nx])
						Else
							cBuffer += ToXlsFormat(aHeader[nx]) + ";"
						EndIf
					Next nx
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					cBuffer	:= ""
					For nx := 1 To Len(aCols)
						If nx == Len(aCols)
							cBuffer += ToXlsFormat(aCols[nx])
						Else
							cBuffer += ToXlsFormat(aCols[nx]) + ";"
						EndIf
					Next nx
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					FWrite(nHandle, CRLF)
				EndIf
			Case aExport[nz,1] == "ENCHOICE"
				cBuffer := AllTrim(cCadastro)
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				FWrite(nHandle, CRLF)
				cBuffer := AllTrim(aExport[nz,2]	)
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				FWrite(nHandle, CRLF)
				cBuffer	:= ""
				aGets := aExport[nz,3]
				aTela := aExport[nz,3]
				For nx := 1 to Len(aGets)
					dbSelectArea("SX3")
					dbSetOrder(2)
					dbSeek(Substr(aGets[nx],9,10))
					If nx == Len(aGets)
						cBuffer += ToXlsFormat(Alltrim(X3TITULO()))
					Else
						cBuffer += ToXlsFormat(Alltrim(X3TITULO())) + ";"
					EndIf
				Next nx
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				cBuffer := ""
				For nx := 1 to Len(aGets)
					If nx == Len(aGets)
						cBuffer += ToXlsFormat(  &("M->"+AllTrim(Substr(aGets[nx],9,10))), Substr(aGets[nx],9,10) )
					Else
						cBuffer += ToXlsFormat( &("M->"+AllTrim(Substr(aGets[nx],9,10))) ,Substr(aGets[nx],9,10) ) + ";"
					EndIf
				Next nx
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				FWrite(nHandle, CRLF)
				cBuffer := ""
			Case aExport[nz,1] == "GETDADOS"
				cBuffer	:= ""
				aHeader	:= aExport[nz,3]
				aCols		:= aExport[nz,4]
				nPosPrd := aScan(aHeader, {|x| Alltrim(x[2]) $ "C1_PRODUTO*C7_PRODUTO"})
				If !Empty(aCols)
					cBuffer := AllTrim(aExport[nz,2]	)
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					FWrite(nHandle, CRLF)
					cBuffer	:= ""
					For nx := 1 To Len(aHeader)
						If nx == Len(aHeader)
							cBuffer += ToXlsFormat(Alltrim(aHeader[nx,1]))
						Else
							cBuffer += ToXlsFormat(Alltrim(aHeader[nx,1])) + ";"
						EndIf
					Next nx
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					cBuffer := ""
					For nx := 1 to Len(aCols)
						If Valtype(aCols[nx][Len(aCols[nx])]) # "L" .Or. (Valtype(aCols[nx][Len(aCols[nx])]) == "L" .And. !aCols[nx][Len(aCols[nx])])
							For ny := 1 to Len(aCols[nx])-1
								If ny == Len(aCols[nx])-1
									cBuffer += ToXlsFormat(aCols[nx,ny],aHeader[ny,2])
								ElseIf nPosPrd > 0 .And. ny == nPosPrd
									cBuffer += "=" + ToXlsFormat(aCols[nx,ny],aHeader[ny,2]) + ";"
								Else
									cBuffer += ToXlsFormat(aCols[nx,ny],aHeader[ny,2]) + ";"
								EndIf
							Next ny
							FWrite(nHandle, cBuffer)
							FWrite(nHandle, CRLF)
							cBuffer := ""
						EndIf
					Next nx
					FWrite(nHandle, CRLF)
				EndIf
			Case aExport[nz,1] == "ARRAY"
				cBuffer := AllTrim(cCadastro)
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				FWrite(nHandle, CRLF)
				cBuffer	:= ""
				aHeader	:= aExport[nz,3]
				aList		:= aExport[nz,4]
				If !Empty(aList)
					cBuffer := AllTrim(aExport[nz,2]	)
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					FWrite(nHandle, CRLF)
					cBuffer	:= ""
					For nx := 1 To Len(aHeader)
						If nx == Len(aHeader)
							cBuffer += ToXlsFormat(Alltrim(aHeader[nx]))
						Else
							cBuffer += ToXlsFormat(Alltrim(aHeader[nx])) + ";"
						EndIf
					Next nx
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					cBuffer := ""
					For nx := 1 to Len(aList)
						For ny := 1 to Len(aList[nx])
							If ny == Len(aList[nx])
								cBuffer += ToXlsFormat(aList[nx,ny])
							Else
								cBuffer += ToXlsFormat(aList[nx,ny]) + ";"
							EndIf
						Next ny
						FWrite(nHandle, cBuffer)
						FWrite(nHandle, CRLF)
						cBuffer := ""
					Next nx
					FWrite(nHandle, CRLF)
				EndIf
			Case aExport[nz,1] == "GETDB"
				cBuffer	:= ""
				aHeader	:= aExport[nz,3]
	         cGetDb	:= aExport[nz,4]
				cBuffer := AllTrim(aExport[nz,2]	)
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				FWrite(nHandle, CRLF)
				cBuffer	:= ""
				For nx := 1 To Len(aHeader)
					If nx == Len(aHeader)
						cBuffer += ToXlsFormat(Alltrim(aHeader[nx,1]))
					Else
						cBuffer += ToXlsFormat(Alltrim(aHeader[nx,1])) + ";"
					EndIf
				Next nx
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				cBuffer := ""
				dbSelectArea(cGetDb)
				aAuxArea	:= GetArea()
				dbGotop()
				While !Eof()
					For nx := 1 to Len(aHeader)
						If nx == Len(aHeader)
							cBuffer += ToXlsFormat(FieldGet(ColumnPos(AllTrim(aHeader[nx,2]))),AllTrim(aHeader[nx,2]))
						Else
							cBuffer += ToXlsFormat(FieldGet(ColumnPos(AllTrim(aHeader[nx,2]))),AllTrim(aHeader[nx,2]))+";"
						EndIf
					Next
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					cBuffer := ""
					dbSkip()
				End
				FWrite(nHandle, CRLF)
				RestArea(aAuxArea)
			Case aExport[nz,1] == "TABELA"
				if !ParamBox( { { 1,STR0051 ,50,"@E 99999" 	 ,""  ,""    ,"" ,30 ,.T. } }, STR0052, aCfgTab ,,,,,,,,.F.)
					RESTINTER()
					Return
				endif
				cBuffer	:= ""
				aHeader	:= aExport[nz,3]
	         cTabela	:= aExport[nz,4]
				cBuffer := AllTrim(aExport[nz,2]	)
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				FWrite(nHandle, CRLF)
				cBuffer	:= ""
				For nx := 1 To Len(aHeader)
				//	If aHeader[nx,3]
						If nx == Len(aHeader)
							cBuffer += ToXlsFormat(Alltrim(aHeader[nx,1]))
						Else
							cBuffer += ToXlsFormat(Alltrim(aHeader[nx,1])) + ";"
						EndIf
				//	EndIf
				Next nx
				FWrite(nHandle, cBuffer)
				FWrite(nHandle, CRLF)
				cBuffer := ""
				dbSelectArea(cTabela)
				aAuxArea	:= GetArea()
				While !Eof() .And. aCfgTab[1] > 0
					For nx := 1 to Len(aHeader)
					//	If aHeader[nx,3]
							If nx == Len(aHeader)
								cBuffer += ToXlsFormat(FieldGet(ColumnPos(AllTrim(aHeader[nx,2]))),AllTrim(aHeader[nx,2]))
							Else
								cBuffer += ToXlsFormat(FieldGet(ColumnPos(AllTrim(aHeader[nx,2]))),AllTrim(aHeader[nx,2]))+";"
							EndIf
				   //	EndIf
					Next
					FWrite(nHandle, cBuffer)
					FWrite(nHandle, CRLF)
					cBuffer := ""
					dbSkip()
					aCfgTab[1]--
				End
				FWrite(nHandle, CRLF)
				RestArea(aAuxArea)
		EndCase
	Next nz

	FClose(nHandle)

	// copia o arquivo do servidor para o remote
	If !lArqLocal
		CpyS2T(cDirDocs + "\" + cArquivo, cPath, .T.)
	Endif

	If ApOleClient("MsExcel")
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cPath + "\" + cArquivo)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	Else
		MsgStop(STR0013 + CRLF + "("+cPath+"\"+cArquivo+")") //"Microsoft Excel nao instalado."
	EndIf

EndIf

RESTINTER()

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³AddToExcel³ Autor ³  Edson Maricate       ³ Data ³ 24/08/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Adiciona o botao de exportação das informações da tela para   ³±±
±±³          ³Microsoft Excel                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ Array contendo os objetos a serem exportados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Genérico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AddToExcel(aButtons,aExport)
Local nRemoteType:=RemoteType()
Default aButtons := {}
If nRemoteType == 1
	aAdd(aButtons,{PmsBExcel()[1],{|| DlgToExcel(aExport)},PmsBExcel()[2],PmsBExcel()[3]})
EndIf
Return aButtons

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³PMSBExcel ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 08/09/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Retorna todas as informacoes para o botao de exportacao para  ³±±
±±³          ³Microsoft Excel                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ Nennhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com os dados para botao de esportacao para EXCEL       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsBExcel()
LOCAL aTexto:={BMP_EXCEL,STR0011,STR0012} //"Exportar os dados da tela para o Microsoft Excel"###"Exp.Excel"
RETURN aTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³RemoteType³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 08/09/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Retorna o tipo de remote para identificar se pode utilizar    ³±±
±±³          ³API do WINDOWS                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ Nennhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Valor numerico com tipo de remote                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RemoteType()
Static nRemoteType := NIL
If nRemoteType == NIL
	nRemoteType := GetRemoteType()
EndIf
RETURN nRemoteType


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsDlgPC³ Autor ³ Edson Maricate          ³ Data ³ 22-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao cria uma janela para configuracao e utilizacao    ³±±
±±³          ³do Pedido de Compras a um dterminado projeto.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA120,SIGAPMS                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsDlgPC(nOpcao,cNumPC,aRatAuto)

Local lOk
Local oDlg
Local nPosPerc    := 0
Local nPosItem    := aScan(aHeader,{|x| Alltrim(x[2]) == "C7_ITEM"})
Local cItemPC     := aCols[n][nPosItem]
Local cNumSC      := aCols[n][aScan(aHeader,{|x| Alltrim(x[2]) == "C7_NUMSC"})]
Local cItemSC     := aCols[n][aScan(aHeader,{|x| Alltrim(x[2]) == "C7_ITEMSC"})]
Local nQuantPC    := aCols[n][aScan(aHeader,{|x| Alltrim(x[2]) == "C7_QUANT"})]
Local nVlrTotal   := aCols[n][aScan(aHeader,{|x| Alltrim(x[2]) == "C7_TOTAL"})]
Local nPosProj    :=	aScan(aHeader,{|x| Alltrim(x[2]) == "C7_PROJET"})
Local nPosVersao  :=	aScan(aHeader,{|x| Alltrim(x[2]) == "C7_REVISA"})
Local nPosTaref   :=	aScan(aHeader,{|x| Alltrim(x[2]) == "C7_TAREFA"})
Local nPosTrt     :=	aScan(aHeader,{|x| Alltrim(x[2]) == "C7_TRT"})
Local nPosRat     := aScan(aRatAJ7,{|x| x[1] == aCols[n][nPosItem]})
Local aSavCols    := {}
Local aSavHeader  := {}
Local nSavN       := 1
Local lGetDados   := .T.
Local oGetDados   := Nil
Local nY          := 0
Local nOpcMsg     := 0
Local cScOk       := "OK"
Local cNumSA      := ""
Local cFilSC1	  := xFilial("SC1")
Local lPmsAj7Cols := ExistBlock("PMSAJ7COLS")
Local aAlter      := {"AJ7_PROJET","AJ7_TAREFA", "AJ7_QUANT", "AJ7_QTSEGU" }
Local aRetorno	  := {}
Local lPmsAj7Cpo  := Existblock("PmsAj7Cpo")
Local lRet        := .T.
Local lAuto       := aRatAuto <> NIL .and. ValType(aRatAuto) = 'A'
Local nX          := 0
Local aArea       := GetArea()
Local aAreaSC7    := SC7->(GetArea())

Local bSavKeyF4   := SetKey(VK_F4 ,Nil)
Local bSavKeyF5   := SetKey(VK_F5 ,Nil)
Local bSavKeyF9   := SetKey(VK_F9 ,Nil)

Default aRatAuto := {}

//Verifica se o PC teve origem de uma Solicitacao de Compra
If !Empty(cNumSC) .And. !Empty(cItemSC)
	dbSelectArea("AFG")
	dbSetOrder(2)
	If MsSeek(xFilial("AFG")+cNumSC+cItemSC) .and. nTipoPed == 1 // 1 = Pedido ; 2 = Aut. Entrega.
		cScOk := "ORIGEM_SC"
	Else
		//Verifica se a SC teve origem de uma Solicitacao de Armazem
		aRetorno:= COMPosDHN({3,{'1',cFilSC1,cNumSC,cItemSC}})
		If (aRetorno[1])
			While cScOk=="OK" .And. !(aRetorno[2])->(Eof()) 
				If (aRetorno[2])->DHN_DOCDES + (aRetorno[2])->DHN_ITDES == cNumSC+cItemSC
					cScOk  := "ORIGEM_SA"
					cNumSA := (aRetorno[2])->DHN_DOCORI
				EndIf
				(aRetorno[2])->(dbSkip())
			EndDo
			(aRetorno[2])->(DbCloseArea())
		EndIf
	EndIf
EndIf

//Verifica se o Contrato que está amarrado a AE, se ja esta amarrado ao PMS
If !Empty(cNumSC) .And. !Empty(cItemSC) .And. cScOk=="OK"
	dbSelectArea("AFL")
	dbSetOrder(2)
	If MsSeek(xFilial()+cNumSC+cItemSC)
		cScOk := "ORIGEM_CP"
	EndIf
EndIf

// Salva ambiente da rotina de pedido de compra
aSavCols   := aClone(aCols)
aSavHeader := aClone(aHeader)
nSavN      := n

n       := 1
aCols   := {}
aHeader := {}

If cScOk =="OK"
	nQtMaxSC:= nQuantPC

	If nOpcao == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("AJ7")
		While !EOF() .And. (x3_arquivo == "AJ7")
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal, x3_valid,;
					x3_usado, x3_tipo, x3_arquivo,x3_context } )
			Endif
			If AllTrim(x3_campo) == "AJ7_QUANT"
				nPosPerc	:= Len(aHeader)
			EndIf
			dbSkip()
		EndDo
		aHeaderAJ7	:= aClone(aHeader)
		If nPosRat > 0
			aCols	:= aClone(aRatAJ7[nPosRat][2])
			If Len(aCols) == 1
				aCols[1][Len(aHeader)+1] := .F.
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a montagem de uma linha em branco no aCols.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aCols,Array(Len(aHeader)+1))
			For ny := 1 to Len(aHeader)
				If Trim(aHeader[ny][2]) == "AJ7_ITEM"
					aCols[1][ny] 	:= "01"
				Else
					aCols[1][ny] := CriaVar(aHeader[ny][2])
				EndIf
				aCols[1][Len(aHeader)+1] := .F.
			Next ny
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("AJ7")
		While !EOF() .And. (x3_arquivo == "AJ7")
			IF X3USO(x3_usado) .And. cNivel >= x3_nivel
				AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal, x3_valid,;
					x3_usado, x3_tipo, x3_arquivo,x3_context } )
			Endif
			If AllTrim(x3_campo) == "AJ7_QUANT"
				nPosPerc	:= Len(aHeader)
			EndIf
			dbSkip()
		End
		aHeaderAJ7	:= aClone(aHeader)
		dbSelectArea("AJ7")
		dbSetOrder(2)
		If nPosRat == 0
			If MsSeek(xFilial()+cNumPC+cITEMPC)
				While !Eof() .And. xFilial()+cNumPC+cITEMPC==;
						AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC
					If AJ7->AJ7_REVISA==PmsAF8Ver(AJ7->AJ7_PROJET)
						aADD(aCols,Array(Len(aHeader)+1))
						For ny := 1 to Len(aHeader)
							If ( aHeader[ny][10] != "V")
								aCols[Len(aCols)][ny] := FieldGet(ColumnPos(aHeader[ny][2]))
							Else
								aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
							EndIf
							aCols[Len(aCols)][Len(aHeader)+1] := .F.
						Next ny
					EndIf
					dbSkip()
				End
			EndIf
			If Empty(aCols)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a montagem de uma linha em branco no aCols.              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aCols,Array(Len(aHeader)+1))
				For ny := 1 to Len(aHeader)
					If Trim(aHeader[ny][2]) == "AJ7_ITEM"
						aCols[1][ny] 	:= "01"
					Else
						aCols[1][ny] := CriaVar(aHeader[ny][2])
					EndIf
					aCols[1][Len(aHeader)+1] := .F.
				Next ny
			EndIf
		Else
			aCols := aClone(aRatAJ7[nPosRat][2])
		EndIf
	EndIf

	If lPmsAj7Cols
		aUserCols := Execblock("PMSAJ7COLS", .F.,.F.,{cItemPC,cNumSC,cItemSC,nQuantPC,nVlrTotal,aHeader,aCols})
		If ValType(aUserCols) == "A"
			aCols := aClone(aUserCols)
		Endif
	Endif

	If lPmsAj7Cpo
		aAlter := aClone(Execblock("PmsAj7Cpo", .F.,.F.,{aAlter,aHeader,aCols}))
	Endif
	If lAuto
		// Compatibiliza array aheader com a funcao de campo PMSAJ7FOK
		For nX := 1 to Len(aRatAuto)
			For nY := 1 to Len(aRatAuto[nX])
				If ( aRatAuto[nX][nY][3] == Nil )
					nPos := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim(aRatAuto[nX][nY][1]) })
					If nPos > 0
						aRatAuto[nX][nY][3] := aHeader[nPos][6]
					EndIf
					If Empty(aRatAuto[nX][nY][3])
						aRatAuto[nX][nY][3] := "PMSAJ7FOK() "
					Else
						aRatAuto[nX][nY][3] += " .And. PMSAJ7FOK() "
					EndIf
				EndIf
			Next nY
		Next nX

		If !AJ7->(MsGetDAuto(aRatAuto,"PMSAJ7LOK()",{|| PMSAJ7TOK()},,nOpcao))
			lOk  := .F.
			lRet := .F.
		Else
			lOk  := .T.
			lRet := .T.
		endif
	else
		If lGetDados
			DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
			DEFINE MSDIALOG oDlg FROM 88 ,22  TO 350,619 TITLE STR0017 Of oMainWnd PIXEL //"Gerenciamento de Projetos - PC"
			oGetDados := MSGetDados():New(23,3,112,296,nOpcao,'PMSAJ7LOK','PMSAJ7TOK','+AJ7_ITEM',.T.,aAlter,,,100,'PMSAJ7FOK')
			@ 16 ,3   TO 18 ,310 LABEL '' OF oDlg PIXEL
			@ 6  ,10   SAY STR0018 Of oDlg PIXEL SIZE 27 ,9   //"Num. PC"
			@ 5  ,35  SAY  cNumPC+"/"+cITEMPC Of oDlg PIXEL SIZE 40,9 FONT oBold
			@ 6  ,190 SAY STR0019 Of oDlg PIXEL SIZE 30 ,9   //"Quantidade"
			@ 5  ,230 MSGET nQuantPC Picture "@E 999,999,999.99" When .F. PIXEL SIZE 65,9
			@ 118,249 BUTTON STR0148 SIZE 35 ,9   FONT oDlg:oFont ACTION {||If(oGetDados:TudoOk(),(lOk:=.T.,oDlg:End()),(lOk:=.F.))}  OF oDlg PIXEL //'Confirma'
			@ 118,210 BUTTON STR0149 SIZE 35 ,9   FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL //'Cancelar'
			If ExistBlock("PMSPCSCR")
				ExecBlock("PMSPCSCR",.F.,.F.,{oDlg,nOpcao})
			Endif
			ACTIVATE MSDIALOG oDlg
		EndIf
	EndIf
	If nOpcao <> 2 .And. lOk
		If nPosRat > 0
			aRatAJ7[nPosRat][2]	:= aClone(aCols)
		Else
			aADD(aRatAJ7,{aSavCols[nSavN][nPosItem],aClone(aCols)})
		EndIf

		If ExistBlock("PMSDLGPC")
			U_PMSDLGPC(aCols,aHeader,aSavCols,aSavHeader,nSavN)
		EndIf
	EndIf

	If lOk
		If nPosProj>0 .And. nPosVersao>0 .And. nPosTaref>0
			aSavCols[n][nPosProj]:=SPACE(TAMSX3("C7_PROJET")[1])
			aSavCols[n][nPosVersao]:=SPACE(TAMSX3("C7_REVISA")[1])
			aSavCols[n][nPosTaref]:=SPACE(TAMSX3("C7_TAREFA")[1])
		EndIf

		If nPosTrt>0
			aSavCols[n][nPosTrt]:=	SPACE(TAMSX3("C7_TRT")[1])
		EndIf
	EndIf
Else
	If lauto
		lRet := .F.
		Help( " ", 1, "PMSAUTOPC",, STR0021, 1, 0 )//"Este item do pedido de compras esta relacionado a uma solicitção de compras amarrado a um projeto/tarefa e não poderá ser alterada. Utilize a rotina de manutenção de solicitações de compras ou verifique o item selecionado"
	ElseIf cScOk == "ORIGEM_SC"
		If !isBlind()
			nOpcMsg := Aviso(STR0020,STR0021,If(nOpcao<>1,{STR0022,STR0053},{STR0022}),2)//"Atenção!"##"Este item do pedido de compras esta relacionado a uma solicitção de compras amarrado a um projeto/tarefa e não poderá ser alterada. Utilize a rotina de manutenção de solicitações de compras ou verifique o item selecionado"##"Fechar"##"Tabela de Dados"##"Fechar"
		Else
			nOpcMsg := 1
		EndIf

		If nOpcMsg == 2		// Visualiza SC
			MaViewSC(cNumSC)
		EndIf
	ElseIf cScOk == "ORIGEM_SA"
		If !isBlind()
			nOpcMsg := Aviso(STR0020,STR0054,If(nOpcao<>1,{STR0022,STR0055},{STR0022}),2)//"Atenção!"##"Este item do pedido de compras esta relacionado a Solicitação de Compras que está relacionado a uma Solicitação ao Armazém e não poderá ser alterada. Utilize a rotina de manutenção de solicitações ao armazém ou verifique o item selecionado"##"Fechar"##"Tabela de Dados"##"Fechar"
		Else
			nOpcMsg := 1
		EndIf

		If nOpcMsg == 2		// Visualiza SA
			MaViewSA(cNumSA)
		EndIf
	ElseIf cScOk == "ORIGEM_CP"
		If !isBlind()
			nOpcMsg := Aviso(STR0020,STR0125,If(nOpcao<>1,{STR0022,STR0126},{STR0022}),2)//"Atenção!"##"Este item da autorização de entrega esta relacionado a um contrato de parceria amarrado a um projeto/tarefa e não poderá ser alterado. Utilize a rotina de manutenção do contrato de parceria ou verifique o item selecionado"##"Fechar"##"Visualiza Ctr"##"Fechar"
		Else
			nOpcMsg := 1
		EndIf
		If nOpcMsg == 2		// Visualiza Contrato
			MaViewCT(cNumSC)
		EndIf
	EndIf
EndIf

// Restaura ambiente do pedido de compras
aCols   := aClone(aSavCols)
aHeader := aClone(aSavHeader)
n       := nSavN

SetKey(VK_F4 ,bSavKeyF4)
SetKey(VK_F5 ,bSavKeyF5)
SetKey(VK_F9 ,bSavKeyF9)

RestArea(aAreaSC7)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAJ7FOK³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao dos campos da GetDados de rateio da SC.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGSC,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAJ7FOK()

Local cTRT     := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_TRT"})]
Local cProjeto := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_PROJET"})]
Local cRevisa  := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_REVISA"})]
Local cTarefa  := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_TAREFA"})]
Local lRet     := .T.
Local cCampo   := AllTrim(ReadVar())
Local lGerEmp  := .F.

Do Case
	Case cCampo == 'M->AJ7_PROJET'
		cProjeto:= M->AJ7_PROJET
		lRet := PMSExistCPO("AF8") .And. PmsVldFase("AF8",M->AJ7_PROJET,"52")
	Case cCampo == 'M->AJ7_TAREFA'
		cTarefa	:= M->AJ7_TAREFA
		lRet := ExistCpo("AF9",cProjeto+cRevisa+M->AJ7_TAREFA,1)
EndCase

If !Empty(cProjeto) .And. Empty(cTRT) .And. !Empty(cTarefa) .And. lRet .And. aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_TRT"}) > 0
// parametro que determina se gera empenho direto sem perguntar nada (.T.)
	lGerEmp := GetNewPar("MV_PMSSCGE",.F.)
	If lGerEmp  // gera empenho direto sem perguntar nada
		aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_TRT"})]	 := PmsPrxEmp(cProjeto,cRevisa,cTarefa)
	ElseIf GetMV("MV_PMSBXEM") .And.  ( !isBlind() .And. Aviso(STR0023,STR0024,{STR0025,STR0026},2) == 1 )   //"Gerenciamento de Projetos"###"Voce deseja gerar um empenho deste item ao projeto ?"###"Sim"###"Nao"
		aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_TRT"})]	 := PmsPrxEmp(cProjeto,cRevisa,cTarefa)
	Else
		aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJ7_TRT"})]	 :=	SPACE(LEN(AJ7->AJ7_TRT))
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAJ7LOK³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao LinOk da GetDados de rateio da SC.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGSC,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAJ7LOK()
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][Len(aCols[n])]
	lRet := PmsVldFase("AF8",aCols[n][aScan(aHeader,{|x| Substr(x[2],4,7) =="_PROJET" })],"52")
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n)
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAJ7TOK³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao TudOk da GetDados de rateio da SC.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGSC,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAJ7TOK()

Local nx
Local lRet			:= .T.
Local nTotQuant		:= 0
Local nPosProjet	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ7_PROJET"})
Local nPosTarefa	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ7_TAREFA"})
Local nPosQuant		:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ7_QUANT"})
Local nSavN			:= n
Local cChave		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 to Len(aCols)
	n	:= nx
	If !aCols[n][len(aCols[n])]
		If !Empty(aCols[n][nPosProjet])
			If !PMSAJ7LOK()
				lRet := .F.
				Exit
			EndIf
			// Verifica se existe algum registro com a mesma chave projeto+tarefa
			If Alltrim(aCols[n][nPosProjet])+Alltrim(aCols[n][nPosTarefa]) $ cChave
				lRet := .F.
				Aviso(STR0020, STR0083, {STR0047}, 2) //"Atenção"##"Existem linhas com a mesma chave (Projeto+Tarefa) nesta tela. Favor deixar somente 1 registro para cada chave."##"Fechar"
				Exit
			Else
				cChave += Alltrim(aCols[n][nPosProjet])+Alltrim(aCols[n][nPosTarefa])+"|"
			Endif

			nTotQuant+=aCols[n][nPosQuant]
		EndIf
	EndIf
Next


If lRet .and. nTotQuant > nQtMaxSC
	Help("   ",1,"PMSQTSC")
	lRet := .F.
EndIf

If lRet .and. ExistBlock("PMSAJ7MB")
	lRet := ExecBlock("PMSAJ7MB", .F., .F., {lRet})
EndIf

n := nSavN

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsWritePC³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de gravacao de Pedido de Compras chamado pela        ³±±
±±³          ³rotina de gravacao de Pedido de Compras.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Evento - [1] - Inclusao da PC                         ³±±
±±³          ³                 [2] - Estorno da PC                          ³±±
±±³          ³                 [3] - Exclusao da PC                         ³±±
±±³          ³ExpC2 : Alias da tabela de Pedido de Compras                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³COMXFUN,MATA110                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsWritePC(nEvento,cAliasSC7)

Local nX		:=	0
Local nZ		:=	0
Local nY		:=	0
Local nPos		:=	0
Local aArea		:= GetArea()
Local aRecAJ7	:= {}
Local aTempCols	:= {}

Local nPosItem	:=	0
Local nPosProj	:=	0
Local nPosTar	:=	0
Local nPosRev	:=	0
Local nPosTrt	:=	0
Local lAJ7_VIAINT := .T.

If Type('aHeader') # "U"
	nPosItem	:=aScan(aHeader,{|x| Alltrim(x[2]) == "C7_ITEM"})
	nPosProj	:=aScan(aHeader,{|x| Alltrim(x[2]) == "C7_PROJET"})
	nPosTar	:=aScan(aHeader,{|x| Alltrim(x[2]) == "C7_TAREFA"})
	nPosRev	:=aScan(aHeader,{|x| Alltrim(x[2]) == "C7_REVISA"})
	nPosTrt	:=aScan(aHeader,{|x| Alltrim(x[2]) == "C7_TRT"})
Endif
If Empty(aHeaderAJ7)
	aHeaderAJ7 := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("AJ7")
	While !EOF() .And. (x3_arquivo == "AJ7")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderAJ7,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o array de amarracao das Pedidos x Projetos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Type('aRatAJ7') # "U" .And. aRatAJ7<>Nil
	Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclusão                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nEvento == 1
				nX	:= aScan(aRatAJ7,{|x| x[1] == (cAliasSC7)->C7_ITEM})
				If nX == 0
					If nPosItem > 0
						nPos	:=	Ascan(aCols,{ |x| x[nPosItem]==(cAliasSC7)->C7_ITEM } )
					Else
						nPos	:=	0
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se informou no proprio item.                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (nPos * nPosProj * nPosTar*nPosTrt)  > 0 .And. !Empty(aCols[nPos][nPosProj]) .And. !Empty(aCols[nPos][nPosTar])
						aADD(aTempCols,Array(Len(aHeaderAJ7)+1))
						For nY := 1 to Len(aHeaderAJ7)
							Do Case
							Case Alltrim(aHeaderAJ7[ny][2])	==	"AJ7_PROJET"
								aTempCols[1][ny] :=	aCols[nPos][nPosProj]
							Case Alltrim(aHeaderAJ7[ny][2])	==	"AJ7_REVISA"
								aTempCols[1][ny] :=	aCols[nPos][nPosRev]
							Case Alltrim(aHeaderAJ7[ny][2])	==	"AJ7_TAREFA"
								aTempCols[1][ny] :=	aCols[nPos][nPosTar]
							Case Alltrim(aHeaderAJ7[ny][2])	==	"AJ7_TRT"
								aTempCols[1][ny] :=	aCols[nPos][nPosTrt]
							Case Alltrim(aHeaderAJ7[ny][2]) == "AJ7_QUANT"
								aTempCols[1][ny] :=	(cAliasSC7)->C7_QUANT
							Case Alltrim(aHeaderAJ7[ny][2]) == "AJ7_QTSEGU"
								aTempCols[1][ny] :=(cAliasSC7)->C7_QTSEGUM
							OtherWise
								aTempCols[1][ny] := CriaVar(aHeaderAJ7[ny][2])
							EndCase
						Next ny
						aTempCols[Len(aTempCols)][Len(aHeaderAJ7)+1] := .F.
						aAdd(aRatAJ7,{(cAliasSC7)->C7_ITEM,aClone(aTempCols)})
						nx := Len(aRatAJ7)
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o item ja possui itens gravados.              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AJ7")
						dbSetOrder(2)
						If MsSeek(xFilial()+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM)
							While !Eof() .And. xFilial()+(cAliasSC7)->(C7_NUM+C7_ITEM)==;
												AJ7->(AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC)
								If AJ7->AJ7_REVISA==PmsAF8Ver(AJ7->AJ7_PROJET)
									aADD(aTempCols,Array(Len(aHeaderAJ7)+1))
									For ny := 1 to Len(aHeaderAJ7)
										If ( aHeaderAJ7[ny][10] != "V")
											aTempCols[Len(aTempCols)][ny] := FieldGet(ColumnPos(aHeaderAJ7[ny][2]))
										Else
											aTempCols[Len(aTempCols)][ny] := CriaVar(aHeaderAJ7[ny][2])
										EndIf
										aTempCols[Len(aTempCols)][Len(aHeaderAJ7)+1] := .F.
									Next ny
								EndIf
								dbSkip()
							EndDo
							aAdd(aRatAJ7,{(cAliasSC7)->C7_ITEM,aClone(aTempCols)})
							nx := Len(aRatAJ7)
						EndIf
					Endif
				Endif
				If nx > 0
					dbSelectArea("AJ7")
					dbSetOrder(2)
					MsSeek(xFilial()+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega no array os registros ja existentes.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While !Eof() .And. xFilial()+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM == ;
						AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC
						If AJ7->AJ7_REVISA==PmsAF8Ver(AJ7->AJ7_PROJET)
							aAdd(aRecAJ7,AJ7->(RecNo()))
						EndIf
						dbSkip()
					EndDo
					For nZ := 1 to Len(aRatAJ7[nX ,02])
						dbSelectArea('AJ7')
						If !aRatAJ7[nX ,02 ,nZ ,Len(aRatAJ7[nX ,02 ,nZ])]
						 	If nZ <= Len(aRecAJ7)
						 		AJ7->(dbGoto(aRecAJ7[nZ]))
						 		RecLock('AJ7',.F.)
						 	Else
					 			RecLock('AJ7',.T.)
						 	EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza os dados contidos na GetDados                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nY := 1 to Len(aHeaderAJ7)
								If aHeaderAJ7[nY ,10] # "V"
									cVar := Trim(aHeaderAJ7[nY ,02])
									Replace &cVar. With aRatAJ7[nX ,02 ,nZ ,nY]
								Endif
							Next nY
							AJ7->AJ7_FILIAL	:= xFilial("AJ7")
							AJ7->AJ7_NUMPC	:= (cAliasSC7)->C7_NUM
							AJ7->AJ7_ITEMPC	:= (cAliasSC7)->C7_ITEM
							AJ7->AJ7_COD   	:= (cAliasSC7)->C7_PRODUTO
							MsUnlock()
							PmsAvalAJ7("AJ7",1)
						Else
   				  		If nZ <= Len(aRecAJ7)
	  							MsGoto(aRecAJ7[nZ])
								RecLock("AJ7",.F.,.T.)
					        	dbDelete()
							EndIf
						EndIf
					Next nZ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Deleta os demais registros.                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aRecAJ7) > Len(aRatAJ7[nx][2])
						For nz := (Len(aRatAJ7[nx][2])+1) to Len(aRecAJ7)
							MsGoto(aRecAJ7[nz])
							RecLock("AJ7",.F.,.T.)
					  		dbDelete()
						Next nz
					EndIf
				EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorno                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nEvento == 2
				dbSelectArea("AJ7")
				dbSetOrder(2)
				If MsSeek(xFilial()+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM)
					While !Eof() .And. xFilial()+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM==;
										AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC
						If AJ7->AJ7_REVISA==PmsAF8Ver(AJ7->AJ7_PROJET)
							PmsAvalAJ7("AJ7",2)
						EndIf
				   		dbSelectArea("AJ7")
						dbSkip()
					EndDo
				EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclusao                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nEvento == 3
			   lAJ7_VIAINT:= IIf(AJ7->AJ7_VIAINT <> "S",.T.,.F.)
				If lAJ7_VIAINT
					dbSelectArea("AJ7")
					dbSetOrder(2)
					If MsSeek(xFilial()+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM)
						While !Eof() .And. xFilial()+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM==;
							AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC
							If AJ7->AJ7_REVISA==PmsAF8Ver(AJ7->AJ7_PROJET)
								PmsAvalAJ7("AJ7",3)
							EndIf
							dbSkip()
						EndDo
					EndIf
				Endif
		EndCase
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAvalAJ7³ Autor ³ Edson Maricate        ³ Data ³ 14-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao da amarracao Tarefas x SC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de amarracao                           ³±±
±±³          ³ExpN2: Codigo do Evento                                       ³±±
±±³          ³       [1] Implantacao de uma amarracao                       ³±±
±±³          ³       [2] Estorno de um amarracao                            ³±±
±±³          ³       [3] Exclusao de uma amarracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAvalAJ7(cAlias,nEvento)

Local aArea		:= GetArea()
Local aAreaAJ7	:= AJ7->(GetArea())
Local aAreaSC7	:= SC7->(GetArea())
Local cTRT		:= ''

Do Case
	Case nEvento == 1
		SC7->(dbSetOrder(1))
		If SC7->(MsSeek(xFilial()+(cAlias)->(AJ7_NUMPC+AJ7_ITEMPC)))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os empenhos do Projeto                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTRT := (cAlias)->AJ7_TRT
			PmsAtuEmp((cAlias)->AJ7_PROJET,(cAlias)->AJ7_TAREFA,SC7->C7_PRODUTO,SC7->C7_LOCAL,(cAlias)->AJ7_QUANT,"+",.T.,(cAlias)->AJ7_QTSEGU,@cTRT,SC7->C7_DATPRF,"3",,SC7->C7_TPOP=="P")
			RecLock("AJ7",.F.)
			AJ7->AJ7_TRT := cTRT
			MsUnlock()
		EndIf
	Case nEvento == 2
		SC7->(dbSetOrder(1))
		If SC7->(MsSeek(xFilial()+(cAlias)->AJ7_NUMPC))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os empenhos do Projeto                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PmsAtuEmp((cAlias)->AJ7_PROJET,(cAlias)->AJ7_TAREFA,SC7->C7_PRODUTO,SC7->C7_LOCAL,(cAlias)->AJ7_QUANT,"-",.T.,(cAlias)->AJ7_QTSEGU,(cAlias)->AJ7_TRT,SC7->C7_DATPRF,"3",,SC7->C7_TPOP=="P")
		EndIf
	Case nEvento == 3
		If ExistBlock("PMSEXCPC")
			ExecBlock("PMSEXCPC",.F.,.F.)
		EndIf
		RecLock("AJ7",.F.,.T.)
		dbDelete()
		MsUnlock()
EndCase

RestArea(aAreaSC7)
RestArea(aAreaAJ7)
RestArea(aArea)
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsOrcUser³ Autor ³ Edson Maricate        ³ Data ³ 29-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica os direitos do Usuario.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsOrcUser(cOrcame,cTarefa,cEDT,cEDTPai,nCheck,cCampo,cUserID,lCheckPai)
Local lRet	    := .F.
Local lContinua := .T.
Local aArea	    := GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF1	:= AF1->(GetArea())
Local aAreaAFJ	:= AFJ->(GetArea())
Local aAreaAJG	:= AJG->(GetArea())
Local aAreaAJF	:= AJF->(GetArea())

DEFAULT cUserID   := __cUserID
DEFAULT lCheckPai := .T.

DbSelectArea("AF1")
dbSetOrder(1)
MsSeek(xFilial()+cOrcame)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o controle de usuarios esta habilitado³
//³e verifca a existencia dos campos do AJG e AJF.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AF1->AF1_CTRUSR <> "1"
	lContinua := .F.
	lRet := .T.
Else
	If (AJG->(ColumnPos("AJG_"+cCampo)) == 0) .And. (AJF->(ColumnPos("AJF_"+cCampo)) == 0)
		lContinua := .F.
	EndIf
EndIf

If lContinua

	If cUserID=="000000"
		lRet := .T.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a autorizacao na EDT principal - para aumentar a performance da rotina   ³
		//³Esta verificacao e feita antes pois na maioria dos casos o usuario tem autoriza-  ³
		//³ao na EDT principal.                                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFJ")
		dbSetOrder(1)
		If lCheckPai .And. MsSeek(xFilial()+cOrcame+Padr(cOrcame,Len(AF5->AF5_EDT))+cUserID+SPACE(LEN(AF1->AF1_FASE))) .And. Val(AJF->(FieldGet(ColumnPos("AJF_"+cCampo)))) >=nCheck
			lRet := .T.
		ElseIf lCheckPai .And. MsSeek(xFilial()+cOrcame+Padr(cOrcame,Len(AF5->AF5_EDT))+cUserID+AF1->AF1_FASE) .And. Val(AJF->(FieldGet(ColumnPos("AJF_"+cCampo)))) >=nCheck
			lRet := .T.
		ElseIf cTarefa != Nil
			dbSelectArea("AJG")
			dbSetOrder(1)
			If MsSeek(xFilial()+cOrcame+cTarefa+cUserID+SPACE(LEN(AF1->AF1_FASE)))  .And. Val(AJG->(FieldGet(ColumnPos("AJG_"+cCampo)))) >=nCheck
				lRet	:= .T.
			ElseIf MsSeek(xFilial()+cOrcame+cTarefa+cUserID+AF1->AF1_FASE)  .And. Val(AJG->(FieldGet(ColumnPos("AJG_"+cCampo)))) >=nCheck
				lRet := .T.
			Else
				AF5->(dbSetOrder(1))
				If AF5->(MsSeek(xFilial()+cOrcame+cEDTPai))
					lRet := PmsOrcUser(cOrcame,,AF5->AF5_EDT,AF5->AF5_EDTPAI,nCheck,cCampo,cUserID,.F.)
				EndIf
			EndIf
		ElseIf (cEDT != Nil)
			dbSelectArea("AJF")
			dbSetOrder(1)
			If MsSeek(xFilial()+cOrcame+cEDT+cUserID+SPACE(LEN(AF1->AF1_FASE))) .And. Val(AJF->(FieldGet(ColumnPos("AJF_"+cCampo)))) >=nCheck
				lRet := .T.
			ElseIf MsSeek(xFilial()+cOrcame+cEDT+cUserID+AF1->AF1_FASE) .And. Val(AJF->(FieldGet(ColumnPos("AJF_"+cCampo)))) >=nCheck
				lRet := .T.
			Else
				AF5->(dbSetOrder(1))
				If AF5->(MsSeek(xFilial()+cOrcame+cEDTPai))
					lRet := PmsOrcUser(cOrcame,,AF5->AF5_EDT,AF5->AF5_EDTPAI,nCheck,cCampo,cUserID,.F.)
				EndIf
			EndIf
		EndIf
	EndIf

EndIf

RestArea(aAreaAJF)
RestArea(aAreaAJG)
RestArea(aAreaAFJ)
RestArea(aAreaAF5)
RestArea(aAreaAF1)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF9RecRelTables³ Autor ³                       ³ Data ³ 13.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que atualiza as tabelas que contem o codigo de tarefa       ³±±
±±³          ³anterior pelo novo.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF9RecRelTables(cFil, cProj, cRev, cOldCode, cTask,aTabelas,aCampoTOP)
	AF9AtuCode(cFil, cProj, cRev, cOldCode, cTask, @aCampoTOP)
	AF9NoIdx(cFil,   cProj, cRev, cOldCode, cTask,aTabelas, @aCampoTOP)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AFCRecRelTables³ Autor ³                       ³ Data ³ 13.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que atualiza as tabelas que contem o codigo de EDT          ³±±
±±³          ³anterior pelo novo.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFCRecRelTables(cFil, cProj, cRev, cOldCode, cEDT, aTabelas, aCampoTOP)
	AFCAtuCode(cFil, cProj, cRev, cOldCode, cEDT, @aCampoTOP)
	AFCNoIdx  (cFil, cProj, cRev, cOldCode, cEDT, aTabelas, @aCampoTOP)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF2RecRelT³ Autor ³                       ³ Data ³ 13.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que atualiza as tabelas que contem o codigo de tarefa  ³±±
±±³          ³anterior pelo novo.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF2RecRelTables(cFil, cProj, cOldCode, cTask)
	AF2AtuCode(cFil, cProj, cOldCode, cTask)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF5RecRelT³ Autor ³                       ³ Data ³ 13.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que atualiza as tabelas que contem o codigo de EDT     ³±±
±±³          ³anterior pelo novo.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF5RecRelTables(cFil, cProj, cOldCode, cEDT)
	AF5AtuCode(cFil, cProj, cOldCode, cEDT)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSSubRec ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 08.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta tela para informar o produto/recurso atual   ³±±
±±³          ³ pelo novo a ser alterado.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSSubRec( lOrcam )
Local oDlg
Local oChkProd
Local oChkRec
Local oGetProdDe
Local oGetProdPara
Local oGetRecDe
Local oGetRecPara
Local lProdut   := .F.
Local lRecurs   := .F.
Local cProdDe   := ""
Local cProdPara := ""
Local cRecDe    := ""
Local cRecPara  := ""
Local lOk       := .F.
Local aRetorno  := {}

Default lOrcam := .T.

	If lOrcam
		cProdDe   := Space(TamSX3("AF3_PRODUT")[1])
		cProdPara := Space(TamSX3("AF3_PRODUT")[1])
		cRecDe    := Space(TamSX3("AF3_RECURS")[1])
		cRecPara  := Space(TamSX3("AF3_RECURS")[1])
	Else
		cProdDe   := Space(TamSX3("AFA_PRODUT")[1])
		cProdPara := Space(TamSX3("AFA_PRODUT")[1])
		cRecDe    := Space(TamSX3("AFA_RECURS")[1])
		cRecPara  := Space(TamSX3("AFA_RECURS")[1])
	EndIf

	Define MsDialog oDlg Title STR0027 From 0, 0 To 290, 300 Of oMainWnd Pixel //"Substituir Produto/Recurso"

		//
 		@ 012, 005 CHECKBOX oChkProd VAR lProdut PROMPT STR0028 ; // "Substituir Produtos"
 		           ON CHANGE CheckOK(lProdut, @oGetProdDe, @oGetProdPara ) ;
	               Of oDlg Pixel Size 200, 16

		// Produto atual
		@ 030, 005 Say STR0029 Of oDlg Pixel // "Produto Atual: "
		@ 029, 045 MSGet oGetProdDe VAR cProdDe Valid Empty(cProdDe) .or. ExistCpo('SB1',cProdDe,1) When lProdut ;
				   F3 "SB1" Of oDlg ;
		           Picture "@!" Size 100, 08 Pixel HASBUTTON

		// Novo Produto
		@ 045, 005 Say STR0030 Of oDlg Pixel // "Novo Produto: "
		@ 044, 045 MSGet oGetProdPara VAR cProdPara Valid Empty(cProdPara) .or. ExistCpo('SB1',cProdPara,1) When lProdut ;
		           F3 "SB1" Of oDlg;
		           Picture "@!" Size 100, 08 Pixel HASBUTTON

		//
 		@ 062, 005 CHECKBOX oChkRec VAR lRecurs PROMPT STR0031 ; // "Substituir Recursos"
 		           ON CHANGE CheckOK(lRecurs, @oGetRecDe, @oGetRecPara ) ;
	               Of oDlg Pixel Size 200, 16

		// Recurso atual
		@ 080, 005 Say STR0032 Of oDlg Pixel // "Recurso Atual: "
		@ 079, 045 MSGet oGetRecDe VAR cRecDe Valid Empty(cRecDe) .or. ExistCpo('AE8',cRecDe,1) When lRecurs ;
		           F3 "AE8" Of oDlg ;
		           Picture "@!" Size 100, 08 Pixel HASBUTTON

		// Novo Recurso
		@ 095, 005 Say STR0033 Of oDlg Pixel // "Novo Recurso: "
		@ 094, 045 MSGet oGetRecPara VAR cRecPara Valid Empty(cRecPara) .or. ExistCpo('AE8',cRecPara,1) When lRecurs ;
		           F3 "AE8" Of oDlg ;
		           Picture "@!" Size 100, 08 Pixel HASBUTTON

		// OK
		@ 130, 035 Button STR0034 Size 35 ,11 FONT oDlg:oFont Action Iif( BtnOKVld(lProdut, cProdDe, cProdPara, lRecurs, cRecDe ,cRecPara ) ,(lOk := .T., oDlg:End()),.F. ) Of oDlg Pixel // "OK"

		// Cancelar
		@ 130, 090 Button STR0006 Size 35 ,11 FONT oDlg:oFont Action (lOk := .F., oDlg:End()) Of oDlg Pixel // "Cancelar"

	Activate MsDialog oDlg Centered

	If lOk
		aRetorno := { lProdut ,cProdDe ,cProdPara ;
					 ,lRecurs ,cRecDe  ,cRecPara  }
	EndIf

Return( aRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckOK  ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 08.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que habita/desabilita as Gets conforme lEnable        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CheckOK(lEnable, oGet1, oGet2 )

	If lEnable
		oGet1:Enable()
		oGet2:Enable()
	Else
		oGet1:Disable()
		oGet2:Disable()
	EndIf

	oGet1:Refresh()
	oGet2:Refresh()

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BtnOKVld  ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 08.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao é chamada ao clicar no botão OK da dialog, a qual      ³±±
±±³           valida os campos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BtnOKVld(lProdut, cProdDe, cProdPara, lRecurs, cRecDe ,cRecPara )
Local lRetorno := .T.

If lProdut
	If lRetorno .AND. Empty(cProdDe)
		Help(" ",,"PMSSubRec",,STR0161,1,0)
		lRetorno := .F.
	EndIf

	If lRetorno .AND. Empty(cProdPara)
		Help(" ",,"PMSSubRec",,STR0162,1,0)
		lRetorno := .F.
	EndIf
EndIf
If lRecurs
	If lRetorno .AND. Empty(cRecDe)
		Help(" ",1,"PMSSubRec",,STR0163,1,0)
		lRetorno := .F.
	EndIf

	If lRetorno .AND. Empty(cRecPara)
		Help(" ",1,"PMSSubRec",,STR0164,1,0)
		lRetorno := .F.
	EndIf

EndIf

Return( lRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsGetBDIPad³ Autor ³ Bruno Sobieski      ³ Data ³ 05.04.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para pegar o BDI Padrao para uma tarefa, definido pelos³±±
±±³          ³campos AF5 e AFC _BDITAR                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsGetBDIPad(cAlias ,cPROJORC ,cREVISA ,cEDTPAI ,cUtiBdi)
Local nRet	:=	0
Local aArea	:=	GetArea()
Local aAreaAFC	:=	AFC->(GetArea())
Local aAreaAF5	:=	AF2->(GetArea())

	If cAlias	==	"AFC"
		DEFAULT	cPROJORC	:=	M->AF9_PROJET
		DEFAULT	cREVISA	:=	M->AF9_REVISA
		DEFAULT	cEDTPAI	:=	M->AF9_EDTPAI
		DEFAULT	cUtiBDI	:=	M->AF9_UTIBDI

		If cUtiBDI == "2"
			nRet := 0 //quando nao utiliza o BDI na tarefa
	    Else
			AFC->(DbSetOrder(1))
			While AFC->(DbSeek(xFilial()+cPROJORC+cRevisa+cEDTPAI)) .And. nRet == 0
				nRet	:=	AFC->AFC_BDITAR
				cEDTPAI	:=	AFC->AFC_EDTPAI
			Enddo
			If nRet	==	0
				AF8->(DbSetOrder(1))
				If AF8->(MsSeek(xFilial()+cProjOrc))
					nRet	:=	AF8->AF8_BDIPAD
				EndIf
			Endif
		EndIf
		RestArea(aAreaAFC)
	Else
		DEFAULT	cPROJORC	:=	M->AF2_ORCAME
		DEFAULT	cEDTPAI		:=	M->AF2_EDTPAI
		DEFAULT	cUtiBDI		:=	M->AF2_UTIBDI

		If cUtiBDI == "2"
			nRet := 0 //quando nao utiliza o BDI na tarefa
	    Else
			AF5->(DbSetOrder(1))
			While AF5->(DbSeek(xFilial()+cPROJORC+cEDTPAI)) .And. nRet == 0
				nRet	:=	AF5->AF5_BDITAR
				cEDTPAI	:=	AF5->AF5_EDTPAI
			Enddo

			If nRet	==	0
				AF1->(DbSetOrder(1))
				If AF1->(MsSeek(xFilial()+cProjOrc))
					nRet	:=	AF1->AF1_BDIPAD
				EndIf
			Endif
		EndIf
		RestArea(aAreaAF5)
	Endif
	RestArea(aArea)

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsUtiBDI ºAutor  ³Paulo Carnelossi    º Data ³  19/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizacao na clausula WHEN dos campos AF2_BDI /     º±±
±±º          ³AF2_VALBDI / AF9_BDI / AF9_VALBDI                           º±±
±±º          ³para nao permitir edicao quando tarefa nao utiliza BDI      º±±
±±º          ³(quando BDI eh 0 (zero) na tarefa, mas no projeto e > 0)    º±±
±±º          ³  PmsUtiBDI(cProjOrc)                                       º±±
±±º          ³  Onde :                                                    º±±
±±º          ³  // cProjOrc  = '1' Quando eh orcamento                    º±±
±±º          ³  //				'2' Quando eh projeto                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsUtiBDI(cProjOrc)
Local lRet := .T.   // tratamento padrao - todas tarefas utilizam BDI
Local aArea := GetArea()

	// cProjOrc  = '1' Quando eh orcamento
	//				'2' Quando eh projeto
	If cProjOrc == "1"

		If M->AF2_UTIBDI == "2"
			lRet := .F.
		EndIf

	ElseIf cProjOrc == "2"

		If M->AF9_UTIBDI == "2"
			lRet := .F.
		EndIf

	EndIf

	RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PMSPesqSRA ³ Autor ³ Cristiano Denardi      ³ Data ³ 24.04.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pesquisa codigo do Funcionario na tabela SRA, independente da   ³±±
±±³          ³filial corrente.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSPesqSRA( lMostraHelp, lRegBlq )

Local aArea  := GetArea()
Local cArq   := ""
Local cIndex := ""
Local cFil   := ""
Local cChave := ""
Local lRet   := .T.
Local lComp  := PmsAe8Comp()
Local lAchouSRA := .F.
Default lMostraHelp := .T.
Default lRegBlq     := .T.

dbSelectArea("SRA")
dbSetOrder(1) // RA_FILIAL + RA_MAT


If lComp
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retira Filial na Busca de Funcionario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFil   := ""
	cArq   := CriaTrab(nil,.F.)
	cIndex := "RA_MAT"
	IndRegua( "SRA", cArq, cIndex,,, OemToAnsi("Selecionando Registros...") )
	nIndex := RetIndex("SRA")
	dbSelectArea("SRA")
	#IFNDEF TOP
		dbSetIndex( cArq+ordBagExt() )
	#ENDIF
	dbSetOrder( nIndex+1 )
	DbGoTop()

Else
	cFil := xFilial()
Endif

/////////////////
// Busca registro
cChave := M->AE8_CODFUN           
lRet   := MsSeek( cFil + cChave )

//Quando tabela AE8 compartilhada e existe campo AE8_FILFUN
//Pode ocorrer de o primeiro registro da SRA estar bloqueado
//e existir um outro registro com a mesma matricula porem com
//filial diferente. Abaixo verifico se existe outro registro
If lComp
	While SRA->(!EOF()) .and. Alltrim(SRA->RA_MAT) == Alltrim(cChave)
		if RegistroOk("SRA",.F.)
			lAchouSRA := .T.
			exit
		else
			SRA->(dbSkip())
		EndIf
	EndDo
	//caso nao ache outro registro desbloqueado, volta ao registro antigo da SRA
	IF !lAchouSRA
		lRet   := MsSeek( cFil + cChave )
	Endif
EndIf

////////////////////////////////
// Verifica se o registro do
// arquivo esta bloqueado ou nao
If lRet .And. lRegBlq
	lRet := RegistroOk("SRA",.F.)
	If !lRet
		cHelp:="REGBLOQ"
	EndIf
EndIf

//////////////////////////
// Mostra o help de
// registro nao encontrado
If !lRet
	If lMostraHelp
		HELP(" ",1,"REGNOIS")
	EndIf
EndIf

If lComp
	dbSelectArea("SRA")
	RetIndex("SRA")
	#IFNDEF TOP
		IF cArq != ""
			FErase ( cArq+OrdBagExt() )
		EndIF
	#ENDIF
Endif

////////////////////////////////////
// Simula gatilho para retorno da
// Filial do Funcionario selecionado
If lRet .And. lComp
	M->AE8_FILFUN := SRA->RA_FILIAL
Endif

RestArea( aArea )
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsAe8Comp ³ Autor ³ Cristiano Denardi      ³ Data ³ 24.04.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se Projetos estao compartilhados para usar movimentos  ³±±
±±³          ³exclusivos.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAe8Comp()
Local lRet := .F.
lRet :=	AE8->(ColumnPos("AE8_FILFUN")) > 0 .And.;	// Campo para Compartilhamento de funcionarios de outras filias
			Alltrim(xFilial("AE8")) == "" 				// Tabela compartilhada
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PMSQEdit ³ Autor ³ Adriano Ueda          ³ Data ³28/04/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Controladoria    ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PMSQEdit()
	Private aRotina := MenuDef()
	Private aCores := PmsAF8Color()

	mBrowse(6, 1, 22, 75, "AF8",,,,,, aCores)

Return

Function PMSPEdit(cAlias, nReg, nOpcx, cR1, cR2, cVers, lSimula)
	Local cProj     := ""
	Local cRev      := ""
	Local cProjDesc := ""
	Local lConfirm  := .F.
	Local aColsOrig := {}

	Private oDlg := Nil

	// variáveis que definem a ação do formulário
	//Private VISUAL := .F.
	//Private INCLUI := .F.
	//Private ALTERA := .F.
	//Private DELETA := .F.

	// privates das NewGetDados
	Private oGetDados1

	dbSelectArea(cAlias)
	(cAlias)->(dbGoto(nReg))

	cProj     := (cAlias)->AF8_PROJET
	cRev      := PMSAF8Ver((cAlias)->AF8_PROJET)
	cProjDesc := ReadValue(cAlias, 1, xFilial(cAlias) + cProj, "AF8_DESCRI")

	// valida o projeto, verificar a fase
	If !PmsVldFase(cAlias, cProj, "25") .Or. !PmsVldFase(cAlias, cProj, "18")
		Return .F.
	EndIf

	// verifica se há pelo menos um registro no AF9
	dbSelectArea("AF9")
	dbSetOrder(1) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
	If !MsSeek(xFilial("AF9") + cProj + cRev)
		Aviso(STR0045, STR0046, {STR0047}, 2) //"Edição de Tarefas"##"Este projeto não possui nenhuma tarefa."##"Fechar"
		Return .F.
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0045 FROM C(178), C(181) TO C(665), C(967) PIXEL //"Edição de Tarefas"

		// código projeto
		@ C(10), C(06) Say STR0048 ; //"Projeto:"
		  Size C(40), C(12) Pixel Of oDlg

		@ C(10), C(25) Say AllTrim(cProj) + " - " + AllTrim(cProjDesc) ;
		  Size C(200), C(12) Pixel Of oDlg

		// botões OK e Cancelar
		@ C(228), C(307) Button "OK" Action ;
		  Iif(PMSQEGrv(xFilial(cAlias), cProj, cRev, oGetDados1:aCols, aColsOrig), oDlg:End(), ;
		  Aviso(STR0045, STR0049, {STR0047}, 2)); //"Edição de Tarefas"##"Não foi possível realizar a alteração das tarefas."##"Fechar"
		  Size C(037), C(012) Pixel Of oDlg

		@ C(228), C(350) Button STR0050 Action oDlg:End() ; //"Cancelar"
		  Size C(037), C(012) Pixel Of oDlg

		// cria ExecBlocks dos Componentes Padroes do Sistema

		// chamadas das GetDados do Sistema
		PMSGDTask(cProj, cRev)

		// salva um backup do aCols
		aColsOrig := aClone(oGetDados1:aCols)

	ACTIVATE MSDIALOG oDlg CENTERED

	If lConfirm



	EndIf

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados1()³ Autor ³ Adriano Ueda              ³ Data ³30/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PMSGDTask(cProj, cRev)

	// variaveis deste Form
	Local nX        := 0
	Local i := 0

	// variaveis da MsNewGetDados()
	Local aCpoGDa   := {"AF9_TAREFA", "AF9_START", "AF9_FINISH", "AF9_QUANT"}

	// vetor com os campos que poderao ser alterados
	Local aAlter    := {"AF9_START", "AF9_FINISH", "AF9_QUANT"}
	Local nSuperior := C(022)         // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local nEsquerda := C(005)         // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
	Local nInferior := C(223)         // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
	Local nDireita  := C(390)         // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem

	// posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
	Local nOpc      := GD_UPDATE + GD_INSERT + GD_DELETE
	Local cLinOk    := "AllwaysTrue"  // Funcao executada para validar o contexto da linha atual do aCols
	Local cTudoOk   := "AllwaysTrue"  // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos  := ""             // Nome dos campos do tipo caracter que utilizarao incremento automatico.
	                                  // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do
	                                  // segundo campo>+..."
	Local nFreeze   := 001            // Campos estaticos na GetDados.
	Local nMax      := 999            // Numero maximo de linhas permitidas. Valor padrao 99
	Local cFieldOk  := "AllwaysTrue"  // Funcao executada na validacao do campo
	Local cSuperDel := ""             // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	Local cDelOk    := "AllwaysTrue"  // Funcao executada para validar a exclusao de uma linha do aCols

	// objeto no qual a MsNewGetDados será criada
	Local oWnd      := oDlg
	Local aHead     := {}             // Array a ser tratado internamente na MsNewGetDados como aHeader
	Local aCol      := {}             // Array a ser tratado internamente na MsNewGetDados como aCols

	// carrega aHead
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2)) // Campo
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			Aadd(aHead,{ AllTrim(X3Titulo()),;
				SX3->X3_CAMPO	,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				""	,; //SX3->X3_VALID
				SX3->X3_USADO	,;
				SX3->X3_TIPO	,;
				SX3->X3_F3 		,;
				SX3->X3_CONTEXT,;
				SX3->X3_CBOX	,;
				SX3->X3_RELACAO})
		Endif
	Next

	dbSelectArea("AF9")
	dbSetOrder(1) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
	MsSeek(xFilial("AF9") + cProj + cRev)

	While !AF9->(Eof()) .And. AF9->AF9_FILIAL == xFilial("AF9") ;
	                    .And. AF9->AF9_PROJET == cProj ;
	                    .And. AF9->AF9_REVISA == cRev

		aAux := {}

		AAdd(aAux, AF9->AF9_TAREFA)
		AAdd(aAux, AF9->AF9_START)
		AAdd(aAux, AF9->AF9_FINISH)
		AAdd(aAux, AF9->AF9_QUANT)
		AAdd(aAux, .F.)
		AAdd(aCol, aAux)

		AF9->(dbSkip())
	End

	oGetDados1:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)

	For i := 1 To Len(oGetDados1:aHeader)
		oGetDados1:aHeader[i][06] := ""
		oGetDados1:aHeader[i][13] := ""

		oGetDados1:aInfo[i][4] := ""
	Next

	// Cria ExecBlocks da GetDados

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

	If nHRes == 640	// resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	// tratamento para tema "Flat"
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)


Function PMSQEGrv(xFilial, cProj, cRev, aCols, aColsOrig)
	Local aCab := {}
	Local i := 0

	Private lMsErroAuto := .F.

	For i := 1 To Len(aCols)

		If DiffArray(aClone(aCols[i]), aClone(aColsOrig[i]))
		  aCab	:=	{}

			aAdd(aCab, {"AF9_PROJET", cProj, Nil})
			aAdd(aCab, {"AF9_REVISA", cRev, Nil})
			aAdd(aCab, {"AF9_TAREFA", aCols[i][1], Nil})
			aAdd(aCab, {"AF9_START",  aCols[i][2], Nil})
			aAdd(aCab, {"AF9_FINISH", aCols[i][3], Nil})
			aAdd(aCab, {"AF9_QUANT",  aCols[i][4], Nil})

			PMSA203(4, , "001", aCab)
		EndIf
	Next

Return !lMsErroAuto

Function DiffArray(aArray1, aArray2)
	Local i := 0

	For i := 1 To Len(aArray1)
		If aArray1[i] != aArray2[i]
			Return .T.
		EndIf
	Next
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PMSResize  ³ Autor ³ Adriano Ueda           ³ Data ³ 05/05/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o tamanho de uma medida considerando a resolução de tela³±±
±±³          ³utilizada no Protheus.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSResize(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

	If nHRes == 640

		// resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam /= 2
	ElseIf (nHRes == 798).Or.(nHRes == 800)

		// resolucao 800x600
		nTam /= 2
	Else

		// resolucao 1024x768 e acima
		nTam /= 2
	EndIf

	// tratamento para tema "Flat"
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam /= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {{STR0042, "AxPesqui", 0, 1},;  //"Pesquisar"
	                    {STR0043, "PMSPEdit", 0 , 6},;   //"Editar"
	                    {STR0044, "PMS200Leg" , 0 , 6, ,.F.}}  //"Legenda"
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CPYMarkP  ºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcoes de copia selecionada de projeto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Melhoria Fabrica.                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPYMarkP(cArquivo, aMarks, cPaiFilho)
Local aArea   := GetArea()
Local lUnMark := (cArquivo)->CPYMARK
Local nPos    := 0
Local nLen    := Len(aMarks)

Default cPaiFilho := "1"

If (cArquivo)->(RecNo()) != 1

	If !lUnMark
		Aadd(aMarks, {(cArquivo)->ALIAS, (cArquivo)->RECNO})

		//If cPaiFilho == "1"
		//	MarkEDTPai((cArquivo)->ALIAS, (cArquivo)->RECNO, @aMarks)
		//EndIf

	Else
		nPos := AScan(aMarks, ;
		             {|x| x[1] == (cArquivo)->ALIAS .And. x[2] == (cArquivo)->RECNO})

		If nPos > 0
			ADel(aMarks, nPos)
			ASize(aMarks, nLen-1)
		EndIf
	EndIf

	If cPaiFilho == "1" .And. !Empty((cArquivo)->CTRLNIV)
		MarkFilhos((cArquivo)->RECNO, @aMarks, lUnMark)
	EndIf

EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Markados  ºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcoes de copia selecionada de projeto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Melhoria Fabrica.                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Markados(cArquivo, aMarks)
Local aArea := GetArea()
Local nLAt  := (cArquivo)->(RecNo())
Local lPMSC010	:= IsinCallStack("PMC010BEXP")
Local aMarkBck:= {}

(cArquivo)->(DbGoTop())

Do While !(cArquivo)->(Eof())

	(cArquivo)->CPYMARK := AScan(aMarks, ;
	   {|x| x[1] == (cArquivo)->ALIAS .And. x[2] == (cArquivo)->RECNO }) > 0
	If (cArquivo)->CPYMARK .and. lPMSC010
		Aadd(aMarkBck, { (cArquivo)->ALIAS, (cArquivo)->RECNO} )
	Endif
	(cArquivo)->(DbSkip())
EndDo

If lPMSC010
	aMarks := {}
	aMarks := aClone(aMarkBck)
Endif

(cArquivo)->(DbGoTo(nLAt))
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarkEDTPaiºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcoes de copia selecionada de projeto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Melhoria Fabrica.                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarkEDTPai(cMAlias, nMRecNo, aMarks)

Local aArea    := GetArea()
Local aAreaX   := (cMAlias)->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local cEDTPAI  := ""
Local cKeyAFC  := ""

(cMAlias)->(DbGoTo(nMRecNo))

cEDTPAI := &(cMAlias+"->" + cMAlias + "_EDTPAI")

If !Empty(cEDTPAI)
	cKeyAFC := &(cMAlias + "->" + cMAlias + "_PROJET") + ;
	           &(cMAlias + "->" + cMAlias + "_REVISA")

	AFC->(DbSetOrder(1))
	If AFC->(MsSeek(xFilial("AFC") + cKeyAFC + cEDTPAI))

		If AScan(aMarks, {|x| x[1] == "AFC" .And. x[2] == AFC->(RecNo())}) == 0
			AAdd(aMarks, {"AFC", AFC->(RecNo())})
		EndIf

		MarkEDTPai("AFC", AFC->(RecNo()), @aMarks)
	EndIf
EndIf

AFC->(RestArea(aAreaAFC))
(cMAlias)->(RestArea(aAreaX))
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarkFilhosºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcoes de copia selecionada de projeto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Melhoria Fabrica.                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarkFilhos(nMRecNo, aMarks, lUnMark)

Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local cKeyAFC  := ""
Local nLen     := 0
Local cAliasf7	:= ""
Local lPMSC010	:= IsinCallStack("PMC010BEXP")

AF9->(DbSetOrder(2))
AFC->(DbGoTo(nMRecNo))
If lPMSC010
	cAliasf7 := "F7"+getNextAlias()
	cQuery := " SELECT 'AFC' ALIAS, AFC_EDT 'CODIGO', R_E_C_N_O_ RECNO__ FROM "+RetSqlName("AFC")
	cQuery += " WHERE AFC_FILIAL = '"+xFilial("AFC")+"' AND "
	cQuery += " AFC_PROJET ='"+AFC->AFC_PROJET+"' AND "
	cQuery += " AFC_REVISA ='"+AFC->AFC_REVISA+"' AND "
	cQuery += " AFC_EDTPAI ='"+AFC->AFC_EDT+"' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL"
	cQuery += " SELECT 'AF9' ALIAS , AF9_TAREFA 'CODIGO', R_E_C_N_O_ RECNO__ FROM "+RetSqlName("AF9")
	cQuery += " WHERE AF9_FILIAL = '"+xFilial("AF9")+"' AND "
	cQuery += " AF9_PROJET ='"+AFC->AFC_PROJET+"' AND "
	cQuery += " AF9_REVISA ='"+AFC->AFC_REVISA+"' AND "
	cQuery += " AF9_EDTPAI ='"+AFC->AFC_EDT+"' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CODIGO "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasf7 , .T. , .T. )

	While (cAliasf7)->(!EOF())

		If !lUnMark
			If AScan(aMarks, {|x| x[1] == (cAliasf7)->(ALIAS) .And. x[2] == (cAliasf7)->(RECNO__) }) == 0
				AAdd(aMarks, {(cAliasf7)->(ALIAS), (cAliasf7)->(RECNO__) })
			EndIf
		Else
			If (nPos := ;
			    AScan(aMarks, {|x| x[1] == (cAliasf7)->(ALIAS) .And. x[2] == (cAliasf7)->(RECNO__) })) > 0
				nLen := Len(aMarks)
				ADel(aMarks, nPos)
				ASize(aMarks, nLen - 1)
				nLen := Len(aMarks)
			EndIf
		EndIf

		If (cAliasf7)->(ALIAS) == "AFC"
			MarkFilhos( (cAliasf7)->(RECNO__) , @aMarks, lUnMark)
		Endif


		(cAliasf7)->(dbSkip())
	EndDo
	(cAliasf7)->(dbCloseArea())

Else

	cKeyAFC := AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT

	AFC->(DbSetOrder(2))

	If AFC->(MsSeek(xFilial("AFC") + cKeyAFC))
		Do While !AFC->(Eof()) .And. xFilial("AFC") + ;
			cKeyAFC == AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDTPAI

			If !lUnMark
				If AScan(aMarks, {|x| x[1] == "AFC" .And. x[2] == AFC->(RecNo())}) == 0
					AAdd(aMarks, {"AFC", AFC->(RecNo())})
				EndIf
			Else
				If (nPos := ;
				    AScan(aMarks, {|x| x[1] == "AFC" .And. x[2] == AFC->(RecNo()) })) > 0
					nLen := Len(aMarks)
					ADel(aMarks, nPos)
					ASize(aMarks, nLen - 1)
					nLen := Len(aMarks)
				EndIf
			EndIf

			MarkFilhos(AFC->(RecNo()), @aMarks, lUnMark)
			AFC->(DbSkip())
		EndDo
	EndIf

	If AF9->(MsSeek(xFilial("AF9") + cKeyAFC))
		Do While !AF9->(Eof()) .And. xFilial("AF9") + ;
		  cKeyAFC == AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI

			If !lUnMark

				If AScan(aMarks, {|x| x[1] == "AF9" .And. x[2] == AF9->(RecNo())}) == 0
					AAdd(aMarks, {"AF9", AF9->(RecNo())})
				EndIf
			Else

				If (nPos := ;
				    AScan(aMarks, {|x| x[1] == "AF9" .And. x[2] == AF9->(RecNo())})) > 0
					nLen := Len(aMarks)
					ADel(aMarks, nPos)
					ASize(aMarks, nLen - 1)
					nLen := Len(aMarks)
				EndIf
			EndIf

			AF9->(DbSkip())
		EndDo
	EndIf

EndIf

AFC->(RestArea(aAreaAFC))
AF9->(RestArea(aAreaAF9))
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UnMarkPai ºAutor  ³Carlos A. Gomes Jr. º Data ³  10/16/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcoes de copia selecionada de projeto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Melhoria Fabrica.                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function UnMarkPai(cMAlias, nMRecNo, aMarks)

Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local lCont    := .T.
Local nCont    := 0
Local cKey     := ""
Local nLen     := Len(aMarks)

If cMAlias == "AF9"
	AF9->(DbGoTo(nMRecNo))
	cKey := AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI
Else
	AFC->(DbGoTo(nMRecNo))
	cKey := AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDTPAI
EndIf

AF9->(DbSetOrder(2))
If AF9->(MsSeek(xFilial("AF9") + cKey))
	Do While lCont .And. !AF9->(Eof()) .And. xFilial("AF9") + ;
	  cKey == AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI
		lCont := (AScan(aMarks, {|x| x[1] == "AF9" .And. x[2] == AF9->(RecNo())}) == 0)
		AF9->(DbSkip())
	EndDo
EndIf

AFC->(DbSetOrder(2))
If lCont .And. AFC->(MsSeek(xFilial("AFC") + cKey))
	Do While lCont .And. !AFC->(Eof()) .And. xFilial("AFC") + ;
	  cKey == AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDTPAI
		lCont := (AScan(aMarks, {|x| x[1] == "AFC" .And. x[2] == AFC->(RecNo())}) == 0)
		AFC->(DbSkip())
    EndDo
EndIf

AFC->(DbSetOrder(1))
If lCont .And. AFC->(MsSeek(xFilial("AFC") + cKey))
	If (nCont := ;
	  AScan(aMarks, {|x| x[1] == "AFC" .And. x[2] == AFC->(RecNo()) })) > 0
		ADel(aMarks, nCont)
		ASize(aMarks, nLen - 1)

		If !Empty(AFC->AFC_EDTPAI)
			UnMarkPai("AFC", AFC->(RecNo()), @aMarks)
		EndIf
	EndIf
EndIf

AFC->(RestArea(aAreaAFC))
AF9->(RestArea(aAreaAF9))
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
‘‘ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»‘‘
‘‘ºPrograma  ³CPYMark   ºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºDesc.     ³Funcoes de copia selecionada de projeto.                    º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºUso       ³ Melhoria Fabrica.                                          º‘‘
‘‘ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼‘‘
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPYMarkB(cArquivo, aMarks, cPaiFilho)
	Local aArea   := GetArea()
	Local lMark := (cArquivo)->CPYMARK
	Local nPos    := 0
	Local nLen    := Len(aMarks)

	Default cPaiFilho := "1"

	If (cArquivo)->(RecNo()) != 1
		If !lMark

			Aadd(aMarks, {(cArquivo)->ALIAS, (cArquivo)->RECNO})

			//If cPaiFilho == "1"
			//	MarkBEDTPai((cArquivo)->ALIAS, (cArquivo)->RECNO, @aMarks)
			//EndIf
		Else

			nPos := AScan(aMarks, {|x| x[1] == (cArquivo)->ALIAS .And. ;
			                           x[2] == (cArquivo)->RECNO})
			If nPos > 0
				ADel(aMarks, nPos)
				ASize(aMarks, nLen-1)
			EndIf

			//If lUnMrkF
			//	UnMarkBPai((cArquivo)->ALIAS, (cArquivo)->RECNO, @aMarks)
			//EndIf
		EndIf

		If cPaiFilho == "1" .And. !Empty((cArquivo)->CTRLNIV)
			MarkBFilhos((cArquivo)->RECNO, @aMarks, lMark)
		EndIf
	EndIf

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
‘‘ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»‘‘
‘‘ºPrograma  ³Markados  ºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºDesc.     ³Funcoes de copia selecionada de projeto.                    º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºUso       ³ Melhoria Fabrica.                                          º‘‘
‘‘ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼‘‘
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarkadosB(cArquivo,aMarks)
	Local aArea := GetArea()
	Local nLAt  := (cArquivo)->(RecNo())

	(cArquivo)->(DbGoTop())
	Do While !(cArquivo)->(Eof())
		(cArquivo)->CPYMARK := AScan(aMarks, ;
		     {|x| x[1] == (cArquivo)->ALIAS .And. x[2] == (cArquivo)->RECNO}) > 0
		(cArquivo)->(DbSkip())
	EndDo

	(cArquivo)->(DbGoTo(nLAt))
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
‘‘ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»‘‘
‘‘ºPrograma  ³MarkEDTPaiºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºDesc.     ³Funcoes de copia selecionada de projeto.                    º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºUso       ³ Melhoria Fabrica.                                          º‘‘
‘‘ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼‘‘
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarkBEDTPai(cMAlias,nMRecNo,aMarks)

Local aArea    := GetArea()
Local aAreaX   := (cMAlias)->(GetArea())
Local aAreaAF5 := AF5->(GetArea())
Local cEDTPAI  := ""
Local cKeyAF5  := ""

(cMAlias)->(DbGoTo(nMRecNo))
cEDTPAI := &(cMAlias + "->" + cMAlias + "_EDTPAI")

If !Empty(cEDTPAI)
	cKeyAF5 := &(cMAlias + "->" + cMAlias + "_ORCAME")
	AF5->(DbSetOrder(1))
	If AF5->(MsSeek(xFilial("AF5") + cKeyAF5 + cEDTPAI))
		If AScan(aMarks, {|x| x[1] == "AF5" .And. x[2] == AF5->(RecNo())}) == 0
			AAdd(aMarks, {"AF5", AF5->(RecNo())})
		EndIf
		MarkBEDTPai("AF5", AF5->(RecNo()), @aMarks)
	EndIf
EndIf

AF5->(RestArea(aAreaAF5))
(cMAlias)->(RestArea(aAreaX))
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
‘‘ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»‘‘
‘‘ºPrograma  ³MarkFilhosºAutor  ³Carlos A. Gomes Jr. º Data ³  09/17/06   º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºDesc.     ³Funcoes de copia selecionada de projeto.                    º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºUso       ³ Melhoria Fabrica.                                          º‘‘
‘‘ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼‘‘
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarkBFilhos(nMRecNo,aMarks,lUnMark)

Local aArea    := GetArea()
Local aAreaAF2 := AF2->(GetArea())
Local aAreaAF5 := AF5->(GetArea())
Local cKeyAF5  := ""
Local nLen     := 0

AF2->(DbSetOrder(2))
AF5->(DbGoTo(nMRecNo))
cKeyAF5 := AF5->AF5_ORCAME + AF5->AF5_EDT

AF5->(DbSetOrder(2))
If AF5->(MsSeek(xFilial("AF5") + cKeyAF5))
	Do While !AF5->(Eof()) .And. xFilial("AF5") + ;
	  cKeyAF5 == AF5->AF5_FILIAL + AF5->AF5_ORCAME + AF5->AF5_EDTPAI

		If !lUnMark
			If AScan(aMarks, {|x| x[1] == "AF5" .And. x[2] == AF5->(RecNo())}) == 0
				AAdd(aMarks, {"AF5", AF5->(RecNo())})
			EndIf
		Else
			If (nPos := ;
			    AScan(aMarks, {|x| x[1] == "AF5" .And. x[2] == AF5->(RecNo())})) > 0
				nLen := Len(aMarks)
				ADel(aMarks, nPos)
				ASize(aMarks, nLen - 1)
				nLen := Len(aMarks)
			EndIf
		EndIf
		MarkBFilhos(AF5->(RecNo()), @aMarks, lUnMark)
		AF5->(DbSkip())
	EndDo
EndIf

If AF2->(MsSeek(xFilial("AF2") + cKeyAF5))
	Do While !AF2->(Eof()) .And. xFilial("AF2") + ;
		cKeyAF5 == AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_EDTPAI

		If !lUnMark
			If AScan(aMarks, {|x| x[1] == "AF2" .And. x[2] == AF2->(RecNo())}) == 0
				AAdd(aMarks, {"AF2", AF2->(RecNo())})
			EndIf
		Else
			If (nPos := ;
			    AScan(aMarks,{|x| x[1] == "AF2" .And. x[2] == AF2->(RecNo())})) > 0
				nLen := Len(aMarks)
				ADel(aMarks, nPos)
				ASize(aMarks, nLen-1)
				nLen := Len(aMarks)
			EndIf
		EndIf
		AF2->(DbSkip())
	EndDo

EndIf

AF5->(RestArea(aAreaAF5))
AF2->(RestArea(aAreaAF2))
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
‘‘ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»‘‘
‘‘ºPrograma  ³UnMarkPai ºAutor  ³Carlos A. Gomes Jr. º Data ³  10/16/06   º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºDesc.     ³Funcoes de copia selecionada de projeto.                    º‘‘
‘‘ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹‘‘
‘‘ºUso       ³ Melhoria Fabrica.                                          º‘‘
‘‘ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼‘‘
‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘‘
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function UnMarkBPai(cMAlias,nMRecNo,aMarks)

Local aArea    := GetArea()
Local aAreaAF2 := AF2->(GetArea())
Local aAreaAF5 := AF5->(GetArea())
Local lCont    := .T.
Local nCont    := 0
Local cKey     := ""
Local nLen     := Len(aMarks)

If cMAlias == "AF2"
	AF2->(DbGoTo(nMRecNo))
	cKey := AF2->AF2_ORCAME + AF2->AF2_EDTPAI
Else
	AF5->(DbGoTo(nMRecNo))
	cKey := AF5->AF5_ORCAME + AF5->AF5_EDTPAI
EndIf

AF2->(DbSetOrder(2))
If AF2->(MsSeek(xFilial("AF2") + cKey))
	Do While lCont .And. !AF2->(Eof()) .And. xFilial("AF2") + cKey == ;
	  AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_EDTPAI

		lCont := (AScan(aMarks, {|x| x[1] == "AF2" .And. x[2] == AF2->(RecNo())}) == 0)
		AF2->(DbSkip())
	EndDo
EndIf

AF5->(DbSetOrder(2))
If lCont .And. AF5->(MsSeek(xFilial("AF5") + cKey))
 	Do While lCont .And. !AF5->(Eof()) .And. xFilial("AF5") + cKey == ;
	  AF5->AF5_FILIAL + AF5->AF5_ORCAME + AF5->AF5_EDTPAI

		lCont := (AScan(aMarks, {|x| x[1] == "AF5" .And. x[2] == AF5->(RecNo())}) == 0)
		AF5->(DbSkip())
    EndDo
EndIf

AF5->(DbSetOrder(1))
If lCont .And. AF5->(MsSeek(xFilial("AF5") + cKey))
	If (nCont := ;
	  AScan(aMarks, {|x| x[1] == "AF5" .And. x[2] == AF5->(RecNo()) })) > 0
		ADel(aMarks, nCont)
		ASize(aMarks, nLen - 1)
		If !Empty(AF5->AF5_EDTPAI)
			UnMarkBPai("AF5", AF5->(RecNo()), @aMarks)
		EndIf
	EndIf
EndIf

AF5->(RestArea(aAreaAF5))
AF2->(RestArea(aAreaAF2))
RestArea(aArea)

Return

/* ----------------------------------------------------------------------------

PmsCreateMenu()

Esta função cria um array aRotina "falso" para utilização em funções que
necessitem do mesmo, porém não existe. Ele é necessário por causa das funções
MenuDef().

Devolve um array com informações necessárias para aRotina, porém este array
não possui a chamada de nenhuma função.

Utilizar esta função toda vez que for necessário criar um array aRotina.

---------------------------------------------------------------------------- */

Function PmsCreateMenu()
	Local aRotina := {{"Pesquisar", "AxPesqui", 0, 1}, ;
	                  {"Visualizar", "", 0, 2}, ;
	                  {"Incluir", "", 0, 3}, ;
	                  {"Alterar", "", 0, 4}, ;
	                  {"Excluir", "", 0, 5}, ;
	                  {"Legenda", "", 0, 6}}
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSFreeObjºAutor  ³Reynaldo Miyashita  º Data ³  08/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ destroi todos os objetos filhos e o proprio objeto         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsFreeObj(oObj)

	// se for um objeto, deve destrui-lo
	If ValType(oObj) == "O"
		oObj:FreeChildren()
		oObj:Free()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS1DtRlz ºAutor  ³Reynaldo Miyashita  º Data ³  16/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ retorna a data de inicio realizado da EDT, caso não        º±±
±±º          ³ encontre busca pela sua EDT PAI.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS1DtRlz(cProjeto,cRevisa,cEdt)
Local d1Rlz := stod("")
Local aArea:= GetArea()
Local aAreaAFC:= AFC->(GetArea())

	dbSelectArea("AFC")
	dbSetOrder(1)
	If dbSeek(xFilial("AFC")+cProjeto+cRevisa+cEdt)
		d1Rlz := AFC->AFC_DTATUI
		If Empty(d1Rlz)
			d1Rlz := PMS1DtRlz(cProjeto,cRevisa,AFC->AFC_EDTPAI)
		EndIf
	Else
		d1Rlz := ctod("01/01/1980")
	EndIf

	RestArea(aAreaAFC)
	RestArea(aArea)

Return d1Rlz

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAtuDtTskºAutor  ³Pedro Pereira Lima  º Data ³  15/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exp1: Projeto                                               º±±
±±º          ³ Exp2: Tarefa                                                º±±
±±º          ³ Exp3: Data Fim                                              º±±
±±º          ³ Exp4: Hora Fim                                              º±±
±±º          ³ Exp5: Duracao                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SSIM-83 (QNC)                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAtuDtTsk(cProjeto,cTarefa,dFinish,cHoraF,nDuracao)
Local aAreaAF8 := AF8->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aArea		:= GetArea()
Local aAuxRet

dbSelectArea("AF8")
dbSetOrder(1)

If dbSeek(xFilial("AF8")+cProjeto) //Posiciono AF8 para pegar versao

	dbSelectArea("AF9")
	dbSetOrder(1)

	If dbSeek(xFilial("AF9")+cProjeto+AF8->AF8_REVISA+cTarefa) //	Posiciono AF9 para pegar calendario e para gravar

		If cHoraF == Nil
			cHoraF := "24:00"
		EndIf

	   If nDuracao == Nil
			nDuracao 	:= AF9->AF9_HDURAC
    	EndIf

		aAuxRet	:= PMSDTaskI(dFinish,cHoraF,AF9->AF9_CALEND,@nDuracao,AF9->AF9_PROJET,Nil)
		AAdd(aAuxRet,nDuracao)

		Reclock("AF9",.F.)
			AF9->AF9_START := aAuxRet[1]
			AF9->AF9_HORAI := aAuxRet[2]
			AF9->AF9_FINISH:= aAuxRet[3]
			AF9->AF9_HORAF := aAuxRet[4]
			AF9->AF9_DURAC := aAuxRet[5]
		MsUnlock()
		//Verificar parametros da avaltrf
		PmsAvalTrf("AF9",1,,.T.,!IsAuto())
	EndIf
EndIf

RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)

Return aAuxRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF9BOF³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AF9.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAF9BOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AF9")+cBofF3AF9,cBofF3AF9)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF9EOF³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AF9.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAF9EOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AF9")+cEofF3AF9,cEofF3AF9)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFCBOF³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AFC.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFCBOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AFC")+cBofF3AFC,cBofF3AFC)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAFCEOF³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AFC.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFCEOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AFC")+cEofF3AFC,cEofF3AFC)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF2BOF³ Autor ³ Wagner Mobile Costa    ³ Data ³ 02-08-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AF2.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAF2BOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AF2")+cBofF3AF2,cBofF3AF2)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAF2EOF³ Autor ³ Wagner Mobile Costa    ³ Data ³ 02-08-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AF2.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAF2EOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AF2")+cEofF3AF2,cEofF3AF2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsIncAFT ºAutor  ³Clovis Magenta		  º Data ³  20/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz tratativa da substituicao de titulos PR no financeiro  º±±
±±º          ³ para saber se existe vinculo com tabela AFT                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsIncAFT()
Local aArea:= GetArea()
Local aAreaAFT:=AFT->(GetArea())
Local cProjeto
Local cRevisa
Local cEdt
Local cTarefa
Local cEvento
Local aRet := {}

dbSelectArea("AFT")
dbSetOrder(2)//AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA
If dbSeek(xFilial("AFT")+ __SUBS->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.T.)

	cRevisa := PmsAF8Ver(AFT->AFT_PROJET)

	AFT->(dbSetOrder(2))
	If dbSeek(xFilial("AFT")+ __SUBS->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+AFT->(AFT_PROJET+cRevisa+AFT_TAREFA))

		cProjeto		:= AFT->AFT_PROJET
		cRevisa		:= AFT->AFT_REVISA
		cEdt			:= AFT->AFT_EDT
		cTarefa		:= AFT->AFT_TAREFA
		cEvento		:= AFT->AFT_EVENTO

		Reclock("AFT" ,.F.)
			AFT->(dbDelete())
		AFT->(MsUnlock())

		aAdd(aRet,xFilial("AFT"))
		aAdd(aRet,cProjeto)
		aAdd(aRet,cRevisa)
		aAdd(aRet,cEdt)
		aAdd(aRet,cTarefa)
		aAdd(aRet,SE1->E1_PREFIXO)
		aAdd(aRet,SE1->E1_NUM)
		aAdd(aRet,SE1->E1_PARCELA)
		aAdd(aRet,SE1->E1_TIPO)
		aAdd(aRet,SE1->E1_CLIENTE)
		aAdd(aRet,SE1->E1_LOJA)
		aAdd(aRet,SE1->E1_VENCREA)
		aAdd(aRet,cEvento)
		aAdd(aRet,xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO))
		aAdd(aRet,xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,2,SE1->E1_EMISSAO))
		aAdd(aRet,xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,3,SE1->E1_EMISSAO))
		aAdd(aRet,xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,4,SE1->E1_EMISSAO))
		aAdd(aRet,xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,5,SE1->E1_EMISSAO))
	EndIf
EndIf

RestArea(aAreaAFT)
RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |PmsVldTit ºAutor  ³Clovis Magenta      º Data ³  20/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Antes de mostrar a enchoice de titulo a receber, na rotina  º±±
±±º          ³de substituicao, aqui verifica se a fase do proj aceita     º±±
±±º          ³	nOpc = 1 --> validacao FINA040, rotina de substituicao     º±±
±±º          ³ nOpc = 2 --> validacao PMSXFUN, rotina de amarraçao CP x PMS º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA040, MATXATU  	                                      	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsVldTit(nOpc)
Local aSaveArea:= GetArea()
Local cProjeto
Local cRevisa
Local lRet := .T.
Local cAliasQry:= "SF1TMP"+GetNextAlias()
Local cQuery   := ""

Default nOpc := 1

If nOpc == 1
	dbSelectArea("AFT")
	dbSetOrder(2)//AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA
	If dbSeek(xFilial("SE1")+ __SUBS->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))

		cProjeto := AFT->AFT_PROJET
		cRevisa	 := AFT->AFT_REVISA

		lRet := PmsVldFase("AF8",cProjeto, "85")
	EndIf
Else

	cQuery	:= "SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_PREFIXO "
	cQuery	+= "  FROM "+RetSqlName("SF1")
	cQuery	+= " WHERE F1_FILIAL  = '"+xFilial("SF1")+"'"
	cQuery	+= "   AND F1_DOC     = '"+M->E2_NUM+"'"
	cQuery += "   AND F1_PREFIXO = '"+M->E2_PREFIXO+"'"
	cQuery += "   AND F1_FORNECE = '"+M->E2_FORNECE+"'"
	cQuery += "   AND F1_LOJA    = '"+M->E2_LOJA+"'"
	cQuery	+= "   AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_PREFIXO "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T. , .T. )

	If !((cAliasQry)->(EOF()))
		dbSelectArea("AFN")
		dbSetOrder(2)//AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA
		If dbSeek(xFilial("AFN")+M->E2_NUM+(cAliasQry)->F1_SERIE+M->E2_FORNECE+M->E2_LOJA)
			lRet := .F.
		ElseIf cPaisLoc <> "BRA" .and. "MATA" $ M->E2_ORIGEM  // tratamento para factura amarrada a remito com SIGAPMS
			dbSelectArea("SD1")
			dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If dbSeek(xFilial("SD1")+M->E2_NUM+(cAliasQry)->F1_SERIE+M->E2_FORNECE+M->E2_LOJA)
				While SD1->(!EOF()) .AND. (xFilial("SD1")+M->E2_NUM+(cAliasQry)->F1_SERIE+M->E2_FORNECE+M->E2_LOJA)==;
						SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

					If !Empty(D1_REMITO)
						dbSelectArea("AFN")
						dbSetOrder(2)//AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA
						If dbSeek(xFilial("AFN")+SD1->(D1_REMITO+D1_SERIREM+D1_FORNECE+D1_LOJA) )
							lRet := .F.
							Exit
						Endif
					Endif

					dbSelectArea("SD1")
					SD1->(dbSkip())
				EndDo
			Endif
		EndIf
	EndIf
Endif
RestArea(aSaveArea)
If	Select(cAliasQry) > 0
	(cAliasQry)->(dBCloseArea())
EndIf
Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |PmsVerAFT ºAutor  ³CLOVIS MAGENTA      º Data ³  20/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o titulo em questao no financeiro esta atreladoº±±
±±º          ³ a algum projeto                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION PmsVerAFT()
Local aSaveArea:= GetArea()
Local lRet := .F.

dbSelectArea("AFT")
dbSetOrder(2)//AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA
If dbSeek(xFilial("AFT")+ __SUBS->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.T.)
	lRet:= .T.
EndIf

RestArea(aSaveArea)

Return(lRet)

// Funcoes trazidas do pmsxfun

Function PMSEDTPoc(lExistTask, lExistMile, nTotTasks, nTotMilestones, lAllMileComp)

	Local nTotCompleted := 0

	// neste ponto, nTotMilestones
	// contém o percentual total apontado em tarefas/EDTs milestones
	// e nTotTasks contém o total apontado em tarefas/EDTs normais
	//AFQ->AFQ_QUANT  := AFC->AFC_QUANT * nPercAtu
	Do Case

		// existem milestones e tarefas
		Case lExistTask .And. lExistMile

			// todas as tarefas estão 100% porém os milestones não
			If nTotTasks >= 1 .And. ;
			   (nTotMilestones > 0 .And. nTotMilestones < 1)
				nTotCompleted := nTotTasks - (nTotTasks * 0.01)
			Else

				// nem todas as tarefas estão completas
				// (ignora os milestones)
				If nTotTasks > 0 .And. nTotTasks < 1
					nTotCompleted := nTotTasks
				Else

					// todas as tarefas e milestones estão completos
					If nTotTasks >= 1 .And. nTotMilestones >= 1
						nTotCompleted := 1
					EndIf
				EndIf
			EndIf
//			ConOut("--------------------------------")
//      ConOut("nTotTasks     : " + Str(nTotTasks))
//			ConOut("nTotMilestones: " + Str(nTotMilestones))
//			ConOut("Existem milestones e tarefas")

		// existem apenas milestones
		Case lExistMile .And. !lExistTask

			If nTotMilestones > 0 .And. nTotMilestones < 1
				nTotCompleted := 0
			Else
				If nTotMilestones > 1
					If lAllMileComp
						nTotCompleted := 1
					Else
						nTotCompleted := 0
					EndIf


				EndIf
			EndIf

//			ConOut("--------------------------------")
//			ConOut("nTotTasks     : " + Str(nTotTasks))
//			ConOut("nTotMilestones: " + Str(nTotMilestones))
//			ConOut("Existem apenas milestones")

		// existem apenas tarefas
		Case lExistTask .And. !lExistMile

			nTotCompleted := nTotTasks

//			ConOut("--------------------------------")
//			ConOut("nTotTasks     : " + Str(nTotTasks))
//			ConOut("nTotMilestones: " + Str(nTotMilestones))
//			ConOut("Existem apenas tarefas")

		// não foi identificado
		Otherwise
			nTotCompleted := 0

//			ConOut("--------------------------------")
//			ConOut("nTotTasks     : " + Str(nTotTasks))
//			ConOut("nTotMilestones: " + Str(nTotMilestones))
//			ConOut("Outra coisa")

	EndCase

Return nTotCompleted

/* ----------------------------------------------------------------------------

PmsAFHExists()

Verifica se existem registros na tabela AFH, a partir do número da Solicitação
ao Armazém cNumSA e do item da Solicitação ao Armazém.

Devolve verdadeiro se for encontrado algum registro e falso caso não for
encontrado.

Esta função não utiliza softseek para efetuar a procura.

---------------------------------------------------------------------------- */

Function PmsAFHExists(cNumSa, cItemSa)
	Local aArea := GetArea()
	Local aAreaAFH := AFH->(GetArea())

	Local lRet := .F.

	dbSelectArea("AFH")
	AFH->(dbSetOrder(2))
	lRet := AFH->(MsSeek(xFilial() + cNumSa + cItemSa))

	RestArea(aAreaAFH)
	RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSRgToExp  ³ Autor ³ Bruno Sobieski      ³ Data ³ 23-01-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte o string de Range em uma expressao ADVPL ou SQL.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSRgToExp(cCampo,cRange,lSql,cFilIni,cFilFim)
Local cRet	:=	""
Local aRet	:=	{}
Local nX
Local nSize	:=	TamSX3(cCampo)[1]
cFilIni	:=	Space(nSize)
cFilfim	:=	Replicate("z",nSize)
Default lSql	:=	.F.
If Empty(cRange)
	Return ""
Endif

While !Empty(cRange)
	cDe		:=	Substr(cRange,1,nSize)
	cAte	:=	Substr(cRange,nSize+3,nSize)
	AAdd(aRet,{cDe,cAte})
	cRange	:=	Substr(cRange,(nSize*2)+4)
Enddo

cRet	+=	"( "
For nX:=1 To Len(aRet)
	If aRet[nX,1] < cFilIni
		cFilIni := aRet[nX,1]
	Endif
	If aRet[nX,2] < cFilIni
		cFilIni := aRet[nX,2]
	Endif
	If aRet[nX,1] > cFilFim
		cFilFim := aRet[nX,1]
	Endif
	If aRet[nX,2] > cFilFim
		cFilFim := aRet[nX,2]
	Endif
	If lSql
		If aRet[nX ,01] == aRet[nX ,02]
			cRet	+=	cCampo + " = '"+aRet[nX,1]+"' "
		Else
			cRet	+=	cCampo + " BETWEEN '"+aRet[nX,1]+ "' AND '"+aRet[nX,2]+"' "
		EndIf
		If nX+1 <= Len(aRet)
			cRet += " OR "
		Endif
	Else
		cRet	+=	"("+cCampo + " >= '"+aRet[nX,1]+ "' .AND. "+cCampo+"<= '"+aRet[nX,2]+"') "
		If nX+1 <= Len(aRet)
			cRet += " .Or. "
		Endif
	Endif
Next
cRet	+= " ) "

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSXFUNB  ºAutor  ³Clovis Magenta      º Data ³  01/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusao da amarracao PMS x Devolucao de remito (compras)   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSINCSD2(cAliasSD2,cProjPMS,cRevisa,cEDTPMS,nQuant,cTask)

Local lPmsInt:= IsIntegTop(,.T.)
SF4->(dbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
AF8->(dbSetOrder(1))
AF8->(MsSeek(xFilial("AF8")+cProjPMS))
dbSelectArea("AFS")
dbSetOrder(2)

//MATA102DN Conduce de Dev SIGACOM. Campo qtde nao e carregado no aHeader tabela AFS, entao assume D2_QUANT
If Empty(nQuant)
	nQuant := (cAliasSD2)->D2_QUANT
EndIf

If MsSeek(xFilial("AFS")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_LOCAL+DTOS((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_NUMSEQ+cProjPMS+cRevisa+cTask)
	RecLock("AFS",.F.)
Else
	RecLock("AFS",.T.)
EndIf
AFS->AFS_FILIAL	:= xFilial("AFS")
AFS->AFS_DOC	:= (cAliasSD2)->D2_DOC
//AFS->AFS_SERIE	:= (cAliasSD2)->D2_SERIE
SerieNfId("AFS", 1, "AFS_SERIE", (cAliasSD2)->D2_EMISSAO, (cAliasSD2)->D2_ESPECIE, (cAliasSD2)->D2_SERIE)
AFS->AFS_PROJET	:= cProjPMS
AFS->AFS_TAREFA	:= cTask
AFS->AFS_REVISA	:= AF8->AF8_REVISA
AFS->AFS_COD	:= (cAliasSD2)->D2_COD
AFS->AFS_LOCAL	:= (cAliasSD2)->D2_LOCAL
AFS->AFS_NUMSEQ	:= (cAliasSD2)->D2_NUMSEQ
AFS->AFS_EMISSAO:= (cAliasSD2)->D2_EMISSAO
AFS->AFS_QUANT	:= nQuant
AFS->AFS_MOVPRJ	:= SF4->F4_MOVPRJ
AFS->AFS_EDT:= cEdtPMS
AFS->AFS_TRT  := ""

MsUnlock()

SF4->(dbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
If SF4->F4_MOVPRJ $ "25"

	// verifica se ja foi baixado na liberacao do pedido ou na geracao de remito
	If Empty((cAliasSD2)->D2_PEDIDO) .And. ((cAliasSD2)->(ColumnPos('D2_REMITO')) == 0;
	   .Or. Empty((cAliasSD2)->D2_REMITO) ) .and. IIf( lPmsInt, .T., (SF4->F4_ESTOQUE == "S"))
//	   .Or. Empty((cAliasSD2)->D2_REMITO) ) .and. SF4->F4_ESTOQUE == "S"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a baixa dos empenhos do Projeto               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PmsBxEmp(AFS_PROJET,AFS_TAREFA,(cAliasSD2)->D2_COD,(cAliasSD2)->D2_LOCAL,AFS_QUANT,"-",AFS_QTSEGU,AFS_TRT)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os valores da Tarefa                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AF9AtuCD2(1,{(cAliasSD2)->D2_CUSTO1,(cAliasSD2)->D2_CUSTO2,(cAliasSD2)->D2_CUSTO3,(cAliasSD2)->D2_CUSTO4,(cAliasSD2)->D2_CUSTO5})

	/////////////////////////////////////////////////////////////////
	//
	// Integração com TOP, gera a apropriacao para o projeto.
	//
	/////////////////////////////////////////////////////////////////
	SLMPMSCOST(0, "AFS", (cAliasSD2)->D2_EMISSAO, AFS->AFS_PROJET, AFS->AFS_TAREFA, AFS->AFS_COD, AFS->AFS_QUANT, (cAliasSD2)->D2_CUSTO1/(cAliasSD2)->D2_QUANT)
	/////////////////////////////////////////////////////////////////
EndIf

If Existblock("PMSNFINC")
	Execblock("PMSNFINC", .F., .F., {cProjPMS, cEDTPMS, cTask})
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSCalcReq³ Autor ³ Reynaldo Miyashita    ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula as necessidades de materias para o projeto.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCalcReq(cProjeto, cRevisa, cTarefa, aTmpProd)
Local aArea    := GetArea()
Local aAreaAFG := {}
Local aAreaAJ7 := {}
Local aAreaAJC := {}
Local aAreaAFN := {}
Local aAreaAFI := {}
Local aAreaAFJ := {}
Local nQtdReq  := 0
Local nCnt     := 0
Local nLoop    := 0
Local nPos     := 0

//
// Este loop tem a finalidade abater as quantidades previstas com as quantidades requisitas
//
For nCnt := 1 To Len(aTmpProd)

	cProduto := aTmpProd[nCnt,01]
	nQtdReq := 0

	aProdReq := {}
	//
	// Projeto x solicitacao de compra **tem data de necessidade
	//
	dbSelectArea("AFG")
	aAreaAFG := AFG->(GetArea())
	DbSetOrder(5)
	DbSeek(xFilial('AFG')+cProjeto+cRevisa+cTarefa+cProduto )
	While !AFG->(Eof()) .And.xFilial('AFG')+cProjeto+cRevisa+cTarefa+cProduto == ;
				AFG->(AFG_FILIAL+AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_COD)
		//
		// Busca pela solicitacao de compra
		dbSelectArea("SC1")
		dbSetOrder(1)
		If dbSeek(xFilial('SC1')+AFG->AFG_NUMSC+AFG->AFG_ITEMSC)

			If (nPos := aScan(aProdReq ,{|x|x[1]==SC1->C1_DATPRF})) >0
				aProdReq[nPos ,02] += AFG->AFG_QUANT
			Else
				aAdd(aProdReq ,{SC1->C1_DATPRF ,AFG->AFG_QUANT})
			EndIF

		EndIf
		dbSelectArea("AFG")
		DbSkip()
	Enddo
	RestArea(aAreaAFG)

	For nLoop := 1 to len(aProdReq)
		//
		nQtdReq := PMSPrdCalc(aTmpProd[nCnt], aProdReq[nLoop,1],nQtdReq+aProdReq[nLoop,2] )

	Next nLoop

	aProdReq := {}
	//
	// Projeto x Pedido de compra **tem data de entrega = necessidade
	//
	dbSelectArea("AJ7")
	aAreaAJ7 := AJ7->(GetArea())
	DbSetOrder(1) //AFJ_FILIAL+AFJ_PROJET+AFJ_REVISA+AFJ_TAREFA+AFJ_NUMPC+AFJ_ITEMPC
	DbSeek(xFilial('AJ7')+cProjeto+cRevisa+cTarefa+cProduto )
	While !AJ7->(Eof()) .And.xFilial('AJ7')+cProjeto+cRevisa+cTarefa == ;
				AJ7->(AJ7_FILIAL+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA)
		If AJ7->AJ7_COD==cProduto
			//
			// Busca pela pedido de compra
			dbSelectArea("SC7")
			dbSetOrder(1)
			If dbSeek(xFilial('SC7')+AJ7->AJ7_NUMPC+AJ7->AJ7_ITEMPC)
				If (nPos := aScan(aProdReq ,{|x|x[1]==SC7->C7_DATPRF})) >0
					aProdReq[nPos ,2] += AJ7->AJ7_QUANT
				Else
					aAdd(aProdReq ,{SC7->C7_DATPRF ,AJ7->AJ7_QUANT})
				EndIf
			EndIf

		EndIf

		dbSelectArea("AJ7")
		DbSkip()
	Enddo
	RestArea(aAreaAJ7)

	For nLoop := 1 to len(aProdReq)
		//
		nQtdReq := PMSPrdCalc(aTmpProd[nCnt], aProdReq[nLoop,1],nQtdReq+aProdReq[nLoop,2] )

	Next nLoop

	aProdReq := {}
	//
	// Projeto x Empenho Manual **tem data de empenho
	//
	dbSelectArea("AFJ")
	aAreaAFJ := AFJ->(GetArea())
	DbSetOrder(1) //AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL
	DbSeek(xFilial('AFJ')+cProjeto+cTarefa+cProduto)
	While !AFJ->(Eof()) .And.xFilial('AFJ')+cProjeto+cTarefa+cProduto == ;
				AFJ->(AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD)
		//
		// Se foi de um planejamento ou manual informa que obteve do estoque
		If AFJ->AFJ_ROTGER == "4" .OR. (AFJ->AFJ_ROTGER == "5" .OR. Empty(AFJ->AFJ_ROTGER))
			If (nPos := aScan(aProdReq ,{|x|x[1]==AFJ->AFJ_DATA})) >0
				aProdReq[nPos ,2] += AFJ->AFJ_QEMP - AFJ->AFJ_QATU - AFJ->AFJ_EMPEST
			Else
				aAdd(aProdReq ,{AFJ->AFJ_DATA ,AFJ->AFJ_QEMP - AFJ->AFJ_QATU - AFJ->AFJ_EMPEST})
			EndIf
		EndIf

		dbSelectArea("AFJ")
		DbSkip()
	Enddo

	RestArea(aAreaAFJ)

	For nLoop := 1 to len(aProdReq)
		//
		nQtdReq := PMSPrdCalc(aTmpProd[nCnt], aProdReq[nLoop,1],nQtdReq+aProdReq[nLoop,2] )

	Next nLoop

	//
	// Apontamento direto do projeto
	//
	dbSelectArea("AJC")
	aAreaAJC := AJC->(GetArea())
	DbSetOrder(1) //AJC_FILIAL+AJC_PROJET+AJC_REVISA+AJC_TAREFA+DTOS(AJC_DATA)
	DbSeek(xFilial('AJC')+"2"+cProjeto+cRevisa+cTarefa+cProduto)
	While !AJC->(Eof()) .And.xFilial('AJC')+cProjeto+cRevisa+cTarefa == ;
				AJC->(AJC_FILIAL+AJC_PROJET+AJC_REVISA+AJC_TAREFA)
		If AJC->AJC_TIPO=="1" .AND. AJC->AJC_COD==cProduto
			nQtdReq += AJC->AJC_QUANT
		EndIf
		DbSkip()
	Enddo
	RestArea(aAreaAJC)

	//
	nQtdReq := PMSPrdCalc(aTmpProd[nCnt],, nQtdReq )

	//
	// Projeto x Documento de entrada
	//
	dbSelectArea("AFN")
	aAreaAFN := AFN->(GetArea())
	DbSetOrder(1) //AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM
	DbSeek(xFilial('AFN')+"2"+cProjeto+cRevisa+cTarefa+cProduto)
	While !AFN->(Eof()) .And.xFilial('AFN')+cProjeto+cRevisa+cTarefa == ;
				AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA)
		If AFN->AFN_TIPO=="1" .AND. AFN->AFN_COD==cProduto
			nQtdReq += AFN->AFN_QUANT
		EndIf
		DbSkip()
	Enddo
	RestArea(aAreaAFN)

	//
	nQtdReq := PMSPrdCalc(aTmpProd[nCnt],, nQtdReq )

	//
	// Projeto x Movimento interno
	//
	dbSelectArea("AFI")
	aAreaAFI := AFI->(GetArea())
	DbSetOrder(1) //AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA+AFI_COD+AFI_LOCAL+DTOS(AFI_EMISSA)+AFI_NUMSEQ
	DbSeek(xFilial('AFI')+cProjeto+cRevisa+cTarefa+cProduto)
	While !AFI->(Eof()) .And.xFilial('AFI')+cProjeto+cRevisa+cTarefa+cProduto == ;
				AFI->(AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA+AFI_COD)

		nQtdReq += AFI->AFI_QUANT
		DbSkip()
	Enddo
	RestArea(aAreaAFI)

	//
	nQtdReq := PMSPrdCalc(aTmpProd[nCnt],, nQtdReq )

Next nCnt

RestArea(aArea)


Return nQtdReq

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSPrdCalc³ Autor ³ Reynaldo Miyashita    ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula se as necessidades foram atendidas.                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSPrdCalc(aProdNec, dNecess, nQtdReq )
Local nCntIt  := 0
Local nCntIt2 := 0

DEFAULT dNecess := STOD("")

	If nQtdReq >0
		If (nPos := aScan(aProdNec[03] ,{|x|x[1]==dNecess})) >0
			// existe quantidade prevista
			If aProdNec[03,nPos,02] >0
				// se a quantidade total requisitada para a data de necessidade é superior que a prevista para o produto na tarefa
				// zera a quantidade prevista
				If aProdNec[03,nPos,02] <= nQtdReq
					nQtdReq := nQtdReq-aProdNec[03,nPos,02]
					aProdNec[02] -= aProdNec[03,nPos,02]
					aProdNec[03,nPos,02] := 0

				// caso contrario, deve buscar por item dos produtos da tarefa.
				Else
					For nCntIt2 := 1 to len(aProdNec[03,nPos,06])
						// existe quantidade prevista
						If aProdNec[03,nPos,06,nCntIt2,01] >0
							// se a quantidade requisitada no item é superior que a prevista para o produto
							If aProdNec[03,nPos,06,nCntIt2,01] <= nQtdReq
								aProdNec[03,nPos,02] -= aProdNec[03,nPos,06,nCntIt2,01]
								aProdNec[02] -= aProdNec[03,nPos,06,nCntIt2,01]
								nQtdReq := nQtdReq-aProdNec[03,nPos,06,nCntIt2,01]
								aProdNec[03,nPos,06,nCntIt2,01] := 0

							Else
								If nQtdReq>0
									aProdNec[03,nPos,06,nCntIt2,01] -= nQtdReq
									aProdNec[03,nPos,02] -= nQtdReq
									aProdNec[02] -= nQtdReq
									nQtdReq := 0
								EndIf
							EndIf
						EndIf
					Next nCntIt2
				EndIf
			EndIf
		Else
			For nCntIt := 1 to len(aProdNec[03])
				// existe quantidade prevista
				If aProdNec[03][nCntIt,02]>0
					// se a quantidade total requisitada para a data de necessidade é superior que a prevista para o produto na tarefa
					// zera a quantidade prevista
					If aProdNec[03][nCntIt,02] <= nQtdReq
						nQtdReq := nQtdReq-aProdNec[03][nCntIt,02]
						aProdNec[02] -= aProdNec[03,nCntIt,02]
						aProdNec[03,nCntIt,02] := 0

					// caso contrario, deve buscar por item dos produtos da tarefa.
					Else
						For nCntIt2 := 1 to len(aProdNec[03,nCntIt,06])
							// existe quantidade prevista
							If aProdNec[03,nCntIt,06,nCntIt2,01] >0
								// se a quantidade requisitada no item é superior que a prevista para o produto
								If aProdNec[03,nCntIt,06,nCntIt2,01] <= nQtdReq
									aProdNec[03,nCntIt,02] -= aProdNec[03,nCntIt,06,nCntIt2,01]
									aProdNec[02] -= aProdNec[03,nCntIt,06,nCntIt2,01]
									nQtdReq := nQtdReq-aProdNec[03,nCntIt,06,nCntIt2,01]
									aProdNec[03,nCntIt,06,nCntIt2,01] := 0

								Else
									If nQtdReq>0
										aProdNec[03,nCntIt,06,nCntIt2,01] -= nQtdReq
										aProdNec[03,nCntIt,02] -= nQtdReq
										aProdNec[02] -= nQtdReq
										nQtdReq := 0
									EndIf
								EndIf
						    EndIf
						Next nCntIt2
					EndIf
				EndIf
			Next nCntIt
		EndIf
	EndIf
Return nQtdReq

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSRangeDesc³ Autor ³ Bruno Sobieski      ³ Data ³ 23-01-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte a expressao de range para formato amigavel           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSRangeDesc(cRange,nSize)
Local cRet	:=	""
//Formato fixo cDe..cAte;cDe2..cAte2; com cDe e cAte com tamanho fixo
If !Empty(cRange)
	While !Empty(cRange)
		cDe		:=	Substr(cRange,1,nSize)
		cAte	:=	Substr(cRange,nSize+3,nSize)
		cRet	+=	"De: "+cDe+" Ate: "+cAte
		cRange	:=	Substr(cRange,(nSize*2)+4)
		If !Empty(cRange)
			cRet +=" ou "+Chr(13)+Chr(10)
		Endif
	Enddo
Endif
Return	cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSReadValue³ Autor ³ Reynaldo Miyashita  ³ Data ³ 20-03-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza uma procura no arquivo de banco de dados utilizando   ³±±
±±³ o alias especificado por cAlias, índice de ordem nOrder. Os valores     ³±±
±±³ para pesquisa (parciais ou totais) estão armazenados em cKey.           ³±±
±±³                                                                         ³±±
±±³ Devolve o valor especificado pelo campo cField se o registro for        ³±±
±±³ encontrado, caso contrário, devolve xDefValue se especificado ou,       ³±±
±±³ finalmente, devolve Nil.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Mata103                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSReadValue(cAlias, nOrder, cKey, cField, xDefValue)
	Local aArea      := GetArea()
	Local aAreaAlias := (cAlias)->(GetArea())
	Local uBuffer    := Nil  // valor a ser devolvido

	Default xDefValue := Nil

	uBuffer := xDefValue

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(nOrder))

	If (cAlias)->(MsSeek(cKey, .F.))
		uBuffer := (cAlias)->(FieldGet(ColumnPos(cField)))
	EndIf

	(cAlias)->(RestArea(aAreaAlias))
	RestArea(aArea)
Return uBuffer

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAtuPln2³ Autor ³ Bruno Sobieski        ³ Data ³ 16-11-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao do arquivo de trabalho de forma otimi   ³±±
±±³          ³zada, quando possivel.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAtuPln2(cRevisa,cArquivo,nNivelMax,cUsrRev,lRecno,aExpand,aConfig,lZap,cFilhos,nIndent,lRefresh)
Local nNivelAtu		:= (cArquivo)->NIVTREE
Local aArea				:= GetArea()
Local aAreaTMP
Local cEdtPai	:=	(cArquivo)->XF9_TAREFA
Local lReBuild	:=	.F.
Local cTask		:=""
Local nRecno := 0
Local lRECIND := (cArquivo)->(ColumnPos("RECIND")) > 0

DEFAULT cRevisa    := AF8->AF8_REVISA
DEFAULT nNivelMax  := 1
DEFAULT cUsrRev    := CriaVar("AF8_REVISA",.F.)
DEFAULT lRecNo     := .T.
DEFAULT aConfig    := {1, PMS_MIN_DATE, PMS_MAX_DATE}
DEFAULT cFilhos    := "AFC/AF9"
DEFAULT nIndent    := PMS_SHEET_INDENT
DEFAULT lRefresh   := .T.

CursorWait()

If lRefresh
	//Verificar qual eh a EDT onde devera serfeito o refresh
	If (cArquivo)->(Eof())
		(cArquivo)->(dbGoTo(LastRec()))
	EndIf
	((cArquivo)->ALIAS)->(MsGoTo((cArquivo)->RECNO))
	If (cArquivo)->ALIAS $ 'AFX'
		cTask		:=	AFX->AFX_EDT
		lRebuild	:=	.F.
	ElseIf (cArquivo)->ALIAS $ 'ACB'
		cTask	:=	""
		lRebuild	:=	.T.
	ElseIf (cArquivo)->ALIAS == 'AFV'
		cTask		:=	AFV->AFV_TAREFA
		AF9->(DbSetOrder(1))
		If AF9->(MsSeek(xFilial('AF9')+AFV->AFV_PROJET+AFV->AFV_REVISA+AFV->AFV_TAREFA))
			cTask		:=	AF9->AF9_EDTPAI
			lRebuild	:=	.F.
		Endif
	ElseIf (cArquivo)->ALIAS == 'AFD'
		cTask		:=	AFD->AFD_TAREFA
		AF9->(DbSetOrder(1))
		If AF9->(MsSeek(xFilial('AF9')+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA))
			cTask		:=	AF9->AF9_EDTPAI
			lRebuild	:=	.F.
		Endif
	ElseIf (cArquivo)->ALIAS == 'AFC'
		cTask		:=	AFC->AFC_EDT
	ElseIf (cArquivo)->ALIAS == 'AF9'
		cTask		:=	AF9->AF9_EDTPAI
	Endif
	//Posiciona na EDT do arquivo de trabalho para a que tem que ser feito o refresh
	If !lRebuild
		lRebuild	:=	.T.
		nRecno := (cArquivo)->(RECNO())
		(cArquivo)->(DbGoTop())
		While !(cArquivo)->(Eof())
			If (cArquivo)->XF9_TAREFA == cTask .And. (cArquivo)->ALIAS != "AF8"
				((cArquivo)->ALIAS)->(MsGoTo((cArquivo)->RECNO))
				Exit
			EndIf
			(cArquivo)->(DbSkip())
		Enddo
		If (cArquivo)->(Eof())
			(cArquivo)->(MsGoTo(nRecno))
		EndIf
	Endif
	//Se nao conseguir determinar qual EDT que deve ser remontada, remontar tudo novamente
	If lRebuild
		CursorArrow()
		RestArea(aArea)
		Return PmsAtuPlan(cRevisa,cArquivo,nNivelMax,cUsrRev,lRecno,aExpand,aConfig,lZap,cFilhos,nIndent)
	Endif
Endif
//Se vem da manutencao de usuarios ou documentos, refazer tudo
If AtIsRotina('PMS230DLG') .Or. AtIsRotina('PMSUSER') .Or.  (Type('lForceReb')== "L" .And. lForceReb)
	CursorArrow()
	Return PmsAtuPlan(cRevisa,cArquivo,nNivelMax,cUsrRev,lRecno,aExpand,aConfig,lZap,cFilhos,nIndent)
Endif
//Se nao e uma EDT, napo fazer nada no cuplo click
If (cArquivo)->ALIAS <> 'AFC' .And. !lRefresh
	CursorArrow()
	RETURN nNivelAtu
Endif


nTime := Seconds()

cRevisa := Padr(cRevisa,4)
cUsrRev	:= Padr(cUsrRev,4)

dbSelectArea(cArquivo)
aAreaTMP	:= GetArea()

// Caso a acao seja expandir (CTRLNIV == "+" ), faz o tratamento normal do array aExpand
If (aExpand != Nil) .and. (cArquivo)->CTRLNIV == "+"

	If !Empty(aExpand).And. (nPos:=aScan(aExpand,{|x|x[1]==(cArquivo)->ALIAS+(cArquivo)->XF9_TAREFA})) >0
      aExpand[nPos][2] :=.T.
	Else
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XF9_TAREFA,.T.})
	Endif
// Caso a acao seja recolher o node, deletamos este registro do array aExpand
// Sem essa parte o sistema ira entender que apos manipularmos uma EDT/Tarefa
// devera dar o Refresh() e expandir as EDT/Tarefas que fora expandidas anteriormente
elseif (aExpand != Nil) .and. (cArquivo)->CTRLNIV == "-"
	If (nPos:=aScan(aExpand,{|x|x[1]==(cArquivo)->ALIAS+(cArquivo)->XF9_TAREFA})) >0
		aDel(aExpand,nPos)
		aSize(aExpand,Len(aExpand)-1)
	EndIf
EndIf
//Se eh uma operacao de refresh, e o nodo esta fechado, nao fazer nada
If !lRefresh .And. (cArquivo)->CTRLNIV	== "+"
	RecLock(cArquivo,.F.)
	(cArquivo)->CTRLNIV	:= "-"
	MsUnLock()

	If lRECIND
		cRecPai	:=	RTrim((cArquivo)->RECIND)
	EndIf

	dbSelectArea("AFC")
	dbSetOrder(1)
	MsSeek(xFilial()+AF8->AF8_PROJET+cRevisa+cEdtPai)
	While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
						AFC->AFC_EDT==xFilial("AFC")+AF8->AF8_PROJET+cRevisa+cEdtPai
		PmsAddPlan(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,cArquivo,@nNivelAtu,nNivelMax,cUsrRev,lRecNo,@aExpand,aConfig,cFilhos,nIndent,.F.,cRecPai)
		dbSelectArea("AFC")
		dbSkip()
	EndDo
	RestArea(aAreaTmp)
ElseIf (cArquivo)->CTRLNIV	== "-"
	DbSelectArea(cArquivo)

	If lRECIND
		(cArquivo)->(DBSetOrder(1))	
		cRecPai	:=	RTrim((cArquivo)->RECIND)
		DbSeek(cRecPai)
		While Substr((cArquivo)->RECIND,1,Len(cRecPai)) == cRecPai .And. !Eof()
			If cRecPai <> Rtrim((cArquivo)->RECIND)
				RecLock(cArquivo,.F.)
				DbDelete()
				MsUnLock()
			Endif
			DbSkip()
		Enddo
	EndIf

	RestArea(aAreaTmp)
	//Se nao e um refresh, atualziado o status do NODO
	If !lRefresh
		RecLock(cArquivo,.F.)
		(cArquivo)->CTRLNIV	:= "+"
		MsUnLock()
	//Se eh um refresh, remonta o conteudo do nodo
	Else
		PmsAddPlan(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,cArquivo,@nNivelAtu,nNivelMax,cUsrRev,lRecNo,@aExpand,aConfig,cFilhos,nIndent,.F.,cRecPai)
	Endif
Endif
CursorArrow()

RestArea(aArea)

// Testa se o registro existe no arquivo temporario no caso de exclusao da ultima tarefa
If (cArquivo)->( EoF() )
	(cArquivo)->( dbGoTo( LastRec() ) )
EndIf

Return nNivelAtu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AcertaAJ4 ºAutor  ³Pedro Pereira Lima  º Data ³  09/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AcertaAJ4(cEdtPai,cProjeto,cRevisa,cTarefa,aAuxRet,cHoraI,cHoraF,dStart,dFinish,cCalend,nHDurac,nMetodo,aTarSucs)

Local aArea 	:= GetArea()
Local aAreaAJ4 := AJ4->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local nRecAF9
Local aRecsAF9:= {}

dbSelectArea("AF9")
dbSetOrder(2)
dbSeek(xFilial("AF9")+cProjeto+cRevisa+cEdtPai)
While AF9->(!EOF()) .And. xFilial("AF9")+cProjeto+cRevisa+cEdtPai == AF9->AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9->AF9_EDTPAI
	nRecAF9	:=	AF9->(Recno())
	Do Case
		Case AJ4->AJ4_TIPO=="1" //Fim no Inicio
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(dStart,cHoraI,AF8->AF8_CALEND,-AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskI(dStart,cHoraI,cCalend,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
			EndIf
		Case AJ4->AJ4_TIPO=="2" //Inicio no Inicio
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(dStart,cHoraI,AF8->AF8_CALEND,-AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskF(dStart,cHoraI,cCalend,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
			EndIf
		Case AJ4->AJ4_TIPO=="3" //Fim no Fim
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(dStart,cHoraI,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskF(dStart,cHoraI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			EndIf
		Case AJ4->AJ4_TIPO=="4" //Inicio no Fim
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(dStart,cHoraI,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskF(dStart,cHoraI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			EndIf
	EndCase

	If dStart <> CToD("31/12/2030")
		AF9->(dbGoto(nRecAF9))
			RecLock("AF9",.F.)
			AF9->AF9_START	:= aAuxRet[1]
			AF9->AF9_FINISH:= aAuxRet[3]
			AF9->AF9_HORAI	:= aAuxRet[2]
			AF9->AF9_HORAF	:= aAuxRet[4]
			MsUnlock()
			PmsAtuNec(AF9_PROJET,AF9_REVISA,AF9_TAREFA)
			AJ4->(dbSetOrder(2))
	EndIf
	aAdd(aRecsAF9, nRecAF9)
	AF9->(dbSkip())
EndDo

dbSelectArea("AFC")
dbSetOrder(2)
If dbSeek(xFilial("AFC")+cProjeto+cRevisa+cTarefa+cEdtPai)
	While AFC->(!Eof()) .And. xFilial("AFC")+cProjeto+cRevisa+cTarefa+cEdtPai == AFC->(AFC_FILIAL+AFC_PROJETO+AFC_REVISA+AFC_EDTPAI)
		AcertaAJ4(AFC->AFC_EDT,cProjeto,cRevisa,cTarefa,cEdtPai,@aAuxRet,cHoraI,cHoraF,dStart,dFinish,cCalend,nHDurac,nMetodo)
		AFC->(dbSkip())
	EndDo
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAJ4)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PredecAJ4Ok ºAutor  ³Pedro Pereira Lima  º Data ³  09/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PredecAJ4Ok(cProjeto,cRevisa,cTask,cTabTemp,nMetodo)
Local cAlias1	:=	GetNextAlias()
Local lRet	:=	.T.
Local aArea 	:= GetArea()
Local aAreaAJ4 := AJ4->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())

DbSelectArea("AF9")
DbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTask)

DbSelectArea("AFC")
DbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+AF9->AF9_EDTPAI)
If nMetodo == 2
	While Found() .And. AFC->AFC_NIVEL <> "001" .And. lRet
		AJ4->(DbSetorder(2))
		If AJ4->(MSSEEK(xFilial()+AF8->AF8_PROJET+cRevisa+AFC->AFC_EDT))
			BeginSQL ALIAS cAlias1
			SELECT COUNT(AJ4_TAREFA) CONTA FROM %TABLE:AJ4% AS AJ4
					 WHERE    AJ4_FILIAL = %EXP:xFilial("AJ4")%
			   			AND AJ4_PROJET = %EXP:cProjeto%
			   			AND AJ4_REVISA = %EXP:cRevisa%
			   			AND AJ4_PREDEC = %EXP:AFC->AFC_EDT%
			   			AND AJ4_TAREFA <> %EXP:cTask%
				   		AND AJ4.AJ4_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp% )
					  		AND AJ4.%NotDel%
	  		EndSQL
			lRet	:=	((cAlias1)->CONTA == 0	)
			dBsELECTaREA(cAlias1)
			dbCloseArea()
		Endif
		DbSelectArea("AFC")
		DbSetOrder(1)
		MsSeek(xFilial()+cProjeto+cRevisa+AFC->AFC_EDTPAI)
	Enddo
Else
	AJ4->(DbSetorder(1)) //verificar ordem
	AJ4->(MSSEEK(xFilial()+AF8->AF8_PROJET+cRevisa+cTask))
	While  xFilial("AJ4")+AF8->AF8_PROJET+cRevisa+cTask == AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_TAREFA .And.;
			 !Eof() .And. lRet

      dbSetOrder()
      dbSeek(xFilial("AFC")+cProjeto+cRevisa+AJ4_PREDEC)

	   lRet :=	PmsVerEdt(cEdt,cProjeto,cRevisa,cTabTemp)

		DbSelectArea("AJ4")
		DbSkip()
	Enddo
Endif
RestArea(aAreaAJ4)
RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVerEdt ºAutor  ³Pedro Pereira Lima  º Data ³  09/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsVerEdt(cEdt,cProjeto,cRevisa,cTabTemp)
Local cAliasX := GetNextAlias()

		BeginSQL ALIAS cAliasX
			SELECT COUNT(AF9_TAREFA) CONTA FROM
			 	WHERE  AF9_FILIAL = %EXP:xFilial("AF9")%
			   	AND AF9_PROJET = %EXP:cProjeto%
			   	AND AF9_REVISA = %EXP:cRevisa%
					AND AF9_EDTPAI = %EXP:cEdt%
					AND TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp%)
			  		AND AF9.%NotDel%
  		EndSQL
		lRet	:=	((cAliasX)->CONTA == 0	)
		dbSelectArea(cAlias1)
		dbCloseArea()

		dbSelectArea("AFC")
		dbSetOrder(2)
		While !Eof() .And. AFC_EDTPAI == cEdt .And. lRet
			 lRet :=	PmsVerEdt(cEdt,cProjeto,cRevisa,cTabTemp)
			 Dbskip()
		Enddo
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAtuSuc ºAutor  ³Pedro Pereira Lima  º Data ³  09/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Pmsxfun()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAtuSuc(cTarefa,cProjeto,cRevisa,dData,aAllEDT,nMetodo)
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFD := AFD->(GetArea())

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)

//Atualiza datas no AF9 de acordo com as sucessoras
aRetTsk := PmsRelAtu(AF9->AF9_CALEND,cProjeto,cRevisa,cTarefa,AF9->AF9_HDURAC,nMetodo)

RecLock("AF9",.F.)
	AF9->AF9_START	:= aRetTsk[1]
	AF9->AF9_FINISH:= aRetTsk[3]
	AF9->AF9_HORAI	:= aRetTsk[2]
	AF9->AF9_HORAF	:= aRetTsk[4]
MsUnlock()
If aScan(aAllEDT,AF9->AF9_EDTPAI) <= 0
	aAdd(aAllEDT,AF9->AF9_EDTPAI)
EndIf

AF9->(PmsAtuNec(AF9_PROJET,AF9_REVISA,AF9_TAREFA))

RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAtuPredºAutor  ³Pedro Pereira Lima  º Data ³  09/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Pmsxfun()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAtuPred(cTarefa,cProjeto,cRevisa,dData,aAllEDT,nMetodo)
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFD := AFD->(GetArea())

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial("AF9")+cProjeto+cRevisa+cTarefa)

//Atualiza datas no AF9 de acordo com as sucessoras
aRetTsk := PmsRelAtu(AF9->AF9_CALEND,cProjeto,cRevisa,cTarefa,AF9->AF9_HDURAC,nMetodo)

RecLock("AF9",.F.)
	AF9->AF9_START	:= aRetTsk[1]
	AF9->AF9_FINISH:= aRetTsk[3]
	AF9->AF9_HORAI	:= aRetTsk[2]
	AF9->AF9_HORAF	:= aRetTsk[4]
MsUnlock()
If aScan(aAllEDT,AF9->AF9_EDTPAI) <= 0
	aAdd(aAllEDT,AF9->AF9_EDTPAI)
EndIf

AF9->(PmsAtuNec(AF9_PROJET,AF9_REVISA,AF9_TAREFA))

RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSRELATU ºAutor  ³Pedro Pereira Lima  º Data ³  09/15/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRelAtu(cCalend,cProjeto,cRevisa,cTarefa,nHDurac,nMetodo)
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aRetSuc	:= {}

aRetSuc	:=	PMSRelAtuT(aClone(aRetSuc),cProjeto,cRevisa,cTarefa,cCalend,nHDurac,nMetodo)

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa+cTarefa)

If nMetodo == 2
	dbSelectArea("AFC")
	dbSetOrder(1)
	MsSeek(xFilial()+cProjeto+cRevisa+AF9->AF9_EDTPAI)
	cEdtPai	:=	AF9->AF9_EDTPAI
	While !AFC->(EOF()) .And. AFC->AFC_NIVEL <> "001" .AND.;
		xFilial("AFC")+cProjeto+cRevisa+cEdtPai == AFC->(AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT)
		dbSelectArea("AJ4")
		dbSetOrder(2)
		MsSeek(xFilial()+cProjeto+cRevisa+AFC->AFC_EDT)
		While !AJ4->(Eof()) .And. xFilial("AJ4")+cProjeto+cRevisa+AFC->AFC_EDT == AJ4->(AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC)
			aAreaAFC2 := AFC->(GetArea())
			aAreaAF92 := AF9->(GetArea())
			AF9->(DbSetOrder(1))
			AF9->(MsSeek(xFilial("AF9")+AJ4->(AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA)))
			aRetSuc := PmsRelAtuE(@aRetSuc,cProjeto,cRevisa,AJ4->AJ4_PREDEC,/*AF9->AF9_START*/,/*AF9->AF9_HORAI*/,/*AF9->AF9_FINISH*/,/*AF9->AF9_HORAF*/,NHDURAC,cTarefa,cCalend,nMetodo)
			RestArea(aAreaAF92)
			RestArea(aAreaAFC2)
			AJ4->(DbSkip())
		EndDo
		dbSelectArea("AFC")
		dbSetOrder(1)
		MsSeek(xFilial()+cProjeto+cRevisa+AFC->AFC_EDTPAI)
		cEdtPai	:=	AFC->AFC_EDT
	Enddo
Else
	aRetSuc := PmsRelAtuE(@aRetSuc,cProjeto,cRevisa,AJ4->AJ4_PREDEC,/*AF9->AF9_START*/,/*AF9->AF9_HORAI*/,/*AF9->AF9_FINISH*/,/*AF9->AF9_HORAF*/,nHDurac,cTarefa,cCalend,nMetodo)
Endif

RestArea(aAreaAF9)
RestArea(aAreaAF8)
RestArea(aArea)
Return(aRetSuc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsRelAtuEºAutor  ³Pedro Pereira Lima  º Data ³  09/17/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRelAtuE(aRetSuc,cProjeto,cRevisa,cEDTPAI,dDataI,cHoraI,dDataF,cHoraF,nHDurac,cTarefa,cCalend,nMetodo)
Local aArea		:= GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())

If nMetodo == 2
	Do Case
		Case AJ4->AJ4_TIPO=="1" //Fim no Inicio
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,-AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskI(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			EndIf
		Case AJ4->AJ4_TIPO=="2" //Inicio no Inicio
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskF(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			EndIf
		Case AJ4->AJ4_TIPO=="3" //Fim no Fim
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskI(AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			EndIf
		Case AJ4->AJ4_TIPO=="4" //Inicio no Fim
			If !Empty(AJ4->AJ4_HRETAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
				aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
			Else
				aAuxRet := PMSDTaskI(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AFC->AFC_PROJET,Nil)
			EndIf
	EndCase
	If Empty(aRetSuc) .Or. ;
			(aAuxRet[1] < aRetSuc[1] .Or. ;
								(aAuxRet[1] == aRetSuc[1] .And. aAuxRet[2] < aRetSuc[2]) ;
			)
		aRetSuc := aClone(aAuxRet)
	Endif
Else
	DbSelectArea("AF9")
	DbSetOrder(2)
	DbSeek(xFilial()+cProjeto+cRevisa+cEDTPAI)
	While !AF9->(Eof()) .And. xFilial("AF9")+cProjeto+cRevisa+cEDTPAI == AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI
//		If AF9->AF9_TAREFA <> cTarefa
		aRetSuc	:=	PMSRelAtuT(aClone(aRetSuc),cProjeto,cRevisa,AF9->AF9_TAREFA,cCalend,nHDurac,nMetodo)
//		Endif
		Do Case
			Case AJ4->AJ4_TIPO=="1" //Fim no Inicio
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,nHDURAC,AF9->AF9_PROJET,Nil)
				EndIf
			Case AJ4->AJ4_TIPO=="2" //Inicio no Inicio
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDURAC,AF9->AF9_PROJET,Nil)
				EndIf
			Case AJ4->AJ4_TIPO=="3" //Fim no Fim
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AJ4->AJ4_TIPO=="4" //Inicio no Fim
				If !Empty(AJ4->AJ4_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AJ4->AJ4_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
	  	EndCase
		If Empty(aRetSuc) .Or. ;
				(aAuxRet[1] < aRetSuc[1] .Or. ;
									(aAuxRet[1] == aRetSuc[1] .And. aAuxRet[2] < aRetSuc[2]) ;
				)
			aRetSuc := aClone(aAuxRet)
		Endif
		DbSelectArea("AF9")
		DbSkip()
	Enddo
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)
Return aRetSuc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsRelAtuTºAutor  ³Pedro Pereira Lima  º Data ³  09/17/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSRelAtuT(aRetSuc,cProjeto,cRevisa,cTarefa,cCalend,nHDurac,nMetodo)
Local aArea		:= GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())

If nMetodo == 2
	dbSelectArea("AFD")
	dbSetOrder(2)
	MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
	While !AFD->(EOF()) .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa == AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC
		AF9->(MsSeek(xFilial("AF9")+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA))
		Do Case
			Case AFD->AFD_TIPO == "1" //Fim no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,-AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO == "2" //Inicio no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO == "3" //Fim no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO == "4" //Inicio no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,(AFD->AFD_HRETAR),AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
	 			EndIf
		EndCase
		If Empty(aRetSuc) .Or. ;
				(aAuxRet[1] < aRetSuc[1] .Or. ;
									(aAuxRet[1] == aRetSuc[1] .And. aAuxRet[2] < aRetSuc[2]) ;
				)
			aRetSuc := aClone(aAuxRet)
		Endif
		DbSelectArea("AFD")
		DbSkip()
	EndDo
Else
	dbSelectArea("AFD")
	dbSetOrder(1)
	MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
	While !AFD->(EOF()) .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa == AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA
		AF9->(MsSeek(xFilial("AF9")+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC))
		Do Case
			Case AFD->AFD_TIPO == "1" //Fim no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO == "2" //Inicio no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO == "3" //Fim no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(AF9->AF9_FINISH,AF9->AF9_HORAF,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO == "4" //Inicio no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,(AFD->AFD_HRETAR*-1),AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(AF9->AF9_START,AF9->AF9_HORAI,cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
		EndCase
		If Empty(aRetSuc) .Or. ;
				(aAuxRet[1] > aRetSuc[1] .Or. ;
									(aAuxRet[1] == aRetSuc[1] .And. aAuxRet[2] > aRetSuc[2]) ;
				)
			aRetSuc := aClone(aAuxRet)
		Endif
		DbSelectArea("AFD")
		DbSkip()
	EndDo
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return aRetSuc


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF8CALCNEWºAutor  ³Pedro Pereira Lima  º Data ³  03/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF8CalcNew(nRecAF8,nMetodo,dData,lProcessa,cRevisa,oTree,cArquivo,cRecDe,cRecAte,cEquipDe,cEquipAte,lReprParc,lFixNaoIni,lTiraFolga,cHoraI,cTabOk)

Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAF8	:= AF8->(GetArea())
Local aAreaAJ4 := AJ4->(GetArea())
Local cAlias
Local nRecAlias
Local aTsk      := {}
Local aAllEDT   := {}
Local nx
Local cAlias1	:=	GetNextAlias()
Local cAlias2	:=	GetNextAlias()
Local cAlias3	:=	GetNextAlias()
Local cAliasNew:= GetNextAlias()
Local cTabTemp
Local nLenAtsk	:=	0
Local nJaProc	:=	0
Local nContaAnt:= 0
Local lContinua := .T.
Local cTexto := ""
Local aTemp := {}
Local aTskRestri	:= {}
Local lAbort := lTiraFolga

DEFAULT lReprParc	:= .F.
DEFAULT lProcessa	:= .F.
DEFAULT cRevisa	  	:= ""
DEFAULT lFixNaoIni  :=	.F.
DEFAULT cHoraI	:= "00:00"
DEFAULT cTabOk	:= CriaTrab(Nil,.F.)

dbSelectArea("AF8")
MsGoto(nRecAF8)

Default cRevisa := AF8->AF8_REVISA

If oTree!= Nil
		cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
ElseIf cArquivo <> Nil
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
Else
	cAlias := "AF8"
	nRecAlias := nRecAF8
EndIf

If cAlias == "AF8"
	dbSelectArea("AF8")
	dbGoto(nRecAlias)
	dbSelectArea("AFC")
	dbSetOrder(1)
	dbSeek(xFilial("AFC")+AF8->AF8_PROJET+cRevisa+Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))
   If !lAbort
		PmsLoadTsk(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aTsk,,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
	Else
		dbSelectArea("AFC")
		dbSetOrder(3)
		dbSeek(xFilial("AFC")+AF8->AF8_PROJET+cRevisa+"001")
		PmsLoadTsk(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aTsk,,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
	EndIf
ElseIf cAlias == "AFC"
	dbSelectArea("AFC")
	dbGoto(nRecAlias)
	If !lAbort
		PmsLoadTsk(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aTsk,,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
	Else
		dbSelectArea("AFC")
		dbSetOrder(3)
		dbSeek(xFilial("AFC")+AFC->AFC_PROJET+AFC->AFC_REVISA+"001")
		PmsLoadTsk(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aTsk,,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
	EndIf
ElseIf cAlias == "AF9"
	dbSelectArea("AF9")
	dbGoto(nRecAlias)
	PmsLoadTsk(AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,aTsk,.T.,cRecDe,cRecAte,cEquipDe,cEquipAte,"( Empty(AF9->AF9_DTATUI).Or. "+If(lReprParc,".T.",".F.")+") .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)")
Endif

If lProcessa
	ProcRegua(Len(aTsk) * 2)
EndIf

#IFDEF TOP //Se for TopConnect (TOTVS DBAcess), utilizo a rotina nova para reprogramacao

	If (PadR(AFC->AFC_PROJET,TamSX3("AFC_EDT")[1]) == AFC->AFC_EDT)//Se o codigo do projeto é igual o codigo da EDT;
																						//então a reprogramação é do projeto inteiro
		// calcula as datas previstas pelo inicio do projeto
		If nMetodo == 1
			If lProcessa
				nLenaTsk	:=	Len(aTsk)
				ProcRegua(nLenaTsk)	
			EndIf	
		
			If !InTransact()//Inclusa validação de transação devido criação de tabela
				aTemp	:=	{{"TAREFA","C",TamSx3("AF9_TAREFA")[1],TamSx3("AF9_TAREFA")[2]}}
				MsCreate(cTabOk,aTemp,"TOPCONN")
				Sleep(1000)
			EndIf
			
			dbUseArea(.T.,"TOPCONN",cTabOk,"TASKS",.T.,.F.)
			IndRegua("TASKS",cTabOk,"TAREFA")
			cTabTemp := "%"
			cTabTemp += cTabOk
			cTabTemp += "%"

			//Seleciona tarefas que nao sao predecessoras
			BeginSQL ALIAS cAlias1
			SELECT AF9.R_E_C_N_O_ RECAF9 FROM %TABLE:AF9% AF9
				WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
			   		AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
			   		AND AF9_REVISA = %EXP:cRevisa%
			   		AND AF9_TAREFA NOT IN
			   			(SELECT AFD_TAREFA FROM %TABLE:AFD% AFD
							   WHERE AFD_FILIAL = %EXP:xFilial("AFD")%
							   		AND AFD_PROJET = %EXP:AF8->AF8_PROJET%
							   		AND AFD_REVISA = %EXP:cRevisa%
							   		AND AFD.%NotDel%
			   			)
			   		AND AF9.%NotDel%
		   	EndSql

			DbSelectArea(cAlias1)
			nLenATsk := 0
			nJaProc := 0
			While !Eof() //Temporario
				nLenATsk++ //QUANTIDADE DE REGISTROS ENCONTRADOS
				DbSkip()
			Enddo

			//Reprograma tarefas que nao sao predecessoras
			DbSelectArea(cAlias1)
			(cAlias1)->(DbGoTop())

			While !Eof() //Temporario
				AF9->(DbGoto((cAlias1)->RECAF9))
				If (Empty(AF9->AF9_DTATUI).Or. lReprParc ) .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)
					//Ver cHoraI
					aAuxRet := PMSDTaskF(dData,cHoraI,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)

					//Verificar se tem alguma tarefa relacionada com inicio no inicio,
					//para mudar a data de fim para uma data que nao conflite com o relacionamento
					//posteriormente
					RecLock("AF9",.F.)
					AF9->AF9_START	:= aAuxRet[1]
					AF9->AF9_HORAI	:= aAuxRet[2]
					AF9->AF9_FINISH:= aAuxRet[3]
					AF9->AF9_HORAF	:= aAuxRet[4]

					dbSelectArea("AF9")
					If aScan(aAllEDT,AF9->AF9_EDTPAI) <= 0
						aAdd(aAllEDT,AF9->AF9_EDTPAI)
					EndIf

					If AF9->AF9_RESTRICAO == "8" // mais tarde possivel
						aAdd(aTskRestri, {AF9->(recno()) , AF9->AF9_RESTRICAO })
			   		Elseif AF9->AF9_RESTRICAO <> "7" // qualquer outra restricao faremos agora o recalculo
				   		aAuxRet := PMSCalRest( AF9->AF9_RESTRICAO , AF9->AF9_DTREST, AF9->AF9_HRREST ,aAuxRet,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET, .T.)
						AF9->AF9_START	:= aAuxRet[1]
						AF9->AF9_HORAI	:= aAuxRet[2]
						AF9->AF9_FINISH	:= aAuxRet[3]
						AF9->AF9_HORAF	:= aAuxRet[4]
				   	Endif

					MsUnlock()
					PmsAtuNec(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA)
				EndIf
				RecLock("TASKS",.T.)
					Replace TAREFA With AF9->AF9_TAREFA
				MsunLock()
				DbSelectArea(cAlias1)
				DbSkip()
				If lProcessa
					nJaProc++
					IncProc(STR0064+StrZero(nLenATsk-nJaProc,4) +STR0065+ StrZero(nLenATsk,4)+STR0066) //  Restando XXXX de XXXXX tarefas
				Endif
			Enddo
			DbSelectArea(cAlias1)
			DbCloseArea()
			//	Verifica se existe alguma tarefa que ainda nao foi reprocessada
			BeginSQL ALIAS cAlias1
				SELECT COUNT(*) CONTA FROM %TABLE:AF9% AF9
				WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
		   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
		   			AND AF9_REVISA = %EXP:cRevisa%
		   			AND AF9_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp%)
		   			AND AF9.%NotDel%
		  	EndSQL
			nConta	:=	(cAlias1)->CONTA
			DbCloseArea()
			//Se tem tarefa qie ainda nao foi reprogramada
			While nConta > 0
				//Seleciona tarefas que tiveram todas as PREDESSORAS reprogramadas
				BeginSQL ALIAS cAlias1
					SELECT DISTINCT AFD.AFD_TAREFA AFD_TAREFA FROM %TABLE:AFD% AFD
						 WHERE    AFD_FILIAL = %EXP:xFilial("AFD")%
				   			AND AFD_PROJET = %EXP:AF8->AF8_PROJET%
				   			AND AFD_REVISA = %EXP:cRevisa%
				   			AND (SELECT Count(AFD_PREDEC) CONTA  FROM %TABLE:AFD% AFD2
									   WHERE     AFD2.AFD_FILIAL = %EXP:xFilial("AFD")%
									   		AND AFD2.AFD_PROJET = %EXP:AF8->AF8_PROJET%
									   		AND AFD2.AFD_REVISA = %EXP:cRevisa%
												AND AFD2.AFD_TAREFA = AFD.AFD_TAREFA
									   		AND AFD2.AFD_PREDEC IN (SELECT TAREFA FROM %EXP:cTabTemp% )
					  							AND AFD2.%NotDel%
					  		   				)
					  		    =
					  		    (SELECT Count(AFD_PREDEC) CONTA  FROM %TABLE:AFD% AFD2
					  		    	WHERE     AFD2.AFD_FILIAL = %EXP:xFilial("AFD")%
								   		AND AFD2.AFD_PROJET = %EXP:AF8->AF8_PROJET%
								   		AND AFD2.AFD_REVISA = %EXP:cRevisa%
											AND AFD2.AFD_TAREFA = AFD.AFD_TAREFA
					  						AND AFD2.%NotDel%
					  			)
							AND AFD.AFD_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp% )
					  		AND AFD.%NotDel%
			   Endsql

				DbSelectArea(cAlias1)
				nLenATsk := 0
				nJaProc := 0
				While !(cAlias1)->(Eof())
					nLenATsk++ //QUANTIDADE DE REGISTROS ENCONTRADOS
					DbSkip()
				Enddo

				//Reprograma tarefas que ja tiveram todas as sucessoras reprogramadas
				DbSelectArea(cAlias1)
				(cAlias1)->(DbGoTop())
				While !(cAlias1)->(Eof())
					AJ4->(DbSetOrder(1))
					If PredecAJ4Ok(AF8->AF8_PROJET,cRevisa,(cAlias1)->AFD_TAREFA,cTabTemp,nMetodo)
						If (Empty(AF9->AF9_DTATUI).Or. lReprParc ) .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)

							//Atualiza datas no AF9 de acordo com as sucessoras
							PmsAtuPred((cAlias1)->AFD_TAREFA,AF8->AF8_PROJET,cRevisa,dData,aAllEDT,nMetodo)
		   			Endif
						BeginSQL ALIAS cAlias2
							SELECT TAREFA FROM %EXP:cTabTemp%
							Where TAREFA = %EXP:(cAlias1)->AFD_TAREFA%
					   Endsql

					   If EOF()
							RecLock("TASKS",.T.)
							Replace TAREFA With (cAlias1)->AFD_TAREFA
							MsunLock()
							If lProcessa
								nJaProc++
								IncProc(STR0064+StrZero(nLenATsk-nJaProc,4)+STR0065+StrZero(nLenATsk,4)+STR0066)
							Endif
						Endif
						DbSelectArea(cAlias2)
				  		DbCloseArea()
					Endif
			    	DbSelectArea(cAlias1)
			    	DbSkip()
			   Enddo
				DbSelectArea(cAlias1)
				DbCloseArea()
				BeginSQL ALIAS cAlias1
					SELECT COUNT(*) CONTA FROM %TABLE:AF9% AF9
						WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
				   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
				   			AND AF9_REVISA = %EXP:cRevisa%
				   			AND AF9_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp% )
				   			AND AF9.%NotDel%
			   EndSQL

				nConta	:=	CONTA

				If nContaAnt == nConta .And. nContaAnt != 0
					BeginSQL ALIAS cAliasNew
					SELECT AF9_TAREFA TAREFA FROM %TABLE:AF9% AF9
						WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
				   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
				   			AND AF9_REVISA = %EXP:cRevisa%
				   			AND AF9_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp% )
				   			AND AF9.%NotDel%
				   EndSQL

					(cAliasNew)->(dbGoTop())
					While !(cAliasNew)->(EOF())
		         	cTexto += (cAliasNew)->TAREFA + CRLF
		         	(cAliasNew)->(dbSkip())
					EndDo
					__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
					DEFINE FONT oFont NAME "Courier New" SIZE 7,15
					DEFINE MSDIALOG oDlg TITLE STR0057 From 3,0 to 400,417 PIXEL //"Reprogramação de Datas"
					@ 5,5  Say STR0058 Size 150,15 Of oDlg Pixel //"Foi encontrada uma referência circular entre tarefas!"
					@ 14,5 Say STR0059 Size 200,15  Of oDlg Pixel	//"Verifique a tarefas abaixo e seus relacionamentos. Operação abortada!"
					@ 23,5 GET oMemo   VAR cTexto MEMO SIZE 200,155 Read  OF oDlg PIXEL
					oMemo:bRClicked := {||AllwaysTrue()}
					oMemo:oFont:=oFont

					DEFINE SBUTTON  FROM 185,170 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga

					ACTIVATE MSDIALOG oDlg CENTER

					lContinua := .F.
					Exit
				EndIf

				nContaAnt := nConta

				DbSelectArea(cAlias1)
				DbCloseArea()
			Enddo

			dbSelectArea("TASKS")
			dbCloseArea()
			
			If !InTransact()//Inclusa validação de transação devido criação de tabela
		 		MsErase(cTabOk)
			EndIf
			
			dbSelectArea("AF8")
			If lProcessa
				ProcRegua(Len(aAllEDT))
			EndIf

			aAllEDT := aSort(aAllEDT,,,{|x,y|x>y})

			For nX := 1 to Len(aAllEDT)
				If lProcessa
					IncProc(STR0067)//"Atualizando datas da estrutura..."
				EndIf
				PmsAtuEDT(AF8->AF8_PROJET, cRevisa, aAllEDT[nX],,,,,.T.)
			Next nX

			aSort( aTskRestri , , , { |x,y| x[2] < y[2]  }) // ordena por codigo de restrição (deixar o "mais tarde possivel por ultimo)
			For nx := 1 to len(aTskRestri)
				dbSelectArea("AF9")
				AF9->(dbGoto(aTskRestri[nx][1]))
		   		If aTskRestri[nx][2] == "8"
					PA203Tarde(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA, .F.)
			   	Endif
			Next nx

		// calcula as datas previstas pelo fim do projeto
		Else
			If lProcessa
				nLenaTsk	:=	Len(aTsk)
				ProcRegua(nLenaTsk)	
			EndIf	

			If !InTransact()//Inclusa validação de transação devido criação de tabela		
				aTemp	:=	{{"TAREFA","C",TamSx3("AF9_TAREFA")[1],TamSx3("AF9_TAREFA")[2]}}
				MsCreate(cTabOk,aTemp,"TOPCONN")
				Sleep(1000)
			EndIf
			
			dbUseArea(.T.,"TOPCONN",cTabOk,"TASKS",.T.,.F.)
			IndRegua("TASKS",cTabOk,"TAREFA")
			cTabTemp := "%"
			cTabTemp += cTabOk
			cTabTemp += "%"

			//Seleciona tarefas que nao sao predecessoras
			BeginSQL ALIAS cAlias1
			SELECT AF9.R_E_C_N_O_ RECAF9 FROM %TABLE:AF9% AF9
				WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
			   		AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
			   		AND AF9_REVISA = %EXP:cRevisa%
			   		AND AF9_TAREFA NOT IN
			   			(SELECT AFD_PREDEC FROM %TABLE:AFD% AFD
							   WHERE AFD_FILIAL = %EXP:xFilial("AFD")%
							   		AND AFD_PROJET = %EXP:AF8->AF8_PROJET%
							   		AND AFD_REVISA = %EXP:cRevisa%
							   		AND AFD.%NotDel%
							)
			   		AND AF9_TAREFA NOT IN
			   			(SELECT AJ4_TAREFA FROM %TABLE:AJ4% AJ4
							   WHERE AJ4_FILIAL = %EXP:xFilial("AJ4")%
							   		AND AJ4_PROJET = %EXP:AF8->AF8_PROJET%
							   		AND AJ4_REVISA = %EXP:cRevisa%
							   		AND AJ4.%NotDel%
			   			)
			   		AND AF9.%NotDel%
		   	EndSql

			DbSelectArea(cAlias1)
			nLenATsk := 0
			nJaProc := 0
			While !(cAlias1)->(Eof())
				nLenATsk++ //QUANTIDADE DE REGISTROS ENCONTRADOS
				DbSkip()
			Enddo

			//Reprograma tarefas que nao sao predecessoras
			DbSelectArea(cAlias1)
			(cAlias1)->(DbGoTop())

			While !Eof() //Temporario
				AF9->(DbGoto((cAlias1)->RECAF9))
				If (Empty(AF9->AF9_DTATUI).Or. lReprParc ) .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)
					aAuxRet := PMSDTaskI(dData,"24:00",AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)

					RecLock("AF9",.F.)
					AF9->AF9_START	:= aAuxRet[1]
					AF9->AF9_HORAI	:= aAuxRet[2]
					AF9->AF9_FINISH:= aAuxRet[3]
					AF9->AF9_HORAF	:= aAuxRet[4]

					dbSelectArea("AF9")
					If aScan(aAllEDT,AF9->AF9_EDTPAI) <= 0
						aAdd(aAllEDT,AF9->AF9_EDTPAI)
					EndIf

					If AF9->AF9_RESTRICAO == "8" // mais tarde possivel
						aAdd(aTskRestri, {AF9->(recno()) , AF9->AF9_RESTRICAO })
			   		Elseif AF9->AF9_RESTRICAO <> "7" // qualquer outra restricao faremos agora o recalculo
				   		aAuxRet := PMSCalRest( AF9->AF9_RESTRICAO , AF9->AF9_DTREST, AF9->AF9_HRREST ,aAuxRet,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET, .T.)
						AF9->AF9_START	:= aAuxRet[1]
						AF9->AF9_HORAI	:= aAuxRet[2]
						AF9->AF9_FINISH	:= aAuxRet[3]
						AF9->AF9_HORAF	:= aAuxRet[4]
				   	Endif
					MsUnlock()

				EndIf
				RecLock("TASKS",.T.)
					Replace TAREFA With AF9->AF9_TAREFA
				MsunLock()
				DbSelectArea(cAlias1)
				DbSkip()
				If lProcessa
					nJaProc++
					IncProc(STR0064+StrZero(nLenATsk-nJaProc,4) +STR0065+ StrZero(nLenATsk,4)+STR0066)
				Endif
			Enddo
			DbSelectArea(cAlias1)
			DbCloseArea()
			//	Verifica se existe alguma tarefa que ainda nao foi reprocessada
			BeginSQL ALIAS cAlias1
				SELECT COUNT(*) CONTA FROM %TABLE:AF9% AF9
				WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
		   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
		   			AND AF9_REVISA = %EXP:cRevisa%
		   			AND AF9_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp%)
		   			AND AF9.%NotDel%
		  	EndSQL
			nConta :=	CONTA
			DbCloseArea()
			//Se tem tarefa qie ainda nao foi reprogramada
			While nConta > 0
				//Seleciona tarefas que tiveram todas as SUCESSORAS reprogramadas
				BeginSQL ALIAS cAlias1
					SELECT DISTINCT AFD.AFD_PREDEC AFD_PREDEC FROM %TABLE:AFD% AFD
						 WHERE    AFD_FILIAL = %EXP:xFilial("AFD")%
				   			AND AFD_PROJET = %EXP:AF8->AF8_PROJET%
				   			AND AFD_REVISA = %EXP:cRevisa%
				   			AND (SELECT Count(AFD_TAREFA) CONTA  FROM %TABLE:AFD% AFD2
									   WHERE     AFD2.AFD_FILIAL = %EXP:xFilial("AFD")%
									   		AND AFD2.AFD_PROJET = %EXP:AF8->AF8_PROJET%
									   		AND AFD2.AFD_REVISA = %EXP:cRevisa%
												AND AFD2.AFD_PREDEC = AFD.AFD_PREDEC
									   		AND AFD2.AFD_TAREFA IN (SELECT TAREFA FROM %EXP:cTabTemp% )
					  							AND AFD2.%NotDel%
					  		   				)
					  		    =
					  		    (SELECT Count(AFD_TAREFA) CONTA  FROM %TABLE:AFD% AFD2
					  		    	WHERE     AFD2.AFD_FILIAL = %EXP:xFilial("AFD")%
								   		AND AFD2.AFD_PROJET = %EXP:AF8->AF8_PROJET%
								   		AND AFD2.AFD_REVISA = %EXP:cRevisa%
											AND AFD2.AFD_PREDEC = AFD.AFD_PREDEC
					  						AND AFD2.%NotDel%
					  			)
							AND AFD.AFD_PREDEC NOT IN (SELECT TAREFA FROM %EXP:cTabTemp% )
					  		AND AFD.%NotDel%
			   Endsql

  				DbSelectArea(cAlias1)
				nLenATsk := 0
				nJaProc := 0
				While !(cAlias1)->(Eof())
					nLenATsk++ //QUANTIDADE DE REGISTROS ENCONTRADOS
					DbSkip()
				Enddo

				//Reprograma tarefas que ja tiveram todas as sucessoras reprogramadas
				DbSelectArea(cAlias1)
				(cAlias1)->(DbGoTop())

				While !(cAlias1)->(Eof())
					AJ4->(DbSetOrder(1))
					If PredecAJ4Ok(AF8->AF8_PROJET,cRevisa,(cAlias1)->AFD_PREDEC,cTabTemp,nMetodo)
						If (Empty(AF9->AF9_DTATUI).Or. lReprParc ) .And. AF9->AF9_PRIORI < 1000 .And. Empty(AF9->AF9_DTATUF)

							//Atualiza datas no AF9 de acordo com as sucessoras
							PmsAtuSuc((cAlias1)->AFD_PREDEC,AF8->AF8_PROJET,cRevisa,dData,aAllEDT,nMetodo)
						EndIf

					   BeginSQL ALIAS cAlias2
							SELECT TAREFA FROM %EXP:cTabTemp%
							Where TAREFA = %EXP:(cAlias1)->AFD_PREDEC%
					   Endsql

					   If EOF()
							RecLock("TASKS",.T.)
							Replace TAREFA With (cAlias1)->AFD_PREDEC
							MsunLock()
							If lProcessa
								nJaProc++
								IncProc(STR0064+StrZero(nLenATsk-nJaProc,4) +STR0065+ StrZero(nLenATsk,4)+STR0066)
							Endif
						Endif
						DbSelectArea(cAlias2)
				  		DbCloseArea()
					Endif
			    	DbSelectArea(cAlias1)
			    	DbSkip()
			   Enddo
				DbSelectArea(cAlias1)
				DbCloseArea()
				BeginSQL ALIAS cAlias1
					SELECT COUNT(*) CONTA FROM %TABLE:AF9% AF9
						WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
				   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
				   			AND AF9_REVISA = %EXP:cRevisa%
				   			AND AF9_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp% )
				   			AND AF9.%NotDel%
			   EndSQL
				nConta	:=	CONTA
				If nContaAnt == nConta .And. nContaAnt != 0
					BeginSQL ALIAS cAliasNew
						SELECT AF9_TAREFA TAREFA FROM %TABLE:AF9% AF9
							WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
					   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
					   			AND AF9_REVISA = %EXP:cRevisa%
					   			AND AF9_TAREFA NOT IN (SELECT TAREFA FROM %EXP:cTabTemp% )
					   			AND AF9.%NotDel%
				   EndSQL

					(cAliasNew)->(dbGoTop())
					While !(cAliasNew)->(EOF())
		         	cTexto += (cAliasNew)->TAREFA + CRLF
		         	(cAliasNew)->(dbSkip())
					EndDo
					__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
					DEFINE FONT oFont NAME "Courier New" SIZE 7,15
					DEFINE MSDIALOG oDlg TITLE STR0057 From 3,0 to 400,417 PIXEL //"Reprogramação de Datas"
					@ 5,5  Say STR0058 Size 150,15 Of oDlg Pixel //"Foi encontrada uma referência circular entre tarefas!"
					@ 14,5 Say STR0059 Size 200,15  Of oDlg Pixel	//"Verifique a tarefas abaixo e seus relacionamentos. Operação abortada!"
					@ 23,5 GET oMemo   VAR cTexto MEMO SIZE 200,155 Read  OF oDlg PIXEL
					oMemo:bRClicked := {||AllwaysTrue()}
					oMemo:oFont:=oFont

					DEFINE SBUTTON  FROM 185,170 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga

					ACTIVATE MSDIALOG oDlg CENTER

					lContinua := .F.
					Exit
				EndIf
				nContaAnt := nConta
				DbSelectArea(cAlias1)
				DbCloseArea()
			Enddo
			
			dbSelectArea("TASKS")
			dbCloseArea()
			
			If !InTransact()//Inclusa validação de transação devido criação de tabela
				MsErase(cTabOk)
			EndIf 

			dbSelectArea("AF8")
			BeginSQL ALIAS cAlias3
				SELECT MIN(AF9_START) AF9_START FROM %TABLE:AF9% AF9
					WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
			   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
			   			AND AF9_REVISA = %EXP:cRevisa%
			   			AND AF9.%NotDel%
		   EndSQL
			cDataMin	:=	AF9_START
			DbSelectArea(cAlias3)
			DbCloseArea()
			BeginSQL ALIAS cAlias3
				SELECT MIN(AF9_HORAI) AF9_HORAI FROM %TABLE:AF9% AF9
					WHERE AF9_FILIAL = %EXP:xFilial("AF9")%
			   			AND AF9_PROJET = %EXP:AF8->AF8_PROJET%
			   			AND AF9_REVISA = %EXP:cRevisa%
			   			AND AF9_START = %EXP:cDataMin%
			   			AND AF9.%NotDel%
		   EndSQL
			cHoraMin	:=	AF9_HORAI
			DbSelectArea(cAlias3)
			DbCloseArea()

		   If lContinua
				AF8CalcNew(nRecAF8,1      ,Stod(cDataMin),lProcessa,cRevisa,oTree,cArquivo,cRecDe,cRecAte,cEquipDe,cEquipAte,lReprParc,lFixNaoIni,.T.       ,cHoraMin,cTabOk)      
		   EndIf

		EndIf
	Else
	 	If Aviso(STR0057,;
	 				STR0060+CRLF+STR0061+CRLF+STR0062+CRLF+STR0063,;
	 				{STR0025,STR0026},2) == 1
			PmsAF8Calc(nRecAF8,nMetodo,dData,lProcessa,cRevisa,oTree,cArquivo,cRecDe,cRecAte,cEquipDe,cEquipAte,lReprParc,lFixNaoIni,cHoraI)
	   Else
	   	DbSelectArea("AFC")
	   	DbSetOrder(1)
	   	DbSeek(xFilial("AFC")+AFC->AFC_PROJET+cRevisa+AFC->AFC_PROJET)
	   	DbSelectArea(cAlias)
			AF8CalcNew(nRecAF8,nMetodo,dData,lProcessa,cRevisa,oTree,cArquivo,cRecDe,cRecAte,cEquipDe,cEquipAte,lReprParc,lFixNaoIni,.T.,cHoraI)
		EndIf
	EndIf
#ELSE
	PmsAF8Calc(nRecAF8,nMetodo,dData,lProcessa,cRevisa,oTree,cArquivo,cRecDe,cRecAte,cEquipDe,cEquipAte,lReprParc,lFixNaoIni,cHoraI)
#ENDIF

RestArea(aAreaAJ4)
RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAFGFOK³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao dos campos da GetDados de rateio da SC.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGSC,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFGFOK()

Local cTRT		:= aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})]
Local cProjeto	:= aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_PROJET"})]
Local cRevisa	:= aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_REVISA"})]
Local cTarefa	:= aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TAREFA"})]
Local cPlanej	:= aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_PLANEJ"})]
Local nQuant	:= aScan(aHeader,{|x|Alltrim(x[2])=="AFG_QUANT"})
Local nPosTrt	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFG_TRT"})
Local nPosPlanj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFG_PLANEJ"})
Local lRet		:= .T.
Local cCampo	:= AllTrim(ReadVar())
Local lGerEmp  := .F.
Local nOption  := 0
Local nCnt		:= 0
Local nTotEmp   := 0
Local nAFMQUANT := Iif(Type("M->AFG_QUANT")=="U", aCols[n][nQuant], M->AFG_QUANT)
Local lPmsScBlq	:= SuperGetMv("MV_PMSCBLQ",,.F.)


If (nPosPlanj > 0) .and.  (nPosTrt > 0) .and. !Empty(aCols[n][nPosPlanj]) .and. !Empty(aCols[n][nPosTrt])
	If nAFMQUANT > ( nTotEmp := PmsGetEmp(aCols[n],aHeader,2, "AFG") )
		if l110Auto
			Help(,,"PMSMAXAMA",,STR0082 + Alltrim(STR(nTotEmp)))
		else
			MSGAlert(STR0082 + Alltrim(STR(nTotEmp))) // "QUANTIDADE MAXIMA PERMITIDADE DE AMARRACAO: "
		endif
		lRet := .F.
	EndIf
EndIf
If lRet .and. lPmsScBlq .and. !(Empty(cPlanej))
	if (aCols[n][aScan(aHeader,{|x|Alltrim(x[2])==Substr(cCampo,4,len(cCampo))})]) !=&cCampo
		if l110Auto
			Help(,,"PMSSCPLAN",,STR0139)
		else
			MsgAlert(STR0139) //"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não será possível alterar informações principais. Verificar parâmetro MV_PMSCBLQ."
		endif
		lRet:=.F.
	Endif
Endif

If lRet

	Do Case
		Case cCampo == 'M->AFG_PROJET'
			cProjeto:= M->AFG_PROJET
			lRet := PMSExistCPO("AF8") .And. PmsVldFase("AF8",M->AFG_PROJET,"52",!l110Auto)
		Case cCampo == 'M->AFG_TAREFA'
			cTarefa	:= M->AFG_TAREFA
			lRet := ExistCpo("AF9",cProjeto+cRevisa+M->AFG_TAREFA,1)
	EndCase
Endif

If lRet .AND. !Empty(cProjeto) .AND. !Empty(cTarefa)
	// verifica os direitos do usuario
	lRet := PmsChkUser(cProjeto,cTarefa,,"",3,"GERSC",cRevisa)
	If !lRet
		if l110Auto
			Help(,,"PMSGERSC",,STR0075)//"Usuario sem permissäo para executar a solicitação de compra para o projeto. Verifique os direitos do usuario na estrutura deste projeto e/ou tarefa."
		else
			Aviso(STR0074,STR0075,{"Ok"},2)// "Usuario sem Permissäo."##"Usuario sem permissäo para executar a solicitação de compra para o projeto. Verifique os direitos do usuario na estrutura deste projeto e/ou tarefa."
		endif
	EndIf
	For nCnt := 1 To Len(aCols)
		If n != nCnt .and. !aCols[n][Len(aHeader)+1]
			If      cProjeto == aCols[nCnt][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_PROJET"})] ;
			  .AND. cTarefa  == aCols[nCnt][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TAREFA"})] ;
			  .AND. cTRT     == aCols[nCnt][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})] ;
			  .AND. !aCols[nCnt][Len(aHeader)+1]
				if l110Auto
					Help(,,"PMSDUPEMP",,STR0160) // "Duplicidade na associação com projeto, tarefa e sequencia de empenho. Verifique"
				else
					Aviso(STR0020 ,STR0160,{"Ok"},2) // "Atenção!" ## "Duplicidade na associação com projeto, tarefa e sequencia de empenho. Verifique"
				endif
				lRet := .F.

			EndIf
		EndIf
	Next nCnt

	If lRet .And. Empty(cTRT) .And. aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"}) > 0
	// parametro que determina se gera empenho direto sem perguntar nada (.T.)
  		lGerEmp := GetNewPar("MV_PMSSCGE",.F.)
		If lGerEmp .and. Empty(cPlanej)  // gera empenho direto sem perguntar nada, se não for um planejamento
	   		aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})]	 := PmsPrxEmp(cProjeto,cRevisa,cTarefa)
		ElseIf GetMV("MV_PMSBXEM") .and. !l110Auto
			If Empty(cPlanej)
				//Se não for planejamento
				If Aviso(STR0068,STR0073,{STR0025,STR0026},2)==1  //"Gerenciamento de Projetos"##"Voce deseja gerar um empenho deste item ao projeto ?"
					aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})]	 := PmsPrxEmp(cProjeto,cRevisa,cTarefa)
				EndIf
			Else
				nOption := Aviso(STR0068,STR0069,{STR0070,STR0071,STR0072},2)
				If nOption == 1
					aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})]	 := PmsPlnEmp(cProjeto,cTarefa,cPlanej)
				ElseIf nOption == 2
					aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})]	 := PmsPrxEmp(cProjeto,cRevisa,cTarefa)
				Else
					aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})]	 :=	SPACE(LEN(AFG->AFG_TRT))
				EndIf
			EndIf
		Else
			aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFG_TRT"})]	 :=	SPACE(LEN(AFG->AFG_TRT))
		EndIf
	EndIf

EndIf


Return lRet


/*/{Protheus.doc} PMSAFGLOK

Funcao de validacao LinOk da GetDados de rateio da SC.

@author Edson Maricate

@since  09-02-2001

@version P10

@param nenhum

@return logico, verdadeiro a linha foi validado com sucesso

/*/
Function PMSAFGLOK()
Local cProject	:= aCols[n][aScan(aHeader,{|x| Substr(x[2],4,7) =="_PROJET" })]
Local cPlanej		:= aCols[n][aScan(aHeader,{|x| Substr(x[2],4,7) =="_PLANEJ" })]
Local cMensagem	:= ""
Local lRet 		:= .T.
Local lPmsScBlq	:= SuperGetMv("MV_PMSCBLQ",,.F.)

lBlockDel := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][Len(aCols[n])]
	If (lRet := PmsVldFase("AF8",cProject,"52",!l110Auto,@cMensagem))
		lRet := MaCheckCols(aHeader,aCols,n)
	Else
		If l110Auto
			Help( " ", 1, "PXFUNFASE",, cMensagem, 1, 0 )
		EndIf
	EndIf
EndIf

If lRet .and. (aCols[n][len(acols[1])]==.T.) .and. lPmsScBlq .and. !(Empty(cPlanej))
	Help( " ", 1, "PXFUNPLAN",, STR0140, 1, 0 ) //"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não sera possível excluí-la. Verificar parâmetrp MV_PMSCBLQ."

	AutoGrLog(STR0140) //"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não sera possível excluí-la. Verificar parâmetrp MV_PMSCBLQ."
	lRet:=.F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAFHBOK³ Autor ³ Bruno Sobieski         ³ Data ³ 06-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da quantidade a ser baixada da pre-req.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGSA,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFHBOK()
Local nQtdTot	:=	&(ReadVar())
Local lRet		:=	.T.
If nQtdTot	   > (IIF(VALTYPE(GdFieldGet('AFH_QUANT')) == "U","0",GdFieldGet('AFH_QUANT')))- (IIF(VALTYPE(GdFieldGet('AFH_QUJE'))== "U","0",GdFieldGet('AFH_QUJE')))
	Help("  ",1, "SALDOAFH")
	lRet	:=	.F.
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAFHBLOK³ Autor ³ Bruno Sobieski        ³ Data ³ 08-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao LinOk da GetDados de rateio da SA.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGSA,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFHBLOK()
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][Len(aCols[n])]
	lRet := PmsVldFase("AF8",aCols[n][aScan(aHeader,{|x| Substr(x[2],4,7) =="_PROJET" })],"54")
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n)
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAFHBTOK³ Autor ³ Bruno Sobieski        ³ Data ³ 06-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da quantidade a ser baixada da pre-req.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSDLGSA,PMSXFUN                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAFHBTOK(nQuantSA)
Local nQtdTot	:=	0
Local nSavN		:=	n
Local lRet		:=	.T.
Local nY

For nY:=1 To Len(aCols)
	nQtdTot	+=	GdFieldGet('AFH_QBAIX',nY)
Next

If nQtdTot == 0
	If IsIntegTop(,.T.)
		Aviso("SIGAPMS",STR0165,{"OK"}) //"A solicitação ao armazém esta associada aos projetos, porém não foram informadas as quantidades a baixar"
		lRet := .F.
	Else
		Aviso("SIGAPMS", STR0076, {"OK"})
		//"A quantidade a baixar total é zero. O movimento interno não será associado ao projeto."
	Endif
Else
	If nQtdTot > nQuantSA
		Help("  ",1, "SALDOSCP")
		lRet	:=	.F.
	Endif
EndIf
n	:=	nSavN
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsSetF3³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configura os parametros de Filtro das consultas F3 para a     ³±±
±±³          ³rotina utilizada.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo da Consulta                                    ³±±
±±³          ³ExpN2 : Opcao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSetF3(cSXB,nOpcao,cProjeto)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local nColigada	:= GetNewPar("MV_RMCOLIG",0)


// Sincroniza as tabelas do TOP com PMS
If nColigada > 0
   PMSVIEWSOLUM()
// PMSUPDSOLUM() - parte A-PMSVIEWSOLUM() e parte B-PMSUPDSOLUM(nERPConn,nSolumConn)
EndIf

If cProjeto != Nil
	dbSelectArea("AF8")
	dbSetOrder(1)
	MsSeek(xFilial()+cProjeto)
EndIf
dbSelectArea("AF9")
dbSelectArea("AFC")

Do Case
	Case cSXB == "AF9" .And. nOpcao == 1
		cEofF3AF9 := 	aCols[n][aScan(aHeader,{|x|Substr(x[2],4,7)=="_PROJET"})]+;
						aCols[n][aScan(aHeader,{|x|Substr(x[2],4,7)=="_REVISA"})]
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AFC" .And. nOpcao == 1
		cEofF3AFC := 	aCols[n][aScan(aHeader,{|x|Substr(x[2],4,7)=="_PROJET"})]+;
						aCols[n][aScan(aHeader,{|x|Substr(x[2],4,7)=="_REVISA"})]
		cBofF3AFC := cEofF3AFC
	Case cSXB == "AF9" .And. nOpcao == 2
		cEofF3AF9 := AF8->AF8_PROJET+AF8->AF8_REVISA
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AF9" .And. nOpcao == 10
		If Type('M->AFC_PROJET')# "U" .And. !Empty(M->AFC_PROJET)
			cEofF3AF9 := M->AFC_PROJET+M->AFC_REVISA
		ElseIf Type('M->AF9_PROJET')# "U"
			cEofF3AF9 := M->AF9_PROJET+M->AF9_REVISA
		Else
			cEofF3AF9 := AF8->AF8_PROJET+AF8->AF8_REVISA
		EndIf
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AFC" .And. nOpcao == 2
		cEofF3AFC := AF8->AF8_PROJET+AF8->AF8_REVISA
		cBofF3AFC := cEofF3AFC
	Case cSXB == "AFC" .And. nOpcao == 10
		If Type('M->AFC_PROJET')# "U" .And. !Empty(M->AFC_PROJET)
			cEofF3AFC := M->AFC_PROJET+M->AFC_REVISA
		ElseIf Type('M->AF9_PROJET')# "U"
			cEofF3AFC := M->AF9_PROJET+M->AF9_REVISA
		Else
			cEofF3AFC := AF8->AF8_PROJET+AF8->AF8_REVISA
		EndIf
		cBofF3AFC := cEofF3AFC
	Case cSXB == "AF9" .And. nOpcao == 3
		If l240
			cEofF3AF9 := M->D3_PROJPMS+PmsRevAtu(M->D3_PROJPMS)
			cBofF3AF9 := cEofF3AF9
		Else
			cEofF3AF9 := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="D3_PROJPMS"})]
			cEofF3AF9 += PmsRevAtu(cEofF3AF9)
			cBofF3AF9 := cEofF3AF9
		EndIf
	Case cSXB == "AF9" .And. nOpcao == 4
		cEofF3AF9 := aCols[n][aScan(aHeader,{|x|Substr(x[2],3,8)=="_PROJPMS"})]
		cEofF3AF9 += PmsRevAtu(cEofF3AF9)
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AF9" .And. nOpcao == 9
		cEofF3AF9 := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="D2_PROJPMS"})]
		cEofF3AF9 += PmsRevAtu(cEofF3AF9)
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AF9" .And. nOpcao == 8
		cEofF3AF9 := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="CN_PROJPMS"})]
		cEofF3AF9 += PmsRevAtu(cEofF3AF9)
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AFC" .And. nOpcao == 4
		cEofF3AFC := aCols[n][aScan(aHeader,{|x|Substr(x[2],3,8)=="_PROJPMS"})]
		cEofF3AFC += PmsRevAtu(cEofF3AFC)
		cBofF3AFC := cEofF3AFC
	Case cSXB == "AFC" .And. nOpcao == 9
		cEofF3AFC := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="D2_PROJPMS"})]
		cEofF3AFC += PmsRevAtu(cEofF3AFC)
		cBofF3AFC := cEofF3AFC
	Case cSXB == "AFC" .And. nOpcao == 5
		cEofF3AFC := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="CN_PROJPMS"})]
		cEofF3AFC += PmsRevAtu(cEofF3AFC)
		cBofF3AFC := cEofF3AFC
	Case cSXB == "AF9" .And. nOpcao == 5
		cEofF3AF9 := M->AFJ_PROJET+PmsRevAtu(M->AFJ_PROJET)
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AF9" .And. nOpcao == 6
		If Type('l320')# "U" .AND. l320
			cEofF3AF9 := M->AFU_PROJET+M->AFU_REVISA
			cBofF3AF9 := cEofF3AF9
		Else
			cEofF3AF9 := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_PROJET"})]+;
						 aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_REVISA"})]
			cBofF3AF9 := cEofF3AF9
		EndIf

	Case cSXB == "AF9" .And. nOpcao == 10
		If Type('l700')# "U" .AND. l700
			cEofF3AF9 := M->AJK_PROJET+M->AJK_REVISA
			cBofF3AF9 := cEofF3AF9
		Else
			cEofF3AF9 := aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJK_PROJET"})]+;
						 aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AJK_REVISA"})]
			cBofF3AF9 := cEofF3AF9
		EndIf

	Case cSXB == "AF2" .And. nOpcao == 1
		cEofF3AF2 := AF2->AF2_ORCAME
		cBofF3AF2 := cEofF3AF2
	Case cSXB == "AF2" .And. nOpcao == 2
		cEofF3AF2 := M->AF2_ORCAME
		cBofF3AF2 := cEofF3AF2
	Case cSXB == "AF5" .And. nOpcao == 2
		cEofF3AF5 := M->AF2_ORCAME
		cBofF3AF5 := cEofF3AF5
	Case cSXB == "AF2" .And. nOpcao == 3
		cEofF3AF2 := M->AF5_ORCAME
		cBofF3AF2 := cEofF3AF2
	Case cSXB == "AF5" .And. nOpcao == 3
		cEofF3AF5 := M->AF5_ORCAME
		cBofF3AF5 := cEofF3AF5
	Case cSXB == "AF9" .And. nOpcao == 7
		cEofF3AF9 := M->E5_PROJPMS+PmsRevAtu(M->E5_PROJPMS)
		cBofF3AF9 := cEofF3AF9
	Case cSXB == "AFC" .And. nOpcao == 7
		cEofF3AFC := M->E5_PROJPMS + PmsRevAtu(M->E5_PROJPMS)
		cBofF3AFC := cEofF3AFC

		cRecPag:= IIf((Type('cRecPag') == "U") .Or. (ValType(cRecPag) == "U"),"R",cRecPag) //Variável vinda do FINA100.
		If (cRecPag == "P")
			lRet:= .F.
		EndIf
	Case cSXB == "AFC" .And. nOpcao == 11
		cEofF3AFC := aCols[n][aScan(aHeader,{|x|Substr(x[2],4,7)=="_PROJET"})]
		cEofF3AFC += PmsRevAtu(cEofF3AF9)
		cBofF3AFC := cEofF3AF9
	Case cSXB == "AF9" .And. nOpcao == 11
		cEofF3AF9 := aCols[n][aScan(aHeader,{|x|Substr(x[2],4,7)=="_PROJET"})]
		cEofF3AF9 += PmsRevAtu(cEofF3AF9)
		cBofF3AF9 := cEofF3AF9

	Case cSXB == "AFC" .And. nOpcao == 91
		If ExistBlock("PMSSET91")
			cEofF3AFC := ExecBlock("PMSSET91",.F.,.F.)
			cBofF3AFC := cEofF3AFC
		Else
			cEofF3AFC := ''
			cBofF3AFC := ''
		EndIf
	Case cSXB == "AF9" .And. nOpcao == 92
		If ExistBlock("PMSSET92")
			cEofF3AF9 := ExecBlock("PMSSET92",.F.,.F.)
			cBofF3AF9 := cEofF3AF9
		Else
			cEofF3AF9 := ''
			cBofF3AF9 := ''
		EndIf
	OtherWise
		cEofF3AF2 := ''
		cBofF3AF2 := ''
		cEofF3AF5 := ''
		cBofF3AF5 := ''
		cEofF3AF9 := ''
		cBofF3AF9 := ''
		cEofF3AFC := ''
		cBofF3AFC := ''
EndCase

RestArea(aAreaAF8)
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PmsTskPad ³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta padrao das tarefas do projeto.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS, SXB - Consulta AF9                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsTskPad(nOpcao)
Local aRet
Local lRet := .F.
Local nPos := 0
Local nProc:= 1
Local cAlias := "AF8"
Private cTxtPesq := ""

DEFAULT nOpcao := 1

If nOpcao == 1
	If Type("aHeader")=="A"
		Do Case
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "D2_PROJPMS"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "C6_PROJPMS"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_PROJPMS"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "C1_PROJET"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "AFH_PROJET"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "AJ7_PROJET"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "AFG_PROJET"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "AJE_PROJET"}))>0
				cEofF3AF9 := aCols[n][nPos]
			Case (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "AFN_PROJET"}))>0
				cEofF3AF9 := aCols[n][nPos]
		EndCase
		cEofF3AF9 += PmsRevAtu(cEofF3AF9)
		cBofF3AF9 := cEofF3AF9
	EndIf

	do while !(ProcName(nProc) == "MATA241") .and. !(ProcName(nProc) == "")
		nProc++
	enddo
	if ProcName(nProc) == "MATA241" // Movimentações Internas modelo 2 (SD3)
		If Type("aHeader")=="A"
			If (nPos := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_PROJPMS"}))>0
				cEofF3AF9 := aCols[n][nPos]
			EndIf
			cEofF3AF9 += PmsRevAtu(cEofF3AF9)
			cBofF3AF9 := cEofF3AF9
		EndIf
	endif

 	If ProcName(nProc) == "" //nProc == 0
		nProc:=0
		do while !(Upper(ProcName(nProc)) == "PMS203DLG") .And. !(ProcName(nProc) == "")
			nProc++
		enddo
		If nProc >0 .AND. ProcName(nProc) == "PMS203DLG" // Se houve sucesso na busca da funcao de dialog da tarefa do projeto
			If Type("AF9_REVISA")=="C" .AND. !EMPTY(M->AF9_REVISA)
				cEofF3AF9 := Substr(cEofF3AF9,1,Len(AF8->AF8_PROJET)) + M->AF9_REVISA
			Else
				cEofF3AF9 := Substr(cEofF3AF9,1,Len(AF8->AF8_PROJET))+ PmsAF8Ver(cEofF3AF9)
			EndIf
			cBofF3AF9 := cEofF3AF9
		Endif
		If Type("lSimulaAJB") == "L"
			If lSimulaAJB
				cAlias := "AJB"
			EndIf
		EndIf

	EndIf

 	aRet := PmsSelTsk(STR0077,"AFC/AF9","AF9",STR0078,cAlias,Substr(cEofF3AF9,1,Len(AF8->AF8_PROJET)),.F.,,Substr(cEofF3AF9,Len(AF8->AF8_PROJET)+1,Len(AF8->AF8_REVISA)))	//"Selecione a Tarefa"###"Selecao Invalida. Esta consulta permite apenas a selecao das Tarefas do projeto. Verifique o objeto selecionado."
	If !Empty(aRet)
		If aRet[1]=="AF9"
			AF9->(dbGoto(aRet[2]))
			lRet := .T.
		EndIf
	EndIf
Else
	aRet := PmsSelTsk(STR0077,"AF5/AF2","AF2",STR0078,"AF1",Substr(cEofF3AF2,1,Len(AF1->AF1_ORCAME)),.F.)	//"Selecione a Tarefa"###"Selecao Invalida. Esta consulta permite apenas a selecao das Tarefas do projeto. Verifique o objeto selecionado."
	If !Empty(aRet)
		If aRet[1]=="AF2"
			AF2->(dbGoto(aRet[2]))
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BPMSEDTPad ³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta padrao das EDTs do projeto.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS, SXB - Consulta AFC                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSEDTPad(nOpcao)
Local aRet
Local lRet := .F.
Private cTxtPesq := ""

DEFAULT nOpcao := 1

If nOpcao == 1
	aRet := PmsSelTsk(STR0078,"AFC","AFC",STR0080,"AF8",Substr(cEofF3AFC,1,Len(AF8->AF8_PROJET)),.F.,,Substr(cEofF3AFC,Len(AF8->AF8_PROJET)+1,Len(AF8->AF8_REVISA)))//"Estrutura de Decomposicao do Trabalho (EDT)"###"Selecao Invalida. Esta consulta permite apenas a selecao das EDTs do projeto. Verifique o objeto selecionado."

	If !Empty(aRet)
		If aRet[1]=="AFC"
			AFC->(dbGoto(aRet[2]))
			lRet := .T.
		EndIf
	EndIf
Else
	aRet := PmsSelTsk(STR0078,"AF5","AF5",STR0080,"AF1",Substr(cEofF3AF5,1,Len(AF1->AF1_ORCAME)),.F.)//"Estrutura de Decomposicao do Trabalho (EDT)"###"Selecao Invalida. Esta consulta permite apenas a selecao das EDTs do projeto. Verifique o objeto selecionado."

	If !Empty(aRet)
		If aRet[1]=="AF5"
			AF5->(dbGoto(aRet[2]))
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSAjustaAFJ ºAutor  ³Pedro Pereira Lima  º Data ³  03/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta a tabela de empenho quando e feita uma alteracao em uma º±±
±±º          ³solicitacao de compra que gerou empenho para projeto.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSXFUN - PmsAtuEmp()                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSAjAFJ(cProjeto,cTarefa,cCodProd,cLocal,cTRT)

Local aArea    := GetArea()
Local aAreaAFI := AFI->(GetArea())
Local aAreaSD3 := SD3->(GetArea())
Local nQuant   := 0
Local cRevisa  := Posicione("AF8",1,xFilial("AF8")+cProjeto,"AF8_REVISA")

dbSelectArea("SD3")

SD3->(dbSetOrder(10))
SD3->(dbSeek(xFilial("SD3")+cProjeto+cTarefa+cCodProd+cLocal))
While SD3->( ! Eof() .And. D3_FILIAL+D3_PROJPMS+D3_TASKPMS+D3_COD+D3_LOCAL == xFilial("SD3")+cProjeto+cTarefa+cCodProd+cLocal )

	If SD3->D3_TRT == cTRT

		dbSelectArea("AFI")
		AFI->(dbSetOrder(2))

		If AFI->(dbSeek(xFilial("AFI")+cCodProd+cLocal+DTOS(SD3->D3_EMISSAO)+SD3->D3_NUMSEQ+cProjeto+cRevisa+cTarefa))
			nQuant := AFI->AFI_QUANT
			Exit
		Else
			SD3->(dbSkip())
		EndIf

	Else

		SD3->(dbSkip())

	EndIf

EndDo

RestArea(aAreaSD3)
RestArea(aAreaAFI)
RestArea(aArea)

Return nQuant


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSCpoCoUnºAutor  ³ Marcelo Akama      º Data ³  04/24/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera conteudo dos campos virtuais com o conteudo do campo  º±±
±±º          ³ da tabela espelho ou da original se não existir            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Parametros³ExpC1 : Campo                                               ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCpoCoUn(cCampo)
Local Ret:=''
Local cAlias
Local cAlias1
Local cAlias2
Local cChave1
Local cChave2
Local cField1
Local cField2
Local nOrd1
Local nOrd2
Local cAux
Local aArea   :=GetArea()
Local aArea1  :={}
Local aArea2  :={}
Local nPos
Local nGet    := IIf(Type("oFolder")="O",oFolder:nOption,1)
Local cCodIns
Local cCodSub
Local cGrOrga	:= ''
Local nQuant	:= 0
Local nQtSub	:= 0
Local nDMT		:= 0
Local nHrProd	:= 1
Local nHrImpr	:= 0
Local cTpParc

DEFAULT cCampo := 'AEL_CUSTD'

If Type("n")<>'N'
	n:=1
EndIf

cCampo:=Upper(alltrim(cCampo))
nPos:=At('->',cCampo)
If nPos>0
	cCampo:=Substring(cCampo,nPos+2,len(cCampo))
EndIf
cAlias:=Left(cCampo,3)
cAux:=Substring(cCampo,5,len(cCampo))

If (Type("aHeader") == "A") .And. (Type("aCols") == "A") .And. (nGet > 0) .And. left(aHeader[1][2],4)$"AEL_|AEN_"

	If (nGet == 1) //getdados de insumos
		nPos    := aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_INSUMO"})
		If nPos >0
			cCodIns := aCols[n,nPos]
		Else
			If Type("M->AEL_INSUMO") == "C"
				cCodIns := M->AEL_INSUMO
			Else
				nPos    := IIf(Type("aHeaderSV") == "A", aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_INSUMO"}), 0)
				cCodIns := IIf(nPos>0, aColsSV[1,n,nPos], CriaVar("AEL_INSUMO"))
			EndIF
		EndIf

		nPos    := aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_HRPROD"})
		If nPos >0 .AND. aCols[n,nPos] <> NIL
			nHrProd := aCols[n,nPos]
		Else
			If Type("M->AEL_HRPROD") == "N"
				nHrProd := M->AEL_HRPROD
			Else
				nPos    := IIf(Type("aHeaderSV") == "A", aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRPROD"}), 0)
				nHrProd := IIf(nPos>0, aColsSV[1,n,nPos], CriaVar("AEL_HRPROD"))
			EndIF
		EndIf

		nPos    := aScan(aHeader,{|x| AllTrim(x[2]) == "AEL_HRIMPR"})
		If nPos >0 .AND. aCols[n,nPos] <> NIL
			nHrImpr := aCols[n,nPos]
		Else
			If Type("M->AEL_HRIMPR") == "N"
				nHrImpr := M->AEL_HRPROD
			Else
				nPos    := IIf(Type("aHeaderSV") == "A", aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRIMPR"}), 0)
				nHrImpr := IIf(nPos>0, aColsSV[1,n,nPos], CriaVar("AEL_HRIMPR"))
			EndIF
		EndIf

	Else
		nPos    := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_INSUMO"})
		cCodIns := IIf(nPos>0 .and. Len( aColsSV[1] ) >= N, aColsSV[1,n,nPos], M->AEL_INSUMO)

		nPos    := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRPROD"})
		nHrProd := IIf(nPos>0 .and. Len( aColsSV[1] ) >= N, aColsSV[1][n,nPos], M->AEL_HRPROD)

		nPos    := aScan(aHeaderSV[1],{|x| AllTrim(x[2]) == "AEL_HRIMPR"})
		nHrImpr := IIf(nPos>0 .and. Len( aColsSV[1] ) >= N, aColsSV[1][n,nPos], M->AEL_HRIMPR)

    EndIf

	If (nGet == 3) //getdados de subcomposicao
		nPos    := aScan(aHeader,{|x| AllTrim(x[2]) == "AEN_SUBCOM"})
		If nPos >0
			cCodSub := aCols[n,nPos]
		Else
			If Type("M->AEN_SUBCOM") == "C"
				cCodSub := M->AEN_SUBCOM
			Else
				nPos    := aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_SUBCOM"})
				cCodSub := IIf(nPos>0, aColsSV[3,n,nPos], CriaVar("AEN_SUBCOM"))
			EndIF
		EndIf
	Else
		If Type("aHeaderSV")=="A" .And. len(aHeaderSV)>=3 .And. len(aHeaderSV[3])>=1 .And. left(aHeaderSV[3][1][2],4)=="AEN_" .And. len(aColsSV)>=3 .And. len(aColsSV[3])>=1
			nPos    := aScan(aHeaderSV[3],{|x| AllTrim(x[2]) == "AEN_SUBCOM"})
			cCodSub := IIf(nPos>0, aColsSV[3,1,nPos], M->AEN_SUBCOM)
		Else
			cCodSub := AEN->AEN_SUBCOM
		EndIf
    EndIf
//* reynaldo<end>
Else
	cCodIns := AEL->AEL_INSUMO
	nHrProd := AEL->AEL_HRPROD
	nHrImpr := AEL->AEL_HRIMPR
	cCodSub := AEN->AEN_SUBCOM
EndIf

If ValType( cCodIns ) <> "C"
	cCodIns	:= ""
EndIf

If ValType( nHrProd ) <> "N"
	nHrProd := 0
EndIf

If ValType( nHrImpr ) <> "N"
	nHrImpr := 0
EndIf

Do Case
	Case cAlias=='AEN'
		cAlias1 := 'AJT'
		nOrd1   := 2
		cChave1 := xFilial(cAlias1)+AF8->(AF8_PROJET+AF8_REVISA)+cCodSub
		cAlias2 := 'AEG'
		nOrd2   := 1
		cChave2 := xFilial(cAlias2)+cCodSub
	Otherwise // cAlias=='AEL'
		cAlias1 := 'AJY'
		nOrd1   := 1
		cChave1 := xFilial(cAlias1)+AF8->(AF8_PROJET+AF8_REVISA)+cCodIns
		cAlias2 := 'AJZ'
		nOrd2   := 1
		cChave2 := xFilial(cAlias2)+cCodIns
EndCase

aArea1 := (cAlias1)->(GetArea())
aArea2 := (cAlias2)->(GetArea())

If cAlias == 'AEL'
	If cCodIns==AEL->AEL_INSUMO
		cGrOrga:=AEL->AEL_GRORGA
		nQuant :=AEL->AEL_QUANT
		nDMT   :=AEL->AEL_DMT
	Else
		cGrOrga:=Posicione(cAlias1,nOrd1,cChave1,cAlias1+'_GRORGA')
		If (cAlias1)->(Eof())
			cGrOrga:=Posicione(cAlias2,nOrd2,cChave2,cAlias2+'_GRORGA')
		EndIf
		nQuant:=GdFieldGet("AEL_QUANT")
		nDMT  :=GdFieldGet("AEL_DMT")
		If valtype(nQuant)!='N'
			If cCodIns==AJU->AJU_INSUMO
				nQuant:=AJU->AJU_QUANT
			ElseIf cCodIns==AEH->AEH_INSUMO
				nQuant:=AEH->AEH_QUANT
			Else
				nQuant:=0
			EndIf
		EndIf
		If valtype(nDMT)!='N'
			If cCodIns==AJU->AJU_INSUMO
				nDMT:=AJU->AJU_DMT
			ElseIf cCodIns==AEH->AEH_INSUMO
				nDMT:=AEH->AEH_DMT
			Else
				nDMT:=0
			EndIf
		EndIf
	EndIf
ElseIf cAlias == 'AEN'
	If (Type("aHeader") == "A") .And. (Type("aCols") == "A")
		nQtSub := GdFieldGet("AEN_QUANT")
	ElseIf cCodSub==AEN->AEN_SUBCOM
		nQtSub := AEN->AEN_QUANT
	ElseIf cCodSub==AJX->AJX_SUBCOM
		nQtSub := AJX->AJX_QUANT
	ElseIf cCodSub==AEJ->AEJ_SUBCOM
		nQtSub := AEJ->AEJ_QUANT
	Else
		nQtSub := 0
	EndIf
EndIf

If cGrOrga != 'A'
	nHrProd := 0
EndIf

Do Case
	Case cAux=='DESCRI' .and. cAlias=='AEL'
		Ret:=Posicione(cAlias1,nOrd1,cChave1,cAlias1+"_DESC")
		If (cAlias1)->(Eof())
			Ret:=Posicione(cAlias2,nOrd2,cChave2,cAlias2+"_DESC")
		EndIf
	Case cAux=='MOEDA'
		Ret:=val(Posicione(cAlias1,nOrd1,cChave1,cAlias1+"_MCUSTD"))
	Case cAux=='SIMBMO'
		Ret:=GetNewPar("MV_SIMB"+Alltrim(Posicione(cAlias1,nOrd1,cChave1,cAlias1+"_MCUSTD")),"")
	Case cAux=='CUSTD'
		If cGrOrga=="A"
		    // somente se o tipo de parcela do insumo for calculada ou não calculada
			Ret:=(PMSCpoCoUn("AEL_CUSPRD")*nHrProd)+(PMSCpoCoUn("AEL_CUSIMP")*nHrImpr)
		Else
			Ret:=Posicione(cAlias1,nOrd1,cChave1,cAlias1+"_CUSTD")
			If (cAlias1)->(Eof())
				Ret:=Posicione(cAlias2,nOrd2,cChave2,cAlias2+"_CUSTD")
			EndIf
		EndIf
	Case cAux=='CUSPRD'
		If cGrOrga=="A"
			cTpParc:=Posicione(cAlias1,nOrd1,cChave1,cAlias1+"_TPPARC")
			If (cAlias1)->(Eof())
				cTpParc:=Posicione(cAlias2,nOrd2,cChave2,cAlias2+"_TPPARC")
			EndIf
			If cTpParc $"1;2"
				Ret:=IIf(AF8->AF8_DEPREC $ "13", PMSCpoCoUn("AEL_DEPREC"), 0) +;
					 IIf(AF8->AF8_JUROS  $ "13", PMSCpoCoUn("AEL_VLJURO"), 0) +;
					 IIf(AF8->AF8_MDO    $ "13", PMSCpoCoUn("AEL_MDO"   ), 0) +;
					 IIf(AF8->AF8_MATERI $ "13", PMSCpoCoUn("AEL_MATERI"), 0) +;
					 IIf(AF8->AF8_MANUT  $ "13", PMSCpoCoUn("AEL_MANUT" ), 0)

			Else
				Ret:=Posicione(cAlias1,nOrd1,cChave1,cAlias1+"_CUSTD")
				If (cAlias1)->(Eof())
					Ret:=Posicione(cAlias2,nOrd2,cChave2,cAlias2+"_CUSTD")
				EndIf
			EndIf
		Else
			Ret:=0
		EndIf
	Case cAux=='CUSIMP'
		If cGrOrga=="A"
			cTpParc:=Posicione(cAlias1,nOrd1,cChave1,cAlias1+"_TPPARC")
			If (cAlias1)->(Eof())
				cTpParc:=Posicione(cAlias2,nOrd2,cChave2,cAlias2+"_TPPARC")
			EndIf
			If cTpParc $"1;2"
				Ret:=IIf(AF8->AF8_DEPREC $ "23", PMSCpoCoUn("AEL_DEPREC"), 0) +;
					 IIf(AF8->AF8_MDO    $ "23", PMSCpoCoUn("AEL_MDO"   ), 0) +;
					 IIf(AF8->AF8_JUROS  $ "23", PMSCpoCoUn("AEL_VLJURO" ), 0)
			Else
				cField1 := iIf( cAlias1 == "AJY" ,"AJY_CUSTIM" ,cAlias1+"_CUSIMP")

				If cAlias2 == "AJZ"
					cField2 := "AJZ_CUSTIM"
				Else
					cField2 := iIf( cAlias2 == "AJY" ,"AJY_CUSTIM" ,cAlias2+"_CUSIMP")
				EndIf

				Ret:=Posicione(cAlias1,nOrd1,cChave1,cField1)
				If (cAlias1)->(Eof())
					Ret:=Posicione(cAlias2,nOrd2,cChave2,cField2)
				EndIf

			EndIf
		Else
			Ret:=0
		EndIf
	Case cAux=='CUSIT' .and. cAlias=='AEN'
		Ret:=PmsCusAJT(AF8->AF8_PROJET, AF8->AF8_REVISA, cCodSub, nQtSub)

	Case cAux=='CUSTO' .and. cAlias=='AEN'
		Ret:=PmsCusAJT(AF8->AF8_PROJET, AF8->AF8_REVISA, cCodSub, 1)

	Case cAux=='CUSIT' .and. cAlias=='AEL'
		Ret:=nQuant * PMSCpoCoUn("AEL_CUSTD")
		If cGrOrga == 'F'
			Ret := Ret * nDMT
		EndIf
	Case '.'+cAux+'.' $ ".PRODUC.QTOT.NUMEQ.VALENC.PADSAL.DMTX.CAPM3.VELO.TCDM.TPERC.TPTOT.PHM3.CSTUNI.MT.EMPOLA."
		Ret:=0
	Case '.'+cAux+'.' $ ".RECPAI.GRPREC."
		Ret:=''
	Otherwise
		Ret:=Posicione(cAlias1,nOrd1,cChave1,cAlias1+'_'+cAux)
		If (cAlias1)->(Eof())
			Ret:=Posicione(cAlias2,nOrd2,cChave2,cAlias2+'_'+cAux)
		EndIf
EndCase

RestArea(aArea1)
RestArea(aArea2)
RestArea(aArea)

Return Ret

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsEqpCUAloc³ Autor ³ Totvs               ³ Data ³ 21-05-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array contendo a alocacao da equipe e seu percent. ³±±
±±³          ³de projetos que usam composicao aux                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsEqpCUAloc(cEquipe,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,aRecAF9,aAE8xAF9,aAloc)
	Local lSeek			:= .T.
	Local aAuxAloc		:= {}
	Local cHoraRef		:= "00:00"
	Local dAuxRef		:= PMS_MAX_DATE
	Local dRef			:= PMS_MIN_DATE
	Local cAuxHoraRef	:= "24:00"
	Local aArea			:= GetArea()
	Local aAreaAE8		:= AE8->(GetArea())
	Local nX            := 0
	Local nY            := 0
	Local cRecurso		:= ""

	DEFAULT nFilter		:= 1

	DbSelectArea("AE8")
	AE8->( DbSetOrder( 4 ) )
	AE8->( DbSeek( xFilial( "AE8" ) + cEquipe ) )
	While AE8->( !Eof() ) .AND. AE8->( AE8_FILIAL + AE8_EQUIP ) == xFilial( "AE8" ) + cEquipe
		cRecurso := AE8->AE8_RECURS

		dbSelectArea( "AJY" )
		AJY->( DbSetOrder( 2 ) )
		AJY->( DbSeek( xFilial( "AJY" ) + cRecurso ) )
		While AJY->( !Eof() ) .AND. AJY->( AJY_FILIAL + AJY_RECURS ) == xFilial( "AJY" ) + cRecurso

			AEL->( DbSetOrder( 2 ) )
			If AEL->( DbSeek( xFilial( "AEL" ) + AJY->( AJY_PROJET + AJY_REVISA + AJY_INSUMO ) ) )
				AF8->( DbSetOrder( 1 ) )
				AF8->( DbSeek( xFilial( "AF8" ) + AJY->AJY_PROJET ) )

				AF9->( DbSetOrder( 1 ) )
				AF9->( DbSeek( xFilial( "AF9" ) + AEL->( AEL_PROJET + AEL_REVISA + AEL_TAREFA ) ) )

				If cAltTrf == Nil .Or.( cAltTrf <> Nil .And. AF9->AF9_TAREFA <> cAltTrf )
					If (AEL->AEL_REVISA==AF8->AF8_REVISA .And. cProjeto==Nil) .Or. (AEL->AEL_REVISA==AF8->AF8_REVISA .And. cProjeto!=AF8->AF8_PROJET).Or.(AEL->AEL_REVISA==cVersao .And. cProjeto==AF8->AF8_PROJET)
						If ( DTOS(AF9->AF9_START)+AF9->AF9_HORAI >= DTOS(DIni)+cHIni .And. DTOS(AF9->AF9_START)+AF9->AF9_HORAI  <= DTOS(dFim)+cHFim)  .Or. 	;
							( DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF >= DTOS(DIni)+cHIni .And. DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF <= DTOS(dFim)+cHFim) .Or.;
							( DTOS(AF9->AF9_START)+AF9->AF9_HORAI < DTOS(DIni)+cHIni .And. DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF > DTOS(dFim)+cHFim)

							Do Case
								Case nFilter==1  //Todas
									aAdd(aAuxAloc,{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,/*AF9->AF9_ALOC*/ 22})
									If aRecAF9 <> Nil
										aAdd(aRecAF9,AF9->(RecNo()) )
										If aAE8xAF9 <> Nil
											AAdd(aAE8xAF9,{Len(aRecAF9),AE8->(Recno())})
										Endif
									EndIf
								Case nFilter==2 .And. !Empty(AF9->AF9_DTATUF) //Tarefas Executadas
									aAdd(aAuxAloc,{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,/*AF9->AF9_ALOC*/ 22})
									If aRecAF9 <> Nil
										aAdd(aRecAF9,AF9->(RecNo()) )
										If aAE8xAF9 <> Nil
											AAdd(aAE8xAF9,{Len(aRecAF9),AE8->(Recno())}		)
										Endif
									EndIf
								Case nFilter==3 .And. Empty(AF9->AF9_DTATUF) //Tarefas a Executar
									aAdd(aAuxAloc,{AF9->AF9_START,AF9->AF9_HORAI,AF9->AF9_FINISH,AF9->AF9_HORAF,/*AF9->AF9_ALOC*/ 22})
									If aRecAF9 <> Nil
										aAdd(aRecAF9,AF9->(RecNo()) )
										If aAE8xAF9 <> Nil
											AAdd(aAE8xAF9,{Len(aRecAF9),AE8->(Recno())}		 )
										Endif
									EndIf
							EndCase
						EndIf
					EndIf
				EndIf
			EndIf

			AJY->( DbSkip() )
		End

		AE8->( DbSkip() )
	End

	While lSeek
		lSeek := .F.
		For nx := 1 to Len(aAuxAloc)
			If DTOS(aAuxAloc[nx][1])+aAuxAloc[nx][2]>DTOS(dRef)+cHoraRef .And. ;
				DTOS(aAuxAloc[nx][1])+aAuxAloc[nx][2]<DTOS(dAuxRef)+cAuxHoraRef
				lSeek	:= .T.
				dAuxRef	:= aAuxAloc[nx][1]
				cAuxHoraRef:= aAuxAloc[nx][2]
			EndIf
			If DTOS(aAuxAloc[nx][3])+aAuxAloc[nx][4]>DTOS(dRef)+cHoraRef .And.;
				DTOS(aAuxAloc[nx][3])+aAuxAloc[nx][4]<DTOS(dAuxRef)+cAuxHoraRef
				lSeek	:= .T.
				dAuxRef	:= aAuxAloc[nx][3]
				cAuxHoraRef:= aAuxAloc[nx][4]
			EndIf
		Next
		If lSeek
			dRef := dAuxRef
			cHoraRef := cAuxHoraRef
			aAdd(aAloc,{dAuxRef,cAuxHoraRef,0})


			dAuxRef		:= PMS_MAX_DATE
			cAuxHoraRef	:= "24:00"
		EndIf
	End

	For nx := 1 to Len(aAloc)-1
		dIni	:= aAloc[nx][1]
		cHIni	:= aAloc[nx][2]
		dFim	:= aAloc[nx+1][1]
		cHFim	:= aAloc[nx+1][2]
		For ny := 1 to Len(aAuxAloc)
			If  ((DTOS(aAuxAloc[ny][1])+aAuxAloc[ny][2] > DTOS(dIni)+cHIni .And.;
				DTOS(aAuxAloc[ny][1])+aAuxAloc[ny][2] < DTOS(dFim)+cHFim) .Or.;
				(DTOS(aAuxAloc[ny][3])+aAuxAloc[ny][4] > DTOS(dIni)+cHIni .And.;
				DTOS(aAuxAloc[ny][3])+aAuxAloc[ny][4] < DTOS(dFim)+cHFim)) .Or.;
				((DTOS(aAuxAloc[ny][1])+aAuxAloc[ny][2]<= DTOS(dIni)+cHIni .And.;
				DTOS(aAuxAloc[ny][3])+aAuxAloc[ny][4] >= DTOS(dFim)+cHFim))
				aAloc[nx][3] += aAuxAloc[ny][5]
			EndIf
		Next
	Next

	RestArea( aAreaAE8 )
	RestArea( aArea )

Return aAloc
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetCUAloc³ Autor ³ Totvs               ³ Data ³ 21-05-2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array contendo a alocacao do recurso e seu percent.³±±
±±³          ³de projeto que usam composicao aux                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRetCUAloc(cRecurso,dIni,cHIni,dFim,cHFim,nFilter,cProjeto,cVersao,cAltTrf,aRecAF9,aDadosSim,aCache,cFiltAF9, aAloc)

Local lSeek			:= .T.
Local aAuxAloc		:= {}
Local cHoraRef		:= "00:00"
Local dAuxRef		:= CtoD( "01/12/25" )
Local dRef			:= PMS_MIN_DATE
Local cAuxHoraRef	:= "24:00"
Local aArea			:= GetArea()
Local aAreaAEL		:= AEL->(GetArea())
Local nX			:= 0
Local nY			:= 0
Local lSimula		:= (aDadosSim<>Nil)
Local cAliasAEL		:= "AEL"
Local cQryAEL		:=	""
/*aDadosSim contem algumas tarefas e seus dados que serao consideradas ao inves das tarefas gravadas, isto eh para
poder verificar a alocacao com dados simulados
aDadosSim[1][1] = .
         [1][2] = .
                = .
         [1][n] = .
aDadosSim[2][1] = .............
aDadosSim[n][n] = .............
*/

Local lTcSrvType  := .F.

DEFAULT nFilter		:= 1
DEFAULT aAloc		:= {}
DEFAULT cProjeto	:= ""
DEFAULT cVersao		:= ""

If aCache==Nil
	aCache := {}
	#IFDEF TOP
		dbSelectArea("AF8")
		dbSetOrder(1)
		dbSelectARea("AF9")
		dbSetOrder(1)
		lTcSrvType := TcSrvType() <> "AS/400"
	#ENDIF
	dbSelectArea("AEL")
	dbSetOrder(1)

	If lTcSrvType
		#IFDEF TOP
		cAliasAEL	:=	GetNextAlias()

		cQryAEL := " SELECT	AF9_FILIAL,	AF9_PROJET, AF9_REVISA, AF9_TAREFA, AF9_START, "
		cQryAEL += " 		AF9_HORAI, AF9_FINISH, AF9_HORAF, AF8.R_E_C_N_O_ REG_AF8, "
		cQryAEL += " 		AF8_REVISA, AF8_PROJET, AJY_RECURS,	AF9.R_E_C_N_O_ REG_AF9,	AEL.R_E_C_N_O_ REG_AEL "
		cQryAEL += " FROM " + RetSqlName( "AF8" ) + " AF8 " "
		cQryAEL += " LEFT JOIN " + RetSqlName( "AF9" ) + " AF9 ON AF9_PROJET = AF8_PROJET AND AF9_REVISA = AF8_REVISA "
		cQryAEL += " LEFT JOIN " + RetSqlName( "AEL" ) + " AEL ON AEL_PROJET = AF8_PROJET AND AEL_REVISA = AF8_REVISA AND AEL_TAREFA = AF9_TAREFA "
		cQryAEL += " LEFT JOIN " + RetSqlName( "AJY" ) + " AJY ON AJY_INSUMO = AEL_INSUMO AND AJY_PROJET = AEL_PROJET AND AJY_REVISA = AEL_REVISA "
		cQryAEL += " WHERE	AJY_RECURS = '" + cRecurso + "'  AND "
		cQryAEL += " 		( (AF9_START  >= '"+DTOS(DIni)+"' AND AF9_HORAI >= '"+cHIni+"'  AND AF9_START  <= '"+DTOS(DFim)+"' AND AF9_HORAI <= '"+cHFim+"') OR "
		cQryAEL += " 		  (AF9_FINISH >= '"+DTOS(DIni)+"' AND AF9_HORAF >= '"+cHIni+"'  AND AF9_FINISH <= '"+DTOS(DFim)+"' AND AF9_HORAF <= '"+cHFim+"') OR "
		cQryAEL += " 		  (AF9_START  >= '2"+DTOS(DIni)+"' AND AF9_HORAI <  '"+cHIni+"'  AND AF9_FINISH <= '"+DTOS(DFim)+"' AND AF9_HORAF > '"+cHFim+"' )  ) AND "
		cQryAEL += " 		AF8_FILIAL = '" + xFilial( "AF8" ) + "'  AND "
		cQryAEL += " 		AF9_FILIAL = '" + xFilial( "AF9" ) + "'  AND "
		cQryAEL += " 		AEL_FILIAL = '" + xFilial( "AEL" ) + "'  AND "
		cQryAEL += " 		AJY_FILIAL = '" + xFilial( "AJY" ) + "' AND "
		cQryAEL += " 		AJY_PROJET = AF8_PROJET  AND "
		cQryAEL += " 		AJY_REVISA = AF8_REVISA  AND "

		If !Empty( cProjeto ) .AND. !Empty( cVersao )
			cQryAEL += " 		AF8_PROJET = '" + cProjeto + "' AND "
			cQryAEL += " 		AF8_REVISA = '" + cVersao + "' AND "
		EndIf

		cQryAEL += " 		AF8.D_E_L_E_T_ = ' ' AND "
		cQryAEL += " 		AF9.D_E_L_E_T_ = ' ' AND "
		cQryAEL += " 		AEL.D_E_L_E_T_ = ' ' AND "
		cQryAEL += " 		AJY.D_E_L_E_T_ = ' ' "
		cQryAEL += " AND AF8_ENCPRJ <> '1' "	//APENAS TAREFAS DE PROJETOS NAO ENCERRADOS

		If cAltTrf <> Nil 					/// Se indicou alteraçao de tarefa
			cQryAEL += " AND AF9_TAREFA <> '"+cAltTrf+"' "	// Seleciona apenas as tarefas diferentes
		EndIf

		If nFilter==2
			cQryAEL += " AND AF9_DTATUF <> '' "			//Tarefas Executadas
		ElseIf nFilter==3
			cQryAEL += " AND AF9_DTATUF = '' "			// Tarefas a Executar
		EndIf

		If cFiltAF9	<> Nil .And. !Empty(cFiltAF9)
			cAF9QryFil	:= PcoParseFil( cFiltAF9, "AF9" )
			If !Empty(cAF9QryFil)
				cQryAEL 	+= " AND ( "+cAF9QryFil +") "
				cFiltAF9	:= Nil
			Endif
		Endif

		cQryAEL += " ORDER BY AF9_FILIAL,AJY_RECURS,AF9_START,AF9_HORAI"

		If Select(cAliasAEL) > 0
			dbSelectArea(cAliasAEL)
			dbCloseArea()
		EndIf

		cQryAEL := ChangeQuery(cQryAEL)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryAEL),cAliasAEL,.F.,.T.)

		TCSetField(cAliasAEL,"REG_AEL","N",17,0)
		TCSetField(cAliasAEL,"REG_AF8","N",17,0)
		TCSetField(cAliasAEL,"REG_AF9","N",17,0)
		TCSetField(cAliasAEL,"AF9_START","D",8,0)
		TCSetField(cAliasAEL,"AF9_FINISH","D",8,0)
		TCSetField(cAliasAEL,"AEL_ALOC","N",6,2)

		dbSelectArea(cAliasAEL)
		While (cAliasAEL)->(!Eof())
			If cFiltAF9 <> Nil.And. !Empty(cFiltAF9)
				AF9->(msGOTO((cAliasAEL)->REG_AF9))
				If !AF9->(&cFiltAF9.)
					DbSelectArea(cAliasAEL)
					DbSkip()
					Loop
				Endif
			Endif
			If !lSimula .Or. Ascan(aDadosSim,{|x| x[SIM_RECAF9]==(cAliasAEL)->REG_AF9 .And. cRecurso== x[SIM_RECURS]}) ==0// Este registro deve ser ignorado, pois foi enviado um simulado para ele

				If ((cAliasAEL)->AF9_REVISA==(cAliasAEL)->AF8_REVISA .And. cProjeto==Nil) .Or.;
					((cAliasAEL)->AF9_REVISA==(cAliasAEL)->AF8_REVISA .And. cProjeto!=(cAliasAEL)->AF8_PROJET).Or.;
					((cAliasAEL)->AF9_REVISA==cVersao .And. cProjeto==(cAliasAEL)->AF8_PROJET)

					aAdd(aAuxAloc,{(cAliasAEL)->AF9_START,(cAliasAEL)->AF9_HORAI,(cAliasAEL)->AF9_FINISH,(cAliasAEL)->AF9_HORAF,/*(cAliasAEL)->AF9_ALOC*/ 11 })
					aAdd(aCache,(cAliasAEL)->REG_AEL )
					If aRecAF9 <> Nil
						aAdd(aRecAF9,(cAliasAEL)->REG_AF9 )
					EndIf
				EndIf
			EndIf

			(cAliasAEL)->(dbSkip())
		EndDo
		DbSelectArea(cAliasAEL)
		DbCloseArea()
		DbSelectArea("AEL")
		#ENDIF

	Else

		MsSeek(xFilial()+cRecurso)
		While !Eof() .And. xFilial()+cRecurso==AEL_FILIAL+AEL_RECURS
			AF8->(dbSetOrder(1))
			AF8->(MsSeek(xFilial()+AEL->AEL_PROJET))
			If AF8->AF8_ENCPRJ != "1" //SOMENTE PARA PROJETOS NAO ENCERRADOS
				AF9->(dbSetOrder(1))
				AF9->(MsSeek(xFilial()+AEL->AEL_PROJET+AEL->AEL_REVISA+AEL->AEL_TAREFA))

				If !lSimula .Or. Ascan(aDadosSim,{|x| x[SIM_RECAF9]==AF9->(RECNO()) .And. cRecurso== x[SIM_RECURS]}) ==0// Este registro deve ser ignorado, pois foi enviado um simulado para ele
					If cAltTrf == Nil .Or.( cAltTrf <> Nil .And. AF9->AF9_TAREFA <> cAltTrf )
						If (AEL->AEL_REVISA==AF8->AF8_REVISA .And. cProjeto==Nil) .Or. (AEL->AEL_REVISA==AF8->AF8_REVISA .And. cProjeto!=AF8->AF8_PROJET).Or.(AEL->AEL_REVISA==cVersao .And. cProjeto==AF8->AF8_PROJET)
							If ( DTOS(AEL->AEL_START)+AEL->AEL_HORAI >= DTOS(DIni)+cHIni .And. DTOS(AEL->AEL_START)+AEL->AEL_HORAI  <= DTOS(dFim)+cHFim)  .Or. 	;
								( DTOS(AEL->AEL_FINISH)+AEL->AEL_HORAF >= DTOS(DIni)+cHIni .And. DTOS(AEL->AEL_FINISH)+AEL->AEL_HORAF <= DTOS(dFim)+cHFim) .Or.;
								( DTOS(AEL->AEL_START)+AEL->AEL_HORAI < DTOS(DIni)+cHIni .And. DTOS(AEL->AEL_FINISH)+AEL->AEL_HORAF > DTOS(dFim)+cHFim)

								Do Case
								Case nFilter==1  //Todas
									aAdd(aAuxAloc,{AEL->AEL_START,AEL->AEL_HORAI,AEL->AEL_FINISH,AEL->AEL_HORAF,AEL->AEL_ALOC})
									aAdd(aCache,AEL->(RecNo()) )
									If aRecAF9 <> Nil
										aAdd(aRecAF9,AF9->(RecNo()) )
									EndIf
								Case nFilter==2 .And. !Empty(AF9->AF9_DTATUF) //Tarefas Executadas
									aAdd(aAuxAloc,{AEL->AEL_START,AEL->AEL_HORAI,AEL->AEL_FINISH,AEL->AEL_HORAF,AEL->AEL_ALOC})
									aAdd(aCache,AEL->(RecNo()) )
									If aRecAF9 <> Nil
										aAdd(aRecAF9,AF9->(RecNo()) )
									EndIf
								Case nFilter==3 .And. Empty(AF9->AF9_DTATUF) //Tarefas a Executar
									aAdd(aAuxAloc,{AEL->AEL_START,AEL->AEL_HORAI,AEL->AEL_FINISH,AEL->AEL_HORAF,AEL->AEL_ALOC})
									aAdd(aCache,AEL->(RecNo()) )
									If aRecAF9 <> Nil
										aAdd(aRecAF9,AF9->(RecNo()) )
									EndIf
								EndCase
							EndIf
						EndIf
					EndIf
				EndIf
			Endif

			dbSkip()
		EndDo
	EndIf

Else
	For nx := 1 to Len(aCache)
		dbSelectArea("AEL")
		dbGoto(aCache[nx])
		AF9->(dbSetOrder(1))
		AF9->(MsSeek(xFilial()+AEL->AEL_PROJET+AEL->AEL_REVISA+AEL->AEL_TAREFA))
		// Quando esta cacheado apenas reavalia o filtro do cache
		Do Case
			Case nFilter==1  //Todas
				aAdd(aAuxAloc,{AEL->AEL_START,AEL->AEL_HORAI,AEL->AEL_FINISH,AEL->AEL_HORAF,AEL->AEL_ALOC})
				If aRecAF9 <> Nil
					aAdd(aRecAF9,AF9->(RecNo()) )
				EndIf
			Case nFilter==2 .And. !Empty(AF9->AF9_DTATUF) //Tarefas Executadas
				aAdd(aAuxAloc,{AEL->AEL_START,AEL->AEL_HORAI,AEL->AEL_FINISH,AEL->AEL_HORAF,AEL->AEL_ALOC})
				If aRecAF9 <> Nil
					aAdd(aRecAF9,AF9->(RecNo()) )
				EndIf
			Case nFilter==3 .And. Empty(AF9->AF9_DTATUF) //Tarefas a Executar
				aAdd(aAuxAloc,{AEL->AEL_START,AEL->AEL_HORAI,AEL->AEL_FINISH,AEL->AEL_HORAF,AEL->AEL_ALOC})
				If aRecAF9 <> Nil
					aAdd(aRecAF9,AF9->(RecNo()) )
				EndIf
		EndCase
	Next
EndIf
If lSimula
	For nX := 1 To Len(aDadosSim)
		//		cProjeto	:=
		//		cVersao 	:=	aDadosSim[nX][SIM_REVISA ]
		cTarefa	:=	aDadosSim[nX][SIM_TAREFA]
		AF8->(MsSeek(xFilial()+aDadosSim[nX][SIM_PROJETO]))
		If cAltTrf == Nil .Or.( cAltTrf <> Nil .And. cTarefa <> cAltTrf )

			If (aDadosSim[nX][SIM_REVISA]==AF8->AF8_REVISA .And. cProjeto==Nil) .Or. (aDadosSim[nX][SIM_REVISA]==AF8->AF8_REVISA .And. cProjeto!=AF8->AF8_PROJET).Or.(aDadosSim[nX][SIM_REVISA]==cVersao .And. cProjeto==AF8->AF8_PROJET)
				If ( DTOS(aDadosSim[nX][SIM_START])+aDadosSim[nX][SIM_HORAI] >= DTOS(DIni)+cHIni 	.And. DTOS(aDadosSim[nX][SIM_START])+aDadosSim[nX][SIM_HORAI]  <= DTOS(dFim)+cHFim)  .Or. 	;
					( DTOS(aDadosSim[nX][SIM_FINISH])+aDadosSim[nX][SIM_HORAF]>= DTOS(DIni)+cHIni 	.And. DTOS(aDadosSim[nX][SIM_FINISH])+aDadosSim[nX][SIM_HORAI] <= DTOS(dFim)+cHFim) .Or.;
					( DTOS(aDadosSim[nX][SIM_START])+aDadosSim[nX][SIM_HORAI] < DTOS(DIni)+cHIni 	.And. DTOS(aDadosSim[nX][SIM_FINISH])+aDadosSim[nX][SIM_HORAI] > DTOS(dFim)+cHFim)
					aAdd(aAuxAloc,{aDadosSim[nX][SIM_START],aDadosSim[nX][SIM_HORAI],aDadosSim[nX][SIM_FINISH],aDadosSim[nX][SIM_HORAF],aDadosSim[nX][SIM_ALOC]})
					If aRecAF9 <> Nil .And. aDadosSim[nX][SIM_RECAF9] <> 0
						aAdd(aRecAF9,aDadosSim[nX][SIM_RECAF9] )
					EndIf

				EndIf
			Endif
		EndIf
	Next nX
Endif
While lSeek
	lSeek := .F.
	For nx := 1 to Len(aAuxAloc)
		If DtoS( aAuxAloc[nx][1] )+aAuxAloc[nx][2] > DtoS( dRef )+cHoraRef .And. ;
			DtoS( aAuxAloc[nx][1] )+aAuxAloc[nx][2] < DtoS( dAuxRef )+cAuxHoraRef
			lSeek	:= .T.
			dAuxRef	:= aAuxAloc[nx][1]
			cAuxHoraRef:= aAuxAloc[nx][2]
		EndIf
		If DtoS( aAuxAloc[nx][3] )+aAuxAloc[nx][4] > DtoS( dRef )+cHoraRef .And.;
			DtoS( aAuxAloc[nx][3] )+aAuxAloc[nx][4] < DtoS( dAuxRef )+cAuxHoraRef
			lSeek	:= .T.
			dAuxRef	:= aAuxAloc[nx][3]
			cAuxHoraRef:= aAuxAloc[nx][4]
		EndIf
	Next
	If lSeek
		dRef := dAuxRef
		cHoraRef := cAuxHoraRef
		aAdd(aAloc,{dAuxRef,cAuxHoraRef,0})

		dAuxRef		:= CtoD( "01/12/25" )
		cAuxHoraRef	:= "24:00"
	EndIf
End
For nx := 1 to Len(aAloc)-1
	dIni	:= aAloc[nx][1]
	cHIni	:= aAloc[nx][2]
	dFim	:= aAloc[nx+1][1]
	cHFim	:= aAloc[nx+1][2]
	For ny := 1 to Len(aAuxAloc)
		If  ((DtoS( aAuxAloc[ny][1] )+aAuxAloc[ny][2] > DTOS(dIni)+cHIni .And.;
			DtoS( aAuxAloc[ny][1] )+aAuxAloc[ny][2] < DTOS(dFim)+cHFim) .Or.;
			(DtoS( aAuxAloc[ny][3] )+aAuxAloc[ny][4] > DTOS(dIni)+cHIni .And.;
			DtoS( aAuxAloc[ny][3] )+aAuxAloc[ny][4] < DTOS(dFim)+cHFim)) .Or.;
			((DtoS( aAuxAloc[ny][1] )+aAuxAloc[ny][2]<= DTOS(dIni)+cHIni .And.;
			DtoS( aAuxAloc[ny][3] )+aAuxAloc[ny][4] >= DTOS(dFim)+cHFim))
			aAloc[nx][3] += aAuxAloc[ny][5]
		EndIf
	Next
Next

RestArea(aAreaAEL)
RestArea(aArea)
Return aAloc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVerCompºAutor  ³Clovis Magenta      º Data ³  27/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que verifica se um determinado produto se encontra  º±±
±±º          ³ em uma composicao que gerou tarefa  	 	                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA010 (Cad. Produtos)                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsVerComp(cCodigo)

Local lAchou 	:= .F.
Local cKey		:= ""
Local cIndex	:= ""
Local cCondicao := ""
Local nIndex  	:= 0
Local lRetorno	:= .T.
DEFAULT cCodigo := ""

dbSelectArea("AE1")
dbsetOrder(1) //AE1_FILIAL+AE1_COMPOS
AE1->(dbGoTop())
While AE1->( !Eof() ) .and. !lAchou

	dbSelectArea("AE2")
	dbSetOrder(1) //AE2_FILIAL+AE2_COMPOS+AE2_ITEM
	dbSeek(xFilial("AE2")+AE1->AE1_COMPOS)
	While AE1->( !Eof() ) .and. AE2->AE2_COMPOS == AE1->AE1_COMPOS .and. !lAchou

		If !(lAchou := (Alltrim(AE2->AE2_PRODUT) == Alltrim(cCodigo)))
			AE2->( dbSkip() )
		EndIf

	EndDo

	If !lAchou
		AE1->( dbSkip() )
	EndIf
EndDo

If lAchou
	dbSelectArea("AF9")
	cIndex	:= CriaTrab(,.F.)
	cCondicao := 'AF9_FILIAL=="'+xFilial("AF9")+'" .And. AF9_COMPOS=="'+AE2->AE2_COMPOS+'"'

	IndRegua("AF9",cIndex,cKey,,cCondicao)
	dbSelectArea("AF9")
	nIndex := RetIndex("AF9")
	#IFNDEF TOP
	DbSetIndex(cIndexo+OrdBagExt())
	#ENDIF
	DbSetOrder(nIndex+1)
	dbGoTop()

	If !EMPTY(AF9->AF9_PROJET)
		lRetorno := .F.
		Help( " ", 1, "PMSAUTOAF9",, STR0081+CRLF+STR0015+" "+AF9->AF9_PROJET , 1, 0 )//Este registro está amarrado a uma composição que gerou uma tarefa no Módulo PMS e não poderá ser excluído.
	EndIf
EndIf

dbSelectArea("AF9")
dbClearFilter()

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSVLDAFN ºAutor  ³Pedro Pereira Lima  º Data ³  15/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validacao do projeto que gerou a SC/PC que sera    º±±
±±º          ³amarrado ao documento de entrada quando MV_PMSIPC <> 1.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA103 - Rotina Automatica                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSVLDAFN(nItem)
Local aArea   := GetArea()
Local aAreaAFN:= AFN->(GetArea())
Local aAreaSC7:= SC7->(GetArea())
Local aSavAFN := aClone(aAutoAFN) //O array quando estiver na dimensao aAutoAFN[N][2]
Local aSavCols:= aClone(aCols)    //deverá conter uma estrutura semelhante a do aCols da tela de amarracao de PC com Projeto
Local aSavHead:= aClone(aHeader)
Local aSavItem:= aClone(aAutoItens)
Local lOk := .T.
Local nPosPc     := aScan(aAutoItens[nItem],{|x| AllTrim(x[1])=="D1_PEDIDO"})
Local nPosItemPc := aScan(aAutoItens[nItem],{|x| AllTrim(x[1])=="D1_ITEMPC"})
Local lMsFilAFG		:= AFG->(ColumnPos("AFG_MSFIL")) > 0


//Posiciono o SC7 para verificar se existe pedido de compra
dbSelectArea("SC7")
dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
If nPosPc > 0 .and. nPosItemPc > 0
	If MsSeek(xFilial("SC7") + aAutoItens[nItem][nPosPc][2] + aAutoItens[nItem][nPosItemPc][2])
		If !Empty(SC7->C7_NUMSC)//Se veio de solicitacao de compra
			If SC7->C7_TIPO == 1
				dbSelectArea("SC1")
				dbSetOrder(1)
				If dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)//Verifico se existe na solicitacao de compra
					// Busca na amarracao da solicitacao de compra com a tarefa do projeto
					dbSelectArea("AFG")
					dbSetOrder(2) //AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC+AFG_PROJET+AFG_REVISA+AFG_TAREFA
					If lMsFilAFG
						//Verifica se existe a origem da amarracao esta na Solicitacao de Compra
						If DbSeek(xFilial("AFG") + SC1->C1_NUM + SC1->C1_ITEM)
							lOk := .F.
							While xFilial("AFG") + SC1->C1_NUM + SC1->C1_ITEM == AFG->(AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC)
								// Se encontrar a solicitacao e item de compra da filial corrente associada ao projeto e tarefa, conclui a busca.
								If ( AFG->AFG_MSFIL == cFilAnt)
									lOk := .T.
									Exit
								EndIf
								DbSkip()
							EndDo
						Else
							lOk := .F.
						EndIf
					Else
						//Verifica se existe a origem da amarracao esta na Solicitacao de Compra
						If !DbSeek(xFilial("AFG") + SC1->C1_NUM + SC1->C1_ITEM)
							lOk := .F.
						EndIf
					EndIF
				EndIf
			EndIf
		Else
			lOk := .F.
		EndIf
	Endif
EndIf

aAutoItens:= aClone(aSavItem)
aAutoAFN  := aClone(aSavAFN)
aHeader   := aClone(aSavHead)
aCols     := aClone(aSavCols)

RestArea(aAreaSC7)
RestArea(aAreaAFN)
RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS140IPC ºAutor  ³Pedro Pereira Lima  º Data ³  03/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encapsulamento da funcao PMS103IPC para uso na rotina de    º±±
±±º          ³pre-nota de entrada, no MATA140.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ A140NFiscal - MATA140                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS140IPC(n)

PMS103IPC(n)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³aChangePosºAutor  ³Clovis Magenta      º Data ³  08/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao generica para trocar posições dentro de um array     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA001                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function aChangePos(aTST, nPos1, nPos2)
Local cParam1 := ""
Local cParam2 := ""
DEFAULT aTST  := {}
DEFAULT nPos1 := 0
DEFAULT nPos2 := 0

if (nPos1>0) .and. (nPos2>0)
	cParam1 := aTST[nPos1]
	cParam2 := aTST[nPos2]

	aTST[nPos1] := cParam2
	aTST[nPos2] := cParam1
EndIf

Return aTST

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMSF3BComp  ºAutor³Marcelo Akama              º Data ³ 15/10/2009   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Consulta padrão para buscar do banco de composicoes ou do SX5       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PMSF3BComp()                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³                                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos / Template Construção Civil                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSF3BComp()
Local cRet

// Se usa composicao unica, usa consulta padrao AJW, caso contrario, I6
cRet := ConPad1( ,,, IIf(AF8ComAJT(AF8->AF8_PROJET),"AJW","I6"),,, .F. )

Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsHasRsrc³ Autor ³ Marcelo Akama			³ Data ³ 14/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna se a tarefa tem recursos							    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsHasRsrc(cProjet, cRevisa, cTarefa, cRecurso)
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaAFA
Local aAreaAEL
Local aAreaAEN
Local aAreaAJT
Local aAreaAJU
Local aAreaAJY

// se for tratativa por composicao auxiliar
If AF8ComAJT(AF8->AF8_PROJET)

	aAreaAEL	:= AEL->(GetArea())
	aAreaAEN	:= AEN->(GetArea())
	aAreaAJT	:= AJT->(GetArea())
	aAreaAJU	:= AJU->(GetArea())
	aAreaAJY	:= AJY->(GetArea())

	//Verifica insumos
	DbSelectArea( "AEL" )
	AEL->( DbSetOrder( 1 ) )
	If AEL->( DbSeek( xFilial( "AEL" ) + cProjet + cRevisa + cTarefa ) )
		Do While !lRet .And. !AEL->(Eof()) .And. AEL->(AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA)==xFilial( "AEL" ) + cProjet + cRevisa + cTarefa
			DbSelectArea( "AJY" )
			AJY->( DbSetOrder( 1 ) ) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
			If AJY->( DbSeek( xFilial( "AJY" ) + AEL->( AEL_PROJET + AEL_REVISA + AEL_INSUMO ) ) )
				If AJY->AJY_RECURS == cRecurso
					lRet := .T.
				EndIf
			EndIf
			AEL->(DbSkip())
		EndDo
	EndIf

	If !lRet // Se nao existir nos insumos, verifica subcomposicoes

		DbSelectArea( "AEN" )
		AEN->( DbSetOrder( 1 ) )
		If AEN->( DbSeek( xFilial( "AEN" ) + cProjet + cRevisa + cTarefa ) )
			Do While !lRet .And. !AEN->(Eof()) .And. AEN->(AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA)==xFilial( "AEN" ) + cProjet + cRevisa + cTarefa
				DbSelectArea( "AJT" ) //AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
				AJT->( DbSetOrder( 2 ) )
				If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + AEN->AEN_SUBCOM ) )
					Do While !lRet .And. !AJT->(Eof()) .And. AJT->(AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN)==xFilial( "AJT" ) + cProjet + cRevisa + AEN->AEN_SUBCOM
						DbSelectArea( "AJU" )
						AJU->( DbSetOrder( 3 ) ) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
						If AJU->( DbSeek( xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
							Do While !lRet .And. !AJU->(Eof()) .And. AJU->(AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN)==xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN
								DbSelectArea( "AJY" )
								AJY->( DbSetOrder( 1 ) ) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
								If AJY->( DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + AJU_INSUMO ) ) )
									If AJY->AJY_RECURS == cRecurso
										lRet := .T.
									EndIf
								EndIf
								AJU->(DbSkip())
							EndDo
						EndIf
						AJT->(DbSkip())
					EndDo
				EndIf
				AEN->(DbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(aAreaAJY)
	RestArea(aAreaAJU)
	RestArea(aAreaAJT)
	RestArea(aAreaAEN)
	RestArea(aAreaAEL)
Else
	aAreaAFA	:= AFA->(GetArea())

	dbSelectArea("AFA")
	dbSetOrder(5) // AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA + AFA_RECURS
	If AFA->(MsSeek(xFilial("AFA") + cProjet + cRevisa + cTarefa + cRecurso))
		lRet := .T.
	EndIf

	RestArea(aAreaAFA)

EndIf

RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAddRsrG³ Autor ³ Marcelo Akama			³ Data ³ 14/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui recursos no array do Gantt							    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAddRsrG(aGant, cProjet, cRevisa, cTarefa, nContLin, cNivel, uCorBarra)
Local aArea		:= GetArea()
Local aAreaAE8	:= AE8->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA
Local aAreaAEL
Local aAreaAEN
Local aAreaAJY
Local nAloc
Local nQuant
Local nProduc
Local nDecCst	:= TamSX3( "AF9_CUSTO" )[2]

dbSelectArea("AE8")
AE8->(dbSetOrder(1)) //AE8_FILIAL+AE8_RECURS+AE8_DESCRI

dbSelectArea("AF9")
AF9->(dbSetOrder(1)) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
AF9->(MsSeek(xFilial("AF9")+cProjet+cRevisa+cTarefa))

If !AF8ComAJT(AF8->AF8_PROJET)

	aAreaAFA	:= AFA->(GetArea())

	dbSelectArea("AFA")
	dbSetOrder(1)
	AFA->(MsSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
	Do While !AFA->(Eof()) .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA_REVISA+AFA->AFA_TAREFA==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
		If !Empty(AFA->AFA_RECURS)
			AE8->(MsSeek(xFilial("AE8")+AFA->AFA_RECURS))
			aAdd(aGant,{{"",cNivel+AE8->AE8_DESCRI,"","","","",cNivel+AE8->AE8_DESCRI,nContlin ,"P"},{{AF9->AF9_START, AF9->AF9_HORAI, AF9->AF9_FINISH, AF9->AF9_HORAF, AllTrim(AFA->AFA_RECURS)+STR0084+AllTrim(Transform(AFA->AFA_ALOC,"@E 9999.99%")),,,1,CLR_BLACK}},uCorBarra,, "P"})
		EndIf
		AFA->(dbSkip())
	EndDo

	RestArea(aAreaAFA)

Else

	aAreaAEL	:= AEL->(GetArea())
	aAreaAEN	:= AEN->(GetArea())
	aAreaAJY	:= AJY->(GetArea())

	//Verifica insumos
	DbSelectArea( "AEL" )
	AEL->( DbSetOrder( 1 ) )
	If AEL->( DbSeek( xFilial( "AEL" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA ) )
		Do While !AEL->(Eof()) .And. AEL->(AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA)==xFilial( "AEL" )+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			DbSelectArea( "AJY" )
			AJY->( DbSetOrder( 1 ) ) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
			If AJY->( DbSeek( xFilial( "AJY" ) + AEL->( AEL_PROJET + AEL_REVISA + AEL_INSUMO ) ) )
				If !Empty(AJY->AJY_RECURS)
					AE8->(MsSeek(xFilial("AE8")+AJY->AJY_RECURS))
					nProduc := 1
					If AF9->AF9_TIPO<>'1'
						nProduc := AF9->AF9_PRODUC / nProduc
					EndIf
					nQuant	:= AEL->AEL_QUANT
					nQuant	:= pmsTrunca( "2", nQuant/nProduc, nDecCst )
					nQuant	:= pmsTrunca( "2", nQuant * AF9->AF9_QUANT, nDecCst )
					nAloc	:= (nQuant / AF9->AF9_HDURAC) * 100
					aAdd(aGant,{{"",cNivel+AE8->AE8_DESCRI,"","","","",cNivel+AE8->AE8_DESCRI,nContlin ,"P"},{{AF9->AF9_START, AF9->AF9_HORAI, AF9->AF9_FINISH, AF9->AF9_HORAF, AllTrim(AJY->AJY_RECURS)+STR0084+AllTrim(Transform(nAloc,"@E 9999.99%")),,,1,CLR_BLACK}},uCorBarra,, "P"})
				EndIf
			EndIf
			AEL->(DbSkip())
		EndDo
	EndIf

	DbSelectArea( "AEN" )
	AEN->( DbSetOrder( 1 ) )
	If AEN->( DbSeek( xFilial( "AEN" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA ) )
		Do While !AEN->(Eof()) .And. AEN->(AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA)==xFilial( "AEN" )+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
			If AF9->AF9_TIPO<>'1'
				nProduc := AF9->AF9_PRODUC
			Else
				nProduc := 1
			EndIf

			AuxAddRsrG(@aGant, AEN->AEN_SUBCOM, AF9->AF9_QUANT * AEN->AEN_QUANT, nProduc, nContLin, cNivel, uCorBarra)

			AEN->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaAJY)
	RestArea(aAreaAEN)
	RestArea(aAreaAEL)

EndIf

RestArea(aAreaAF9)
RestArea(aAreaAE8)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxAddRsrG³ Autor ³ Marcelo Akama			³ Data ³ 14/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui recursos no array do Gantt							    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxAddRsrG(aGant, cCompun, nQtd, nProdEqp, nContLin, cNivel, uCorBarra)
Local aArea		:= GetArea()
Local aAreaAJT	:= AJT->(GetArea())
Local aAreaAJU	:= AJU->(GetArea())
Local aAreaAJY	:= AJY->(GetArea())
Local nAloc
Local nQuant
Local nProduc
Local nDecCst	:= TamSX3( "AF9_CUSTO" )[2]

DbSelectArea( "AJT" ) //AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
AJT->( DbSetOrder( 2 ) )
If AJT->( DbSeek( xFilial( "AJT" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + cCompun ) )
	Do While !AJT->(Eof()) .And. AJT->(AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN)==xFilial( "AJT" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + cCompun
		DbSelectArea( "AJU" )
		AJU->( DbSetOrder( 3 ) ) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		If AJU->( DbSeek( xFilial( "AJU" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
			Do While !AJU->(Eof()) .And. AJU->(AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN)==xFilial( "AJU" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN
				DbSelectArea( "AJY" )
				AJY->( DbSetOrder( 1 ) ) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
				If AJY->( DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + AJU_INSUMO ) ) )
					If !Empty(AJY->AJY_RECURS)
						AE8->(MsSeek(xFilial("AE8")+AJY->AJY_RECURS))
						nProduc := nProdEqp
						If AJT->AJT_TIPO<>'1'
							nProduc := AJT->AJT_PRODUC / nProduc
						EndIf
						nQuant	:= AJU->AJU_QUANT
						nQuant	:= pmsTrunca( "2", nQuant/nProduc, nDecCst )
						nQuant	:= pmsTrunca( "2", nQuant * nQtd, nDecCst )
						nAloc	:= (nQuant / AF9->AF9_HDURAC) * 100
						aAdd(aGant,{{"",cNivel+AE8->AE8_DESCRI,"","","","",cNivel+AE8->AE8_DESCRI,nContlin ,"P"},{{AF9->AF9_START, AF9->AF9_HORAI, AF9->AF9_FINISH, AF9->AF9_HORAF, AllTrim(AJY->AJY_RECURS)+STR0084+AllTrim(Transform(nAloc,"@E 9999.99%")),,,1,CLR_BLACK}},uCorBarra,, "P"})
					EndIf
				EndIf
				AJU->(DbSkip())
			EndDo
		EndIf

		// Verifica as subcomposicoes da composicao aux
		DbSelectArea( "AJX" )
		AJX->( DbSetOrder( 2 ) )
		AJX->( DbSeek( xFilial( "AJX" ) + AF9->AF9_PROJET + AF9->AF9_REVISA + cCompun ) )
		Do While !AJX->( Eof() ) .And. AF9->AF9_PROJET + AF9->AF9_REVISA + cCompun == AJX->( AJX_PROJET + AJX_REVISA + AJX_COMPUN )

			nProduc := nProdEqp
			If AJT->AJT_TIPO<>'1'
				nProduc := nProduc / AJT->AJT_PRODUC
			EndIf

			AuxAddRsrG(@aGant, AJX->AJX_SUBCOM, AJX->AJX_QUANT * nQtd, nProduc, nContLin, cNivel, uCorBarra)

			AJX->( DbSkip() )
		EndDo
		AJT->(DbSkip())
	EndDo
EndIf

RestArea(aAreaAJY)
RestArea(aAreaAJU)
RestArea(aAreaAJT)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsLdRecCU³ Autor ³ Marcelo Akama			³ Data ³ 15/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui recursos no array de recursos						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsLdRecCU(cChave,aRecursos)
Local aArea		:= GetArea()
Local aAreaAEL	:= AEL->(GetArea())
Local aAreaAEN	:= AEN->(GetArea())
Local aAreaAJY	:= AJY->(GetArea())

dbSelectArea("AEL")
dbSetOrder(1)
MsSeek(xFilial("AEL")+cChave)
Do While !Eof() .And. AEL->AEL_FILIAL+AEL->AEL_PROJET+AEL->AEL_REVISA+AEL->AEL_TAREFA==xFilial("AEL")+cChave
	DbSelectArea( "AJY" )
	AJY->( DbSetOrder( 1 ) ) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
	If AJY->( DbSeek( xFilial( "AJY" ) + AEL->( AEL_PROJET + AEL_REVISA + AEL_INSUMO ) ) )
		If !Empty(AJY->AJY_RECURS) .And. aScan(aRecursos,AJY->AJY_RECURS) <= 0
			aAdd(aRecursos,AJY->AJY_RECURS)
		EndIf
	EndIf
	AEL->(dbSkip())
EndDo

dbSelectArea("AEN")
dbSetOrder(1)
MsSeek(xFilial("AEN")+cChave)
Do While !Eof() .And. AEN->AEN_FILIAL+AEN->AEN_PROJET+AEN->AEN_REVISA+AEN->AEN_TAREFA==xFilial("AEN")+cChave

	AuxLdRecCU(AEN->AEN_PROJET, AEN->AEN_REVISA, AEN->AEN_SUBCOM, @aRecursos)

	AEN->(dbSkip())
EndDo

RestArea(aAreaAJY)
RestArea(aAreaAEL)
RestArea(aAreaAEN)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxLdRecCU³ Autor ³ Marcelo Akama			³ Data ³ 15/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui recursos no array de recursos						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Template CCT													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxLdRecCU(cProjet, cRevisa, cCompun, aRecursos)
Local aArea		:= GetArea()
Local aAreaAJT	:= AJT->(GetArea())
Local aAreaAJU	:= AJU->(GetArea())
Local aAreaAJY	:= AJY->(GetArea())

DbSelectArea( "AJT" ) //AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
AJT->( DbSetOrder( 2 ) )
If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompun ) )
	Do While !AJT->(Eof()) .And. AJT->(AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN)==xFilial( "AJT" ) + cProjet + cRevisa + cCompun
		DbSelectArea( "AJU" )
		AJU->( DbSetOrder( 3 ) ) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		If AJU->( DbSeek( xFilial( "AJU" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN ) )
			Do While !AJU->(Eof()) .And. AJU->(AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN)==xFilial( "AJU" ) + AJT->AJT_PROJET + AJT->AJT_REVISA + AJT->AJT_COMPUN
				DbSelectArea( "AJY" )
				AJY->( DbSetOrder( 1 ) ) //AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
				If AJY->( DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + AJU_INSUMO ) ) )
					If !Empty(AJY->AJY_RECURS) .And. aScan(aRecursos,AJY->AJY_RECURS) <= 0
						aAdd(aRecursos,AJY->AJY_RECURS)
					EndIf
				EndIf
				AJU->(DbSkip())
			EndDo
		EndIf

		// Verifica as subcomposicoes da composicao aux
		DbSelectArea( "AJX" )
		AJX->( DbSetOrder( 2 ) )
		AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa + cCompun ) )
		Do While !AJX->( Eof() ) .And. cProjet + cRevisa + cCompun == AJX->( AJX_PROJET + AJX_REVISA + AJX_COMPUN )

			AuxLdRecCU(cProjet, cRevisa, AJX->AJX_SUBCOM, @aRecursos)

			AJX->( DbSkip() )
		EndDo
		AJT->(DbSkip())
	EndDo
EndIf

RestArea(aAreaAJY)
RestArea(aAreaAJU)
RestArea(aAreaAJT)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³getRecursosCU³ Autor ³ Totvs                     ³ Data ³15/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Explode a composicao auxiliar para impressao dos recursos          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function getRecursosCU( cProjet, cRevisa, cTrf, aRecurs )
Local aArea		:= GetArea()
Local aAreaAEN	:= AEN->(GetArea())

Default cTrf	:= ""

// Verifica recursos incluidos no projeto
DbSelectArea( "AEN" )
AEN->( DbSetOrder( 1 ) ) //AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
AEN->( DbSeek( xFilial( "AEN" ) + cProjet + cRevisa + cTrf ) )
While !AEN->( Eof() ) .And. AEN->( AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA == xFilial( "AEN" ) + cProjet + cRevisa + cTrf  )
	getAJTRecursos( cProjet, cRevisa, AEN->AEN_SUBCOM, @aRecurs )
	AEN->( DbSkip() )
End

RestArea(aAreaAEN)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³getAJTRecursos³ Autor ³ Totvs                    ³ Data ³15/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Explode a composicao auxiliar para impressao dos recursos          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function getAJTRecursos( cProjet, cRevisa, cCompun, aRecurs )
Local aArea		:= GetArea()
Local aAreaAJT	:= AJT->(GetArea())

Default cCompun	:= ""

// Verifica recursos incluidos no projeto
DbSelectArea( "AJT" )
AJT->( DbSetOrder( 2 ) ) //AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompun ) )
	While !AJT->( Eof() ) .And. AJT->( AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN == xFilial( "AJT" ) + cProjet + cRevisa + cCompun )
		// Verifica os insumos e recursos da composicao aux
		DbSelecTArea( "AJU" )
		AJU->( DbSetOrder( 3 ) ) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		AJU->( DbSeek( xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
		While !AJU->( Eof() ) .And. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN
			DbSelectArea( "AJY" )
			AJY->( DbSetOrder( 1 ) )
			If AJY->( DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + AJU_INSUMO ) ) )
				If !Empty( AJY->AJY_RECURS )
					If aScan( aRecurs, { |x| x == AJY->AJY_RECURS } ) == 0
						aAdd( aRecurs, AJY->AJY_RECURS )
					EndIf
				EndIf
			EndIf

			AJU->( DbSkip() )
		End

		// Verifica os insumos e recursos da composicao aux realizando a recursividade
		DbSelecTArea( "AJX" )
		AJX->( DbSetOrder( 2 ) ) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
		While !AJX->( Eof() ) .And. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN
			If !Empty( AJX->AJX_SUBCOM )
				getAJTRecursos( cProjet, cRevisa, AJX->AJX_SUBCOM, @aRecurs )
			EndIf

			AJX->( DbSkip() )
		End

		AJT->( DbSkip() )
	End
EndIf

RestArea(aAreaAJT)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetAlCU  ³ Autor ³ Marcelo Akama       ³ Data ³ 19/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array contendo a alocacao dos recursos e seus      ³±±
±±³          ³percentuais de projeto que usa composicao aux                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRetAlCU(aParam,cProjet,cRevisa)
Local aAuxAloc	:= {}
Local aRecursos	:= {}
Local nAloc
Local nQuant
Local nProduc
Local nDecCst	:= TamSX3( "AF9_CUSTO" )[2]
Local aAuxRet
Local nTamPriori 	:= 0
Local aTmp			:= {}
Local nOrdem
Local nI

dbSelectArea("AF9")
dbSetOrder(1)
dbSelectArea("AE8")
dbSetOrder(1)
dbSelectArea("AJY")
dbSetOrder(1) // AJY_FILIAL+AJY_PROJET+AJY_REVISA+AJY_INSUMO
dbSelectArea("AEL")
dbSetOrder(1)
AEL->(MsSeek(xFilial("AEL")+cProjet+cRevisa))
Do While !AEL->(Eof()) .And. xFilial("AEL")+cProjet+cRevisa==AEL->( AEL_FILIAL + AEL_PROJET + AEL_REVISA )
	If AJY->( MsSeek( xFilial( "AJY" ) + AEL->( AEL_PROJET + AEL_REVISA + AEL_INSUMO ) ) )
		If !Empty(AJY->AJY_RECURS) .And. AJY->AJY_RECURS >= aParam[3] .And. AJY->AJY_RECURS <= aParam[4]
			If AE8->(MsSeek(xFilial("AE8")+AJY->AJY_RECURS))
				If AE8->AE8_EQUIP >= aParam[6] .And. AE8->AE8_EQUIP <= aParam[7]
					AF9->(MsSeek(xFilial("AF9")+AEL->AEL_PROJET+AEL->AEL_REVISA+AEL->AEL_TAREFA))
					If PmsChkUser( AF9->AF9_PROJET, AF9->AF9_TAREFA, , AF9->AF9_EDTPAI, 2, "ESTRUT", AF9->AF9_REVISA )
						nProduc := 1
						If AF9->AF9_TIPO<>'1'
							nProduc := AF9->AF9_PRODUC / nProduc
						EndIf
						nQuant	:= AEL->AEL_QUANT
						nQuant	:= pmsTrunca( "2", nQuant/nProduc, nDecCst )
						nQuant	:= pmsTrunca( "2", nQuant * AF9->AF9_QUANT, nDecCst )
						nAloc	:= (nQuant / AF9->AF9_HDURAC) * 100
						aAuxRet := PMSDTaskF(AEL->AEL_DATPRF,"00:00",AF9->AF9_CALEND,nQuant,AF9->AF9_PROJET,Nil)
						AADD(aAuxAloc, {AJY->AJY_RECURS, AF9->AF9_PRIORI, "AEL", AEL->(Recno()), aAuxRet[1], aAuxRet[2], aAuxRet[3], aAuxRet[4], nQuant, nAloc, AF9->AF9_TAREFA})
						If aScan(aRecursos,AJY->AJY_RECURS) <= 0
							aAdd(aRecursos,AJY->AJY_RECURS)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	AEL->(dbSkip())
EndDo

dbSelectArea("AEN")
dbSetOrder(1)
AEN->(MsSeek(xFilial("AEN")+cProjet+cRevisa))
Do While !AEN->(Eof()) .And. xFilial("AEN")+cProjet+cRevisa==AEN->(AEN_FILIAL+AEN_PROJET+AEN_REVISA)
	AF9->(MsSeek(xFilial("AF9")+AEN->AEN_PROJET+AEN->AEN_REVISA+AEN->AEN_TAREFA))
	If PmsChkUser( AF9->AF9_PROJET, AF9->AF9_TAREFA, , AF9->AF9_EDTPAI, 2, "ESTRUT", AF9->AF9_REVISA )
		If AF9->AF9_TIPO<>'1'
			nProduc := AF9->AF9_PRODUC
		Else
			nProduc := 1
		EndIf
		AuxRetAlCU(aParam,cProjet,cRevisa,AEN->AEN_SUBCOM,AF9->AF9_QUANT * AEN->AEN_QUANT,nProduc,@aAuxAloc,@aRecursos)
	EndIf
	AEN->(dbSkip())
EndDo

aTmp := TamSX3("AF9_PRIORI")
nTamPriori := aTmp[1]+aTmp[2]
nOrdem := val(transform( aParam[5] ,"@9"))
// se for ordem de prioridade e data
If nOrdem == 2
	aAuxAloc := aSort( aAuxAloc ,,,{|x,y| x[1]+strZero(1000-x[2] ,nTamPriori) + DTOS(x[5])+x[6]+x[11]+x[3]+str(x[4]) < y[1]+strZero(1000-y[2] ,nTamPriori) + DTOS(y[5])+y[6]+y[11]+y[3]+str(y[4]) })
ElseIf nOrdem == 1
	aAuxAloc := aSort( aAuxAloc ,,,{|x,y| x[1]+DTOS(x[5])+x[6] + strZero(1000-x[2] ,nTamPriori)+x[11]+x[3]+str(x[4]) < y[1]+DTOS(y[5])+y[6] + strZero(1000-y[2] ,nTamPriori)+y[11]+y[3]+str(y[4]) })
EndIf

aRecursos := aSort( aRecursos )

nI := 1
Do While nI <= len(aRecursos)
	If RedistCU(aRecursos[nI], @aAuxAloc)
		nI:=1
	Else
		nI++
	EndIf
EndDo

Return aAuxAloc


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxRetAlCU  ³ Autor ³ Marcelo Akama       ³ Data ³ 20/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array contendo a alocacao dos recursos e seus      ³±±
±±³          ³percentuais de projeto que usa composicao aux                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxRetAlCU(aParam,cProjet,cRevisa,cCompun,nQtd,nProdEqp,aAuxAloc,aRecursos)
Local nAloc
Local nQuant
Local nProduc
Local nDecCst	:= TamSX3( "AF9_CUSTO" )[2]
Local aAuxRet
Local nPos

DbSelectArea( "AJT" )
AJT->( DbSetOrder( 2 ) ) //AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
If AJT->( DbSeek( xFilial( "AJT" ) + cProjet + cRevisa + cCompun ) )
	Do While !AJT->( Eof() ) .And. AJT->( AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN == xFilial( "AJT" ) + cProjet + cRevisa + cCompun )
		DbSelecTArea( "AJU" )
		AJU->( DbSetOrder( 3 ) ) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		AJU->( DbSeek( xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
		Do While !AJU->( Eof() ) .And. AJU->( AJU_FILIAL + AJU_PROJET + AJU_REVISA + AJU_COMPUN ) == xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN
			DbSelectArea( "AJY" )
			AJY->( DbSetOrder( 1 ) )
			If AJY->( DbSeek( xFilial( "AJY" ) + AJU->( AJU_PROJET + AJU_REVISA + AJU_INSUMO ) ) )
				If !Empty(AJY->AJY_RECURS) .And. AJY->AJY_RECURS >= aParam[3] .And. AJY->AJY_RECURS <= aParam[4]
					If AE8->(MsSeek(xFilial("AE8")+AJY->AJY_RECURS))
						If AE8->AE8_EQUIP >= aParam[6] .And. AE8->AE8_EQUIP <= aParam[7]
							nProduc := nProdEqp
							If AJT->AJT_TIPO<>'1'
								nProduc := AJT->AJT_PRODUC / nProduc
							EndIf
							nQuant	:= AJU->AJU_QUANT
							nQuant	:= pmsTrunca( "2", nQuant/nProduc, nDecCst )
							nQuant	:= pmsTrunca( "2", nQuant * nQtd, nDecCst )
							nPos	:= aScan( aAuxAloc, { |x| x[1] == AJY->AJY_RECURS .And. x[3]=="AEN" .And. x[4]==AEN->(Recno()) } )
							If nPos == 0
								nAloc	:= (nQuant / AF9->AF9_HDURAC) * 100
								aAuxRet := PMSDTaskF(AEN->AEN_DATPRF,"00:00",AF9->AF9_CALEND,nQuant,AF9->AF9_PROJET,Nil)
								AADD(aAuxAloc, {AJY->AJY_RECURS, AF9->AF9_PRIORI, "AEN", AEN->(Recno()), aAuxRet[1], aAuxRet[2], aAuxRet[3], aAuxRet[4], nQuant, nAloc, AF9->AF9_TAREFA})
							Else
								nQuant	+= aAuxAloc[nPos][9]
								nAloc	:= (nQuant / AF9->AF9_HDURAC) * 100
								aAuxRet := PMSDTaskF(AEN->AEN_DATPRF,"00:00",AF9->AF9_CALEND,nQuant,AF9->AF9_PROJET,Nil)
								aAuxAloc[nPos][07]	:= aAuxRet[3]
								aAuxAloc[nPos][08]	:= aAuxRet[4]
								aAuxAloc[nPos][09]	:= nQuant
								aAuxAloc[nPos][10]	:= nAloc
							EndIf
							If aScan(aRecursos,AJY->AJY_RECURS) <= 0
								aAdd(aRecursos,AJY->AJY_RECURS)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			AJU->( DbSkip() )
		EndDo

		// Verifica os insumos e recursos da composicao aux realizando a recursividade
		DbSelecTArea( "AJX" )
		AJX->( DbSetOrder( 2 ) ) //AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_INSUMO
		AJX->( DbSeek( xFilial( "AJX" ) + cProjet + cRevisa + AJT->AJT_COMPUN ) )
		Do While !AJX->( Eof() ) .And. AJX->( AJX_FILIAL + AJX_PROJET + AJX_REVISA + AJX_COMPUN ) == xFilial( "AJU" ) + cProjet + cRevisa + AJT->AJT_COMPUN
			nProduc := nProdEqp
			If AJT->AJT_TIPO<>'1'
				nProduc := nProduc / AJT->AJT_PRODUC
			EndIf

			AuxRetAlCU(aParam,cProjet,cRevisa,AJX->AJX_SUBCOM,AJX->AJX_QUANT * nQtd,nProduc,@aAuxAloc,@aRecursos)

			AJX->( DbSkip() )
		EndDo

		AJT->( DbSkip() )
	EndDo
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RedistCU    ³ Autor ³ Marcelo Akama       ³ Data ³ 21/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Reedistribui a alocacao do recurso                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RedistCU(cRecurso,aAuxAloc)
Local nI
Local nJ
Local dDtFim
Local cHrFim
Local aAuxRet
Local lRet := .F.

nI := aScan( aAuxAloc, { |x| x[1] == cRecurso } )

If nI>=0
	dDtFim := aAuxAloc[nI][7]
	cHrFim := aAuxAloc[nI][8]
	nI++
	Do While nI<=len(aAuxAloc) .And. aAuxAloc[nI][1]==cRecurso
		If DTOS(aAuxAloc[nI][5])+aAuxAloc[nI][6]<DTOS(dDtFim)+cHrFim
			aAuxRet := PMSDTaskF(dDtFim,cHrFim,AF9->AF9_CALEND,aAuxAloc[nI][9],AF9->AF9_PROJET,Nil)
			aAuxAloc[nI][05]	:= aAuxRet[1]
			aAuxAloc[nI][06]	:= aAuxRet[2]
			aAuxAloc[nI][07]	:= aAuxRet[3]
			aAuxAloc[nI][08]	:= aAuxRet[4]
			If aAuxAloc[nI][3]=="AEN"
				For nJ:=1 to len(aAuxAloc)
					If aAuxAloc[nJ][3]=="AEN" .And. aAuxAloc[nI][4]==aAuxAloc[nJ][4]
						aAuxRet := PMSDTaskF(aAuxAloc[nI][5],aAuxAloc[nI][6],AF9->AF9_CALEND,aAuxAloc[nJ][9],AF9->AF9_PROJET,Nil)
						aAuxAloc[nJ][05]	:= aAuxRet[1]
						aAuxAloc[nJ][06]	:= aAuxRet[2]
						aAuxAloc[nJ][07]	:= aAuxRet[3]
						aAuxAloc[nJ][08]	:= aAuxRet[4]
					EndIf
				Next nJ
				lRet:=.T.
			EndIf
		EndIf
		dDtFim := aAuxAloc[nI][7]
		cHrFim := aAuxAloc[nI][8]
		nI++
	EndDo
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAppAlCU  ³ Autor ³ Marcelo Akama       ³ Data ³ 22/04/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aplica o array contendo a alocacao dos recursos nas tabelas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAppAlCU(aAloc)
Local nI
Local aAux
Local cLast := ''

aAux := aSort(aAloc,,,{|x,y| x[3]+str(x[4])<y[3]+str(y[4]) })

For nI := 1 to len(aAux)
	If cLast <> aAux[nI][3]+str(aAux[nI][4])
		cLast := aAux[nI][3]+str(aAux[nI][4])
		If aAux[nI][3]=="AEL"
			dbSelectArea("AEL")
			dbGoto(aAux[nI][4])
			RecLock("AEL", .F.)
			replace AEL->AEL_DATPRF with aAux[nI][5]
		Else
			dbSelectArea("AEN")
			dbGoto(aAux[nI][4])
			RecLock("AEN", .F.)
			replace AEN->AEN_DATPRF with aAux[nI][5]
		EndIf
		MsUnlock()
	EndIf
Next nI

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsGetFilt  ³ Autor ³ Marcelo Akama       ³ Data ³ 15/06/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a expressao de filtro correspondente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsGetFilt(cUser,cRotina,cAlias,cNomFilt)
Local cRet := ""

DEFAULT cUser	:= oApp:cUserID
DEFAULT cRotina	:= PADR(ProcName(1),10)
DEFAULT cAlias	:= ALIAS()
DEFAULT cNomFilt:= ""

dbSelectArea("AN7")
AN7->(dbSetOrder(1))
If AN7->(MsSeek( xFilial("AN7")+cUser+cRotina+cAlias+cNomFilt ))
	cRet := Alltrim(AN7->AN7_EXPR)
EndIf
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsIncFilt  ³ Autor ³ Marcelo Akama       ³ Data ³ 15/06/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de inclusao de filtros                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Parambox                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsIncFilt(aParametros, cUser, cRotina, cAlias)
Local cExpr		:= ""
Local cNomFilt	:= ""
Local lOk		:= .F.
Local nx
Local nAt
Local oCombo

DEFAULT cUser	:= oApp:cUserID
DEFAULT cRotina	:= PADR(ProcName(1),10)
DEFAULT cAlias	:= Alias()

cExpr:=BuildExpr(cAlias,,cExpr)

If !Empty(cExpr)
	dbSelectArea("AN7")
	AN7->(dbSetOrder(1))
	Do While !lOk
		cNomFilt := LeNomeFilt()
		If AN7->(MsSeek( xFilial("AN7")+cUser+cRotina+cAlias+cNomFilt ))
			Aviso("Filtro", "Nome de filtro já existe!", {"Ok"})
		Else
			lOk := .T.
		EndIf
	EndDo
	RecLock("AN7", .T.)
	AN7->AN7_FILIAL	:= xFilial("AN7")
	AN7->AN7_USER	:= cUser
	AN7->AN7_FUNCAO	:= cRotina
	AN7->AN7_ALIAS	:= cAlias
	AN7->AN7_FILTR	:= cNomFilt
	AN7->AN7_EXPR	:= cExpr
	MsUnlock()

	For nx := 1 to Len(aParametros)
		If aParametros[nx][1] == 12
			If aParametros[nx][3] == cAlias
				oCombo := &( "oCombo"+AllTrim(STRZERO(nx,2,0)) )
				nAt := oCombo:nAt
				AADD(oCombo:aItems, cNomFilt)
				oCombo:SetItems(oCombo:aItems)
				oCombo:Refresh()
				oCombo:Select(nAt)
			EndIf
		EndIf
	Next

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsAltFilt  ³ Autor ³ Marcelo Akama       ³ Data ³ 16/06/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de alteracao de filtros                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Parambox                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAltFilt(aParametros, nAt, cUser, cRotina, cAlias, cNomFilt)
Local cExpr
Local cNewExpr := ""

DEFAULT cUser	:= oApp:cUserID
DEFAULT cRotina	:= PADR(ProcName(1),10)
DEFAULT cAlias	:= Alias()
DEFAULT cNomFilt:= ""

If nAt==1
	MSGINFO("Nao e permitido alterar este filtro!", "TOTVS")
Else
	dbSelectArea("AN7")
	AN7->(dbSetOrder(1))
	If AN7->(MsSeek( xFilial("AN7")+cUser+cRotina+cAlias+cNomFilt ))
		cExpr   := Alltrim(AN7->AN7_EXPR)
		cNewExpr:=BuildExpr(cAlias,,cExpr)
		If cExpr <> cNewExpr
			RecLock("AN7", .F.)
			AN7->AN7_EXPR	:= cNewExpr
			MsUnlock()
		EndIf
		If empty(cNewExpr)
			PmsExcFilt(aParametros, nAt, cUser, cRotina, cAlias, cNomFilt)
		EndIf
	EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsExcFilt  ³ Autor ³ Marcelo Akama       ³ Data ³ 16/06/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Exclusao de filtros                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Parambox                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcFilt(aParametros, nAt, cUser, cRotina, cAlias, cNomFilt)
Local nx
Local nPos

DEFAULT cUser	:= oApp:cUserID
DEFAULT cRotina	:= PADR(ProcName(1),10)
DEFAULT cAlias	:= Alias()
DEFAULT cNomFilt:= ""

If nAt==1
	MSGINFO("Nao e permitido excluir este filtro!", "TOTVS")
Else
	If MSGYESNO("Confirma a exclusao deste filtro?", "TOTVS")
		dbSelectArea("AN7")
		AN7->(dbSetOrder(1))
		If AN7->(MsSeek( xFilial("AN7")+cUser+cRotina+cAlias+cNomFilt ))
			RecLock("AN7", .F.)
			dbDelete()
			MsUnlock()

			For nx := 1 to Len(aParametros)
				If aParametros[nx][1]==12
					If aParametros[nx][3] == cAlias
						oCombo := &( "oCombo"+AllTrim(STRZERO(nx,2,0)) )
						nAt  := oCombo:nAt
						nPos := AScan(oCombo:aItems, cNomFilt)
						If nPos>0
							If nAt >= nPos
								nAt--
							EndIf
							ADel(oCombo:aItems, nPos)
							ASize(oCombo:aItems, len(oCombo:aItems)-1)
							oCombo:SetItems(oCombo:aItems)
							oCombo:Refresh()
							oCombo:Select(nAt)
						EndIf
					EndIf
				EndIf
			Next

		EndIf
	EndIf
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LeNomeFilt ³ Autor ³ Marcelo Akama       ³ Data ³ 15/06/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Caixa de dialogo para ler o nome do filtro                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LeNomeFilt()

Local oDlg
Local oGet
Local nTam	:=  TamSX3("AN7_FILTR")[1]
Local cRet	:= Space(nTam)

DEFINE MSDIALOG oDlg TITLE "Filtro" FROM 0,0 TO 120,300 PIXEL

@ 002, 004 GROUP TO 027, 146 OF oDlg PIXEL
@ 007, 007 SAY "Informe uma descricao para o filtro criado" PIXEL
@ 030, 004 MSGET oGet VAR cRet SIZE 142, 010 OF oDlg PIXEL
@ 045, 107 BUTTON "Ok" SIZE 037, 012 OF oDlg PIXEL ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTER

Return Upper(PADR(cRet,nTam))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAConsEquipeºAutor³Totvs                      º Data ³ 31/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³ Consulta padrão para buscar do banco de composicoes ou do SX5    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PAConsEquipe( cRecurso )                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParƒmetros³ ExpC1 -> recurso no qual se deseja obter os niveis abaixo na     º±±
±±º          ³          hierarquia                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PAConsEquipe( cRecurso, lNivSup )
Local cEquipe	:= ""
Local cCodFunc	:= ""
Local aFuncoes	:= {}
Local aRet		:= {}

DEFAULT lNivSup := .F.

// 1. Leitura do recurso para obter equipe e funcao
// 2. Determinar quais funcoes que estao abaixo na hierarquia --> AN1
// 3. Leitura dos recursos filtrando equipe e funcoes que estao abaixo na hierarquia

// Verifica se existe a tabela que determina o nivel hierarquico
DbSelectArea( "AE8" )
AE8->( DbSetOrder( 1 ) )
If AE8->( DbSeek( xFilial( "AE8" ) + cRecurso ) )
	// Filtra recursos da mesma equipe e nivel hierarquico
	cEquipe		:= AE8->AE8_EQUIP
	cCodFunc	:= AE8->AE8_FUNCAO
	aFuncoes	:= PANiveis( cCodFunc,, lNivSup )
	aRet		:= PARecursos( cRecurso, cEquipe, aFuncoes )
EndIf

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PANiveis    ºAutor³Totvs                      º Data ³ 31/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³ Retorna array com os niveis abaixo na hierarquia de funcoes.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PANiveis( cCodFuncao, aRet )                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParƒmetros³ ExpC1 -> codigo da funcao do recurso para obter os niveis abaixo º±±
±±º          ³ ExpA1 -> array com os codigos das funcoes em nivel inferior na   º±±
±±º          ³          hierarquia.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PANiveis( cCodFuncao, aRet, lNivSup )
Local aAreaAN1	:= {}

DEFAULT aRet	:= {}
DEFAULT lNivSup := .F.

DbSelectArea( "AN1" )
If lNivSup
	AN1->( DbSetOrder( 1 ) ) // AN1_FILIAL+AN1_CODIGO
	AN1->( DbSeek( xFilial( "AN1" ) + cCodFuncao ) )
	Do While AN1->( !Eof() ) .AND. AN1->( AN1_FILIAL + AN1_CODIGO ) == xFilial( "AN1" ) + cCodFuncao
	   	If !Empty(AN1->AN1_NIVSUP) .And. aScan( aRet, { |x| x == AN1->AN1_NIVSUP } ) == 0
			aAdd( aRet, AN1->AN1_NIVSUP )
			aAreaAN1 := AN1->( GetArea() )
			PANiveis( AN1->AN1_NIVSUP, @aRet, lNivSup )
			RestArea( aAreaAN1 )
		EndIf
		AN1->( DbSkip() )
	EndDo
Else
	AN1->( DbSetOrder( 2 ) ) // AN1_FILIAL+AN1_NIVSUP
	AN1->( DbSeek( xFilial( "AN1" ) + cCodFuncao ) )
	Do While AN1->( !Eof() ) .AND. AN1->( AN1_FILIAL + AN1_NIVSUP ) == xFilial( "AN1" ) + cCodFuncao
	   	If aScan( aRet, { |x| x == AN1->AN1_CODIGO } ) == 0
			aAdd( aRet, AN1->AN1_CODIGO )
			aAreaAN1 := AN1->( GetArea() )
			PANiveis( AN1->AN1_CODIGO, @aRet, lNivSup )
			RestArea( aAreaAN1 )
		EndIf
		AN1->( DbSkip() )
	EndDo
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PARecursos  ºAutor³Totvs                      º Data ³ 31/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³ Retorna array com os recursos em niveis abaixo na hierarquia     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PARecursos(cEquipe, aFuncoes )                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParƒmetros³ ExpC1 -> codigo do recurso que deseja obter os subordinados.     º±±
±±º          ³ ExpC2 -> codigo da funcao do recurso para obter os niveis abaixo º±±
±±º          ³ ExpA1 -> array com os codigo das funcoes no nivel inferior       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestão de Projetos                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PARecursos( cRecurso, cEquipe, aFuncoes )
Local aAreaAE8	:= AE8->( GetArea() )
Local aRet		:= { cRecurso }
Local nInc		:= 1
Local cCodFunc	:= ""

// Determina os codigo das funcoes para filtro
For nInc := 1 To Len( aFuncoes )
	cCodFunc += AllTrim( aFuncoes[nInc] )
	If nInc < Len( aFuncoes )
		cCodFunc += "*"
	EndIf
Next

DbSelectArea( "AE8" )
AE8->( DbSetOrder( 1 ) )
AE8->( DbSeek( xFilial( "AE8" ) ) )
While AE8->( !Eof() ) .AND. AE8->AE8_FILIAL == xFilial( "AE8" )
	If cEquipe <> AE8->AE8_EQUIP
		AE8->( DbSkip() )
		Loop
	EndIf

	If !( AllTrim( AE8->AE8_FUNCAO ) $ cCodFunc )
		AE8->( DbSkip() )
		Loop
	EndIf

	// Ignora o recurso que consulta pois ele foi incluido no inicio
	// e deve ser o primeiro a ser apresentado na tela
	If AllTrim( cRecurso ) <> AllTrim( AE8->AE8_RECURS )
		aAdd( aRet, AE8->AE8_RECURS )
	EndIf

	AE8->( DbSkip() )
End

RestArea( aAreaAE8 )
Return aRet

Function PMSArred(cTrunca, nValor, nCasasDec,nQuantTrf)
Local nValFin := 0
Local cPmsCust := SuperGetMv("MV_PMSCUST",.F.,"1") //Indica se utiliza o custo pela quantidade unitaria ou total

	If nQuantTrf <> Nil .And. cPmsCust <> "1"
		If cTrunca == "1"
			 // truncar
			nValFin := NoRound(nValor, nCasasDec)
		ElseIf cTrunca == "3"
			nValFin := NoRound(NoRound(nValor/nQuantTrf, nCasasDec)*nQuantTrf, nCasasDec)
		ElseIf cTrunca == "4"
			nValFin := Round(Round(nValor/nQuantTrf,nCasasDec)*nQuantTrf, nCasasDec)
		Else
			// arredondar
			nValFin := Round(nValor, nCasasDec)
		EndIf
	Else
		//
		// Truncar por Item ou Truncar por Tarefa
		If cTrunca $ "13"
			 // truncar
			nValFin := NoRound(nValor, nCasasDec)
		Else
			// arredondar
			nValFin := Round(nValor, nCasasDec)
		EndIf
	EndIf

Return nValFin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSXTpTrf     ³ Autor ³ Totvs                 ³ Data ³ 14/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria lista de opcoes para escolha em parametro                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Siga                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSXTpTrf()

Local i := 0
Private nTam      := 0
Private aCat      := {}
Private MvRet     := Alltrim(ReadVar())
Private MvPar     := ""
Private cTitulo   := ""
Private MvParDef  := ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//Tratamento para carregar variaveis da lista de opcoes
nTam	:= TamSX3("AN4_TIPO")[1]
cTitulo := STR0085 // "Tipo de Tarefa"

AN4->( DbSetOrder( 1 ) )
AN4->( DbSeek( xFilial( "AN4" ) ) )
While AN4->( !Eof() ) .And. AN4->AN4_FILIAL == xFilial( "AN4" )
	MvParDef += Left( PADR( AN4->AN4_TIPO, nTam ), nTam )
	aAdd( aCat, Left( PADR( AN4->AN4_TIPO, nTam ), nTam ) + " - " + AllTrim( AN4->AN4_DESCRI ) )

	AN4->( DbSkip() )
End

 MvPar:= PadR(StrTran(&MvRet,";",""),Len(aCat)*nTam)
&MvRet:= PadR(StrTran(&MvRet,";",""),Len(aCat)*nTam)

//Executa funcao que monta tela de opcoes
f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.,nTam, Len(aCat) )

//Tratamento para separar retorno com barra "/"
&MvRet := ""
For i := 1 To Len( MvPar ) Step nTam
	If !(SubStr(MvPar,i,1) $ "|*")
		&MvRet  += SubStr(MvPar,i,nTam) + ";"
	EndIf
Next

//Trata para tirar o ultimo caracter
&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1)

//Guarda numa variavel private o retorno da função
cRetSX1 := &MvRet

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSXGTpTrf    ³ Autor ³ Totvs                 ³ Data ³ 14/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o tipo da consulta padrao PMSXTpTrf		               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Siga                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSXGTpTrf()
Return( cRetSX1 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAValApont  ºAutor³Totvs                      º Data ³ 22/06/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³Valida o apontamento do recurso na tarefa.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³PAValApont( cProjeto, cTarefa, cRecurso )                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParƒmetros³ ExpC1 -> codigo do projeto onde o recurso deseja apontar.        º±±
±±º          ³ ExpC2 -> revisao do projeto                                      º±±
±±º          ³ ExpC3 -> codigo da tarefa para apontamento do recurso            º±±
±±º          ³ ExpC4 -> codigo do recurso                                       º±±
±±º          ³ ExpN1 -> quantidade do apontamento                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestao de Projetos                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PAValApont( cProjeto, cRevisa, cTarefa, cRecurso, nQtdeInfo )
Local aAreaAF8		:= AF8->( GetArea() )
Local aAreaAF9		:= AF9->( GetArea() )
Local aAreaAE8		:= AE8->( GetArea() )
Local aAreaAFA		:= AFA->( GetArea() )
Local aAreaAFU		:= AFU->( GetArea() )
Local aAreaAJK		:= AJK->( GetArea() )
Local aCalcHr		:= {}
Local cCalend		:= ""
Local cMsg			:= STR0087 + cRecurso + CRLF
Local cTO			:= ""
Local cCC			:= ""
Local cAssunto		:= ""
Local lRet 			:= .T.
Local lBlqApt		:= PACtrlHoras( cProjeto )
Local nQtdeHrs		:= 0						// Qtde de horas do recurso
Local nQtdeApt		:= 0						// Qtde de horas apontadas na tarefa
Local nSaldo		:= 0
Local nDifHrs		:= 0

// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
If !lBlqApt
	Return lRet
EndIf

// Permite o apontamento de horas de uma tarefa que o recurso esteja alocado na tarefa;
DbSelectArea( "AFA" )
AFA->( DbSetOrder( 5 ) )
lRet := AFA->( DbSeek( xFilial( "AFA" ) + cProjeto + cRevisa + cTarefa + cRecurso ) )
If lRet
    // Considerar as horas alocadas de esforço do recurso na tarefa como Quantidade horas permitidas;
	nQtdeHrs := AFA->AFA_QUANT

	DbSelectArea( "AE8" )
	AE8->( DbSetOrder( 1 ) )
	If AE8->( DbSeek( xFilial( "AE8" ) + cRecurso ) )
		cCalend	:= AE8->AE8_CALEND
	EndIf

	// Apontamentos de horas
	DbSelectArea( "AFU" )
	AFU->( DbSetOrder( 1 ) )
	AFU->( DbSeek( xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa ) )
	While AFU->( !Eof() ) .AND. AFU->( AFU_FILIAL + AFU_CTRRVS + AFU_PROJET + AFU_REVISA + AFU_TAREFA ) == xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa
		If AllTrim( AFU->AFU_RECURS ) == AllTrim( cRecurso )
			nQtdeApt += AFU->AFU_HQUANT
	    EndIf

		AFU->( DbSkip() )
	End

	// Pré-Apontamentos Aprovados a serem aprovados
	DbSelectArea( "AJK" )
	AJK->( DbSetOrder( 1 ) )
	AJK->( DbSeek( xFilial( "AJK" ) + "1" + cProjeto + cRevisa + cTarefa ) )
	While AJK->( !Eof() ) .AND. AJK->( AJK_FILIAL + AJK_CTRRVS + AJK_PROJET + AJK_REVISA + AJK_TAREFA ) == xFilial( "AJK" ) + "1" + cProjeto + cRevisa + cTarefa
		// Situacao pendente
		If Empty( AJK->AJK_SITUAC ) .OR. AJK->AJK_SITUAC == "1"
			If AllTrim( AJK->AJK_RECURS ) == AllTrim( cRecurso )
				nQtdeApt += AJK->AJK_HQUANT
			EndIf
	    EndIf

		AJK->( DbSkip() )
	End

	// Obtem o saldo com base nas horas permitidas - horas apontadas
	nSaldo	:= nQtdeHrs - nQtdeApt
Else
	Help( " ", 1, "PXFUNAPON",, STR0088, 1, 0 ) //"O recurso não foi alocado para esta tarefa!"
EndIf

If nSaldo > 0
	If lBlqApt
		//Este deve gerar um apontamento com o saldo de horas e gerar um pré-apontamento com a diferença de horas.
		If nQtdeInfo > nSaldo
			nDifHrs := nQtdeInfo - nSaldo

			// Define o apontamento com o saldo
			aCalcHr			:= PMSADDHrs( M->AFU_DATA, M->AFU_HORAI, cCalend, nSaldo, cProjeto, cRecurso )
			M->AFU_HQUANT	:= nSaldo
			If !Empty( aCalcHr )
				M->AFU_HORAF	:= aCalcHr[2]
			EndIf

			// Com o excedente, eh gerado um pre-apontamento
			aCalcHr			:= PMSADDHrs( M->AFU_DATA, M->AFU_HORAF, cCalend, nDifHrs, cProjeto, cRecurso )
			If !Empty( aCalcHr ) .AND. nDifHrs > 0
				DbSelectArea( "AJK" )
				RecLock( "AJK", .T. )
				AJK->AJK_FILIAL	:= xFilial( "AJK" )
				AJK->AJK_CTRRVS	:= "1"
				AJK->AJK_PROJET	:= M->AFU_PROJET
				AJK->AJK_TAREFA	:= M->AFU_TAREFA
				AJK->AJK_REVISA	:= M->AFU_REVISA
				AJK->AJK_RECURS	:= M->AFU_RECURS
				AJK->AJK_HQUANT	:= nDifHrs
				AJK->AJK_DATA	:= aCalcHr[1]
				AJK->AJK_HORAI	:= M->AFU_HORAF
				AJK->AJK_HORAF	:= aCalcHr[2]
				AJK->AJK_SITUAC	:= "1"	// Pendente
				AJK->( MsUnLock() )

				// Localiza o evento de notificacao do projeto
				DbSelectArea( "AN6" )
				AN6->( DbSetOrder( 1 ) )
				AN6->( DbSeek( xFilial( "AN6" ) + AJK->AJK_PROJET + "000000000000001" ) )
				While AN6->( !Eof() ) .AND. xFilial( "AN6" ) + AJK->AJK_PROJET == AN6->( AN6_FILIAL + AN6_PROJET ) .And. AN6->AN6_EVENT == "000000000000001"
					// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
					If !Empty( AN6->AN6_USRFUN )
						&(AN6->AN6_USRFUN)
					EndIf

					// Obtem o assunto da notificacao
					cAssunto := STR0092 // "Notificação de Evento - Horas Excedidas"
					If !Empty( AN6->AN6_ASSUNT )
						cAssunto := AN6->AN6_ASSUNT
					EndIf

					// macro executa para obter o titulo
					If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
						cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
						cAssunto := &(cAssunto)
					EndIf

					// Obtem o destinatario
					cTo	:= PASeekPara( AJK->AJK_RECURS, AN6->AN6_PARA )
					cCC	:= ""//PASeekCopia( AJK->AJK_RECURS, AN6->AN6_COPIA )

					// Cria a mensagem
					cMsg := AN6->AN6_MSG

					// macro executa para obter a mensagem
					If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
						cMsg := Right( cMsg, Len( cMsg ) -1 )
						cMsg := &(cMsg)
					EndIf

					/*
					cMsg := STR0079 + AFU->AFU_RECURS + CRLF	// "Foi gerado um pré-apontamento para o recurso "
					cMsg += STR0080 + AllTrim( AFU->AFU_PROJET ) + CRLF
					cMsg += STR0081 + AllTrim( AFU->AFU_TAREFA ) + CRLF
					cMsg += STR0082 + AllTrim( Str( nDifHrs ) ) + CRLF
					cMsg += STR0083 + DtoC( aCalcHr[1] ) + CRLF
					*/

			        //Deve ser gerada uma notificação de evento do projeto encaminhando um e-mail para o superior do recurso;
					If !Empty( cTO )
						PMSSendMail(	cAssunto,; 						// Assunto
										cMsg,;							// Mensagem
										cTO,;							// Destinatario
										cCC,;							// Destinatario - Copia
										.T. )							// Se requer dominio na autenticacao
					EndIf

					AN6->( DbSkip() )
				End
			EndIf
		EndIf
	EndIf

ElseIf lRet .AND. nSaldo <= 0 .And. !IsinCallStack("PMSA710")
	//Ao incluir ou alterar um apontamento de horas do recurso que o saldo de horas for igual a zero deve
	//apresentar uma mensagem advertindo o usuário que não pode incluir este apontamento;
	Help( " ", 1, "PXFUNAPON",, STR0093, 1, 0 ) //"O usuário não pode incluir este apontamento!"
	lRet := .F.
EndIf

RestArea( aAreaAF8 )
RestArea( aAreaAF9 )
RestArea( aAreaAE8 )
RestArea( aAreaAFA )
RestArea( aAreaAFU )
RestArea( aAreaAJK )

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSSendMail   ³ Autor ³ Totvs            ³ Data ³ 23/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que envia os emails para as Empresas Participantes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PMSSendMail( cAssunto, cMensagem, cTO, cCC )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 -> assunto para envio do e-mail                     ³±±
±±³          ³ ExpC2 -> mensagem                                         ³±±
±±³          ³ ExpC3 -> e-mail para quem o eMail vai ser enviado         ³±±
±±³          ³ ExpC4 -> e-mail para copia carbono                        ³±±
±±³          ³ ExpL1 -> se usa o dominio da conta para autenticacao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAPMS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PMSSendMail( cAssunto, cMensagem, cTO, cCC, lDNSAuth )

Local lOk		:= .F.		// Variavel que verifica se foi conectado OK
Local lSendOk	:= .F.		// Variavel que verifica se foi enviado OK
Local cError	:= ""
Local cEmailTo	:= ""
Local cEmailBcc	:= ""
Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.T.)
Local cMailAuth := ""
Local lResult	:= .F.

Default cCC			:= ""
Default cMensagem	:= ""
Default lDNSAuth	:= .F.

Private cMailConta	:= Nil
Private cMailServer	:= Nil
Private cMailSenha	:= Nil

cMailConta	:= If( cMailConta	== NIL, GetMV( "MV_EMCONTA" ), cMailConta  )
cMailServer	:= If( cMailServer	== NIL, GetMV( "MV_RELSERV" ), cMailServer )
cMailSenha	:= If( cMailSenha	== NIL, GetMV( "MV_EMSENHA" ), cMailSenha  )

//Verifica se existe o SMTP Server
If 	Empty(cMailServer)
	Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
	Return .F.
EndIf

//Verifica se existe a CONTA
If 	Empty(cMailServer)
	Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
	Return .F.
EndIf

//Verifica se existe a Senha
If 	Empty(cMailServer)
	Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
	Return .F.
EndIf

cEmailTo := Alltrim( cTO )
cEmailBcc:= cCC

// Envia e-mail com os dados necessarios
If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a autenticacao no servidor SMTP                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMailAuth
		If ( "@" $ cMailConta ) .AND. !lDNSAuth
			cMailAuth := Subs(cMailConta,1,At("@",cMailConta)-1)
		Else
			cMailAuth := cMailConta
		EndIf

		lResult := MailAuth(cMailAuth,cMailSenha)
	Else
		lResult := .T. //Envia E-mail
	Endif

	If 	lOk .And. lResult
		SEND MAIL 	FROM cMailConta;
					TO cEmailTo;
 					BCC cEmailBcc;
					SUBJECT cAssunto;
					BODY cMensagem;
					RESULT lSendOk
		If !lSendOk
			//Erro no Envio do e-mail
			GET MAIL ERROR cError
			MsgInfo( cError, OemToAnsi( STR0086 ) ) //"Erro no envio de Email"
		EndIf

		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		MsgInfo( cError, OemToAnsi( STR0086 ) ) // "Erro no envio de Email"
	EndIf
EndIf

Return lSendOk

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PACtrlHoras   ³ Autor ³ Totvs            ³ Data ³ 24/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o projeto controla apontamentos com horas     ³±±
±±³          ³ excedentes.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PACtrlHoras( cProjeto )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 -> codigo do projeto.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PACtrlHoras( cProjeto )
Local lRet := .F.

// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
	DbSelectArea( "AF8" )
	AF8->( DbSetOrder( 1 ) )
	If AF8->( DbSeek( xFilial( "AF8" ) + cProjeto ) )
		If AF8->AF8_PAR001 == "1"
			lRet := .T.
		EndIf
	EndIf


Return lRet

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PACtrlApon    ³ Autor ³ Totvs            ³ Data ³ 24/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o projeto controla apontamentos com horas     ³±±
±±³          ³ excedentes.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PACtrlApon( cProjeto )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 -> codigo do projeto.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PACtrlApon( cProjeto )
Local lRet := .F.

// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
	DbSelectArea( "AF8" )
	AF8->( DbSetOrder( 1 ) )
	If AF8->( DbSeek( xFilial( "AF8" ) + cProjeto ) )
		If AF8->AF8_PAR004 == "1"
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PASeekPara    ³ Autor ³ Totvs            ³ Data ³ 14/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o(s) endereco(s) de e-mail para notificacao.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PASeekPara( cRecurs, cNivel )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 -> codigo do recurso                                ³±±
±±³          ³ ExpC2 -> nivel de notificacao                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PASeekPara( cRecurs, cNivel )
Local aAliasAE8	:= AE8->( GetArea() )
Local aAE8TMP	:= {}
Local cReturn 	:= ""
Local cEquip 	:= ""

// recurso cadastrado
dbSelectArea("AE8")
dbSetOrder(1)
If MsSeek(xFilial()+cRecurs)
	cEquip  := AE8->AE8_EQUIP
	cFuncao := AE8->AE8_FUNCAO

	// retorna o email do recurso
	If cNivel == "1"
		cReturn := AE8->AE8_EMAIL
	EndIf

	// retorna o email do superior imediato
	If cNivel == "2"
		aAE8TMP := GetArea()

		DbSelectArea("AN1")
		AN1->( DbSetOrder( 1 ) )
		If AN1->( DbSeek( xFilial( "AN1" ) + cFuncao ) )
			// equipe referente ao recurso
			DbSelectArea("AE8")
			AE8->( DbSetOrder( 4 ) )
			AE8->( DbSeek( xFilial( "AE8" ) + cEquip ) )
			While AE8->( !Eof() ) .AND. xFilial( "AE8" ) + cEquip == AE8->( AE8_FILIAL + AE8_EQUIP )
				If AN1->AN1_NIVSUP == AE8->AE8_FUNCAO
					If !Empty(AE8->AE8_EMAIL)
						cReturn += AE8->AE8_EMAIL + ";"
					EndIf
				EndIf

				AE8->( DbSkip() )
			End
		EndIf

		RestArea(aAE8TMP)
	EndIf

	// retorna o email da equipe
	If cNivel == "3"
		aAE8TMP := GetArea()

		DbSelectArea("AN1")
		AN1->( DbSetOrder( 1 ) )
		If AN1->( DbSeek( xFilial( "AN1" ) + cFuncao ) )
			// equipe referente ao recurso
			DbSelectArea("AE8")
			AE8->( DbSetOrder( 4 ) )
			AE8->( DbSeek( xFilial( "AE8" ) + cEquip ) )
			While AE8->( !Eof() ) .AND. xFilial( "AE8" ) + cEquip == AE8->( AE8_FILIAL + AE8_EQUIP )
				If !Empty(AE8->AE8_EMAIL)
					cReturn += AE8->AE8_EMAIL + ";"
				EndIf
				AE8->( DbSkip() )
			End
		EndIf

		RestArea(aAE8TMP)
	EndIf
EndIf

RestArea( aAliasAE8 )

Return cReturn

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PASeekCopia   ³ Autor ³ Totvs            ³ Data ³ 16/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o(s) endereco(s) de e-mail para notificacao.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PASeekCopia( cRecurs, cNivel )                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 -> codigo do recurso                                ³±±
±±³          ³ ExpC2 -> nivel de notificacao                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PASeekCopia( cRecurs, cNivel )
Local aAliasAE8	:= AE8->( GetArea() )
Local aAE8TMP	:= {}
Local cReturn 	:= ""
Local cEquip 	:= ""

// recurso cadastrado
dbSelectArea("AE8")
dbSetOrder(1)
If MsSeek(xFilial()+cRecurs)
	cEquip  := AE8->AE8_EQUIP
	cFuncao := AE8->AE8_FUNCAO

	// retorna o email do superior imediato
	If cNivel == "1"
		DbSelectArea("AN1")
		AN1->( DbSetOrder( 1 ) )
		If AN1->( DbSeek( xFilial( "AN1" ) + cFuncao ) )
			// equipe referente ao recurso
			DbSelectArea("AE8")
			AE8->( DbSetOrder( 4 ) )
			AE8->( DbSeek( xFilial( "AE8" ) + cEquip ) )
			While AE8->( !Eof() ) .AND. xFilial( "AE8" ) + cEquip == AE8->( AE8_Filial + AE8_EQUIP )
				If AN1->AN1_NIVSUP == AE8->AE8_FUNCAO
					cReturn += AE8->AE8_EMAIL + ";"
					Exit
				EndIf

				AE8->( DbSkip() )
			End
		EndIf

		RestArea(aAE8TMP)
	EndIf

	// retorna o email de todos os superiores
	If cNivel == "2"
		aAE8TMP := GetArea()

		DbSelectArea("AN1")
		AN1->( DbSetOrder( 1 ) )
		If AN1->( DbSeek( xFilial( "AN1" ) + cFuncao ) )
			cReturn += PAEMailSup( AN1->AN1_NIVSUP, cEquip )
		EndIf

		RestArea(aAE8TMP)
	EndIf

	// retorna o email da equipe
	If cNivel == "3"
		aAE8TMP := GetArea()

		// equipe referente ao recurso
		DbSelectArea("AE8")
		AE8->( DbSetOrder( 4 ) )
		AE8->( DbSeek( xFilial( "AE8" ) + cEquip ) )
		While AE8->( !Eof() ) .AND. xFilial( "AE8" ) + cEquip == AE8->( AE8_Filial + AE8_EQUIP )
			cReturn := AE8->AE8_EMAIL + ";"

			AE8->( DbSkip() )
		End

		RestArea(aAE8TMP)
	EndIf
EndIf

RestArea( aAliasAE8 )

Return cReturn

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PAEMailSup    ³ Autor ³ Totvs            ³ Data ³ 14/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o(s) endereco(s) de e-mail do superior            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PAEMailSup( cFuncao ,cEquip )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 -> codigo da funcao                                 ³±±
±±³          ³ ExpC2 -> codigo da equipe                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PAEMailSup( cFuncao, cEquip )
Local aAliasAN1	:= AN1->( GetArea() )
Local aAliasAE8	:= AE8->( GetArea() )
Local cReturn	:= ""

// função que o recurso pertence
DbSelectArea("AN1")
AN1->( DbSetOrder( 1 ) )
If AN1->( DbSeek( xFilial( "AN1" ) + cFuncao ) )
	// equipe referente ao recurso
	DbSelectArea("AE8")
	AE8->( DbSetOrder( 4 ) )
	AE8->( DbSeek( xFilial( "AE8" ) + cEquip ) )
	While AE8->( !Eof() ) .AND. xFilial( "AE8" ) + cEquip == AE8->( AE8_Filial + AE8_EQUIP )
		If AN1->AN1_NIVSUP == AE8->AE8_FUNCAO
			cReturn += AE8->AE8_EMAIL + ";"
		EndIf

		AE8->( DbSkip() )
	End

	cReturn += PAEMailSup( AN1->AN1_NIVSUP, cEquip )
EndIf

RestArea( aAliasAN1 )
RestArea( aAliasAE8 )

Return cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsChkAN3³ Autor ³ Marcelo Akama          ³ Data ³ 14-07-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a existencias das regras de apontamento.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsChkAN3()
Local aArea	:= GetArea()
Local aRegras
Local nX	:= 0

aRegras :=	{;
				{"001", 'AF9->AF9_TPHORA = "1" .And. nHoras>0 .And. nHoras < nSaldo'												, "nHoras", "1"},;
				{"002", 'AF9->AF9_TPHORA = "1" .And. nHoras >= nSaldo .And. nSaldo > 0'												, "nSaldo", "1"},;
				{"003", 'AF9->AF9_TPHORA = "1" .And. nHoras>0 .And. nSaldo <= 0'													, "nHoras", "2"},;
				{"004", 'AF9->AF9_TPHORA = "2" .And. cRespAtu = cRespAnt .And. nHoras>0 .And. nHoras < nSaldo'						, "nHoras", "1"},;
				{"005", 'AF9->AF9_TPHORA = "2" .And. cRespAtu = cRespAnt .And. nHoras >= nSaldo .And. nSaldo >0'					, "nSaldo", "1"},;
				{"006", 'AF9->AF9_TPHORA = "2" .And. cRespAtu = cRespAnt .And. nHoras>0 .And. nSaldo <= 0'							, "nHoras", "2"},;
				{"007", 'AF9->AF9_TPHORA = "2" .And. cRespAtu <> cRespAnt .And. nHoras>0 .And. nHoras < nSaldo'						, "nHoras", "1"},;
				{"008", 'AF9->AF9_TPHORA = "2" .And. cRespAtu <> cRespAnt .And. nHoras >= nSaldo .And. nSaldo >0'					, "nSaldo", "1"},;
				{"009", 'AF9->AF9_TPHORA = "2" .And. cRespAtu <> cRespAnt .And. nHoras>0 .And. nSaldo <= 0 .And. nHoras < nApont'	, "nHoras", "3"},;
				{"010", 'AF9->AF9_TPHORA = "2" .And. cRespAtu <> cRespAnt .And. nSaldo <= 0 .And. nHoras >= nApont .And. nApont >0'	, "nApont", "3"},;
				{"011", 'AF9->AF9_TPHORA = "2" .And. cRespAtu <> cRespAnt .And. nHoras>0 .And. nSaldo <= 0'							, "nHoras", "2"};
			}

dbSelectArea("AN3")
dbSetOrder(1)
If !MsSeek(xFilial("AN3")+"001")
	For nX := 1 to Len(aRegras)
		RecLock("AN3",.T.)
		AN3->AN3_FILIAL	:= xFilial("AN3")
		AN3->AN3_ORDEM	:= aRegras[nX][1]
		AN3->AN3_REGRA	:= aRegras[nX][2]
		AN3->AN3_HORAS	:= aRegras[nX][3]
		AN3->AN3_TIPO	:= aRegras[nX][4]
		MsUnlock()
	Next
EndIf

If MsSeek(xFilial("AN3")+"005")
	If alltrim(AN3->AN3_REGRA) == 'AF9->AF9_TPHORA = "2" .And. cRespAtu = cRespAnt .And. nHoras >= nSaldo .And. nSaldo >0' .And. alltrim(AN3->AN3_HORAS) == 'nHoras'
		RecLock("AN3",.F.)
		AN3->AN3_HORAS	:= aRegras[5][3]
		MsUnlock()
	EndIf
EndIf

If MsSeek(xFilial("AN3")+"007")
	If alltrim(AN3->AN3_REGRA) == 'AF9->AF9_TPHORA = "2" .And. cRespAtu <> cRespAnt .And. nHoras>0 .And. nHoras < nSaldo' .And. alltrim(AN3->AN3_HORAS) == 'nSaldo'
		RecLock("AN3",.F.)
		AN3->AN3_HORAS	:= aRegras[5][3]
		MsUnlock()
	EndIf
EndIf

If MsSeek(xFilial("AN3")+"010")
	If alltrim(AN3->AN3_REGRA) == 'AF9->AF9_TPHORA = "2" .And. cRespAtu <> cRespAnt .And. nSaldo <= 0 .And. nHoras >= nApont >.And. nApont >0'
		RecLock("AN3",.F.)
		AN3->AN3_REGRA	:= aRegras[10][2]
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSQNCEtp

Etapas Paralelas para verificação na Funcao PMSQNCInc.
Aplicado na Integração TMK X QNC X PMS -  Projeto Phoenix

@author Adriano da Silva

@since 16.06.10

@version P10

@param cPlnCod, 	caracter,	Codigo do Plano
@param cRevCod, 	caracter,	Codigo da Revisao do Plano
@param cEtpCod, 	caracter,	Codigo da Etapa do plano

@return aSeqEtp,	array, Etapas Paralelas para verificação na Funcao PMSQNCInc

/*/
//-------------------------------------------------------------------
Function PMSQNCEtp(cPlnCod,cRevCod,cEtpCod)
Local aQI5PRL 	:= {}
Local aQI3PRL		:= {}
Local aQUPPRL		:= {}
Local aQUPPRL2	:= {}
Local aEtapas 	:= {}
Local cGrpEtap	:= ""
Local aSeqEtp 	:= {}
Local nX			:= 0
Local aArea 		:= GetArea()

	DbSelectArea("QI5")				//Ação Corretiva x Ações
	aQI5PRL := QI5->(GetArea())		//Salvo a Area da QI5
	DbSelectArea("QI3")				//Cadastro de Plano e Ações
	aQI3PRL := QI3->(GetArea())	    //Salvo a Area da QI3
	DbSelectArea("QUP")      	//Grupo x Etapa
	aQUPPRL := QUP->(GetArea())	//Salvo a Area da QUP

	DbSelectArea("QI5")				//Ação Corretiva x Ações
	DbSetOrder(4)					//QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
	If DbSeek(xFilial("QI5")+cPlnCod+cRevCod+cEtpCod)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se tem o Código de Etapa Pai gravada na QI5                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(QI5->QI5_ETPRLA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciono no Plano de Acao para Verificar o Modelo do Grupo de Etapas     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("QI3")				//Cadastro de Plano e Ações
			DbSetOrder(2)                   //QI3_FILIAL+QI3_CODIGO+QI3_REV
			If DbSeek(xFilial("QI3")+QI5->QI5_CODIGO+QI5->QI5_REV)
				cGrpEtap := QI3->QI3_MODELO
			Else
				cGrpEtap := ""
			EndIf

			If !Empty(cGrpEtap)

			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciono no Grupo de Etapas com o Código da Etapa Pai gravada na QI5     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("QUP")      	//Grupo x Etapa
				DbSetOrder(1)				//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
				If DbSeek(xFilial("QUP")+PadR(AllTrim(cGrpEtap),TamSx3("QUO_GRUPO")[1])+QI5->QI5_ETPRLA)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico se no Grupo de Etapas a etapa é Paralela Pai                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	If QUP->QUP_ETAPRL == "1" //Etapa Paralela

	    	   		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Funcao que Retorna as Etapas Paralelas informadas no campo QUP_ETAPAP     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	   	aEtapas := StrTokarr(AllTrim(QUP->QUP_ETAPAP),";")
			  			If Len(aEtapas) > 0

				  		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Adiciono a Etapa Pai para posterior verificação na Função PMSQNCInc      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  		    	Aadd(aEtapas,QUP->QUP_TPACAO)

							DbSelectArea("QUP")      	//Grupo x Etapa
							aQUPPRL2 := QUP->(GetArea())	//Salvo a Area da QUP
							DbSetOrder(1)				//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
  		  		    		For nX := 1 To Len(aEtapas)

	  		  		    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciono no Grupo de Etapas com o Código da Etapa Pai gravada na QI5     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If DbSeek(xFilial("QUP")+PadR(AllTrim(cGrpEtap),TamSx3("QUO_GRUPO")[1])+aEtapas[nX])
					  		    	Aadd(aSeqEtp,{QUP->QUP_TPACAO,;			//1-Codigo da Etapa
					  		    					QUP->QUP_SEQUEN })		//2-Sequencia da Etapa
								EndIf

  		  		    		Next
  		  		    		RestArea(aQUPPRL2)

	  		  		    EndIf

	  		  		EndIf

				EndIf

			EndIf

		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciono no Plano de Acao para Verificar o Modelo do Grupo de Etapas     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("QI3")				//Cadastro de Plano e Ações
			DbSetOrder(2)                   //QI3_FILIAL+QI3_CODIGO+QI3_REV
			If DbSeek(xFilial("QI3")+QI5->QI5_CODIGO+QI5->QI5_REV)
				cGrpEtap := QI3->QI3_MODELO
			Else
				cGrpEtap := ""
			EndIf

			If !Empty(cGrpEtap)
				DbSelectArea("QUP")      	//Grupo x Etapa
				DbSetOrder(1)				//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
				If DbSeek(xFilial("QUP")+PadR(AllTrim(cGrpEtap),TamSx3("QUO_GRUPO")[1])+QI5->QI5_TPACAO)

			    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico se no Grupo de Etapas a etapa é Paralela Pai                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	If QUP->QUP_ETAPRL == "1" //Etapa Paralela

	    	   		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Funcao que Retorna as Etapas Paralelas informadas no campo QUP_ETAPAP     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	   	aEtapas := StrTokarr(AllTrim(QUP->QUP_ETAPAP),";")

			  			If Len(aEtapas) > 0

				  		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Adiciono a Etapa Pai para posterior verificação na Função PMSQNCInc      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  		    	Aadd(aEtapas,QUP->QUP_TPACAO)

							DbSelectArea("QUP")      	//Grupo x Etapa
							aQUPPRL2 := QUP->(GetArea())	//Salvo a Area da QUP
							DbSetOrder(1)				//QUP_FILIAL+QUP_GRUPO+QUP_TPACAO
   		  		    		For nX := 1 To Len(aEtapas)

	  		  		    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciono no Grupo de Etapas com o Código da Etapa Pai gravada na QI5     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If DbSeek(xFilial("QUP")+PadR(AllTrim(cGrpEtap),TamSx3("QUO_GRUPO")[1])+aEtapas[nX])
					  		    	Aadd(aSeqEtp,{QUP->QUP_TPACAO,;			//1-Codigo da Etapa
					  		    					QUP->QUP_SEQUEN })		//2-Sequencia da Etapa
								EndIf

  		  		    		Next
  		  		    		RestArea(aQUPPRL2)

	  		  		    EndIf

	  		  		EndIf

				EndIf

			EndIf

	    EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordeno o Array aEtapas por Sequencia das Etapas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aSeqEtp) > 0
		aSeqEtp := aSort(aSeqEtp,,,{|x,y| AllTrim(x[2]) < AllTrim(y[2]) })
	EndIf

	RestArea(aQUPPRL)
	RestArea(aQI3PRL)
	RestArea(aQI5PRL)

RestArea(aArea)

// liberacao de memoria utilizado pelos arrays
aSize(aEtapas,0)
aEtapas := NIL
Return aSeqEtp

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSQNCInc

Funcao para verificar etapas paralelas
Aplicado na Integração TMK X QNC X PMS -  Projeto Phoenix

@author Adriano da Silva

@since 16.06.10

@version P10

@param cPlnCod, 	caracter,	Codigo do Plano
@param cRevCod, 	caracter,	Codigo da Revisao do Plano
@param aEtprla, 	array,		As Etapas Paralelas

@return aSeqEtp,	array, As Inconsistências das Etapas Paralelas

/*/
//-------------------------------------------------------------------
Function PMSQNCInc(cCodPln,cCodRev,aEtprla)

Local aQI5PRL 	:= {}
Local aQI2PRL 	:= {}
Local aAF9PRL 	:= {}
Local aIncons 	:= {}
Local aStatus		:= {}
Local cPrazo		:= ""
Local nX			:= 0
Local cNomDepto 	:= ""
Local aArea 		:= GetArea()

If Len(aEtprla) > 0 .And. !Empty(cCodPln+cCodRev)

  	DbSelectArea("QI5")				//Ação Corretiva x Ações
	aQI5PRL := QI5->(GetArea())

  	DbSelectArea("AF9")	//Tarefas do Projeto
	aAF9PRL	:= AF9->(GetArea())

	DbSelectArea("QI2")	//Não Conformidades
	aQI2PRL := QI2->(GetArea())

	For nX := 1 To Len(aEtprla)

	  	DbSelectArea("QI5")				//Ação Corretiva x Ações
		DbSetOrder(4)					//QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
		If DbSeek(xFilial("QI5")+Padr(AllTrim(cCodPln),TamSx3("QI5_CODIGO")[1])+cCodRev+AllTrim(aEtprla[nX][1]))

	  		DbSelectArea("AF9")	//Tarefas do Projeto
			DbSetOrder(6)		//AF9_FILIAL+AF9_ACAO+AF9_REVACA+AF9_TPACAO
			If DbSeek(xFilial("AF9")+QI5->QI5_CODIGO+QI5->QI5_REV+QI5->QI5_TPACAO )

				DbSelectArea("QI2")	//Não Conformidades
				DbSetOrder(2)		//QI2_FILIAL+QI2_FNC+QI2_REV
				If DbSeek(xFilial("QI2")+AF9->AF9_FNC+AF9->AF9_REVFNC )

					cNomDepto := PADR(QA_NDEPT(QI2->QI2_DESDEP,.F.,QI2->QI2_FILDEP),30)

					If Empty(AF9->AF9_DTATUF)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Função que retorna as Datas/Horas do SLA.		                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aStatus := QNC200STS(AF9->AF9_ACAO, AF9->AF9_REVACA, AF9->AF9_TPACAO)
						cPrazo	:= DtoC(aStatus[2]) + " - " + AllTrim(aStatus[3]) + " a " + DtoC(aStatus[4]) + " - " + AllTrim(aStatus[5])

			    	    AADD( aIncons,{AF9->AF9_ACAO+"/"+AF9->AF9_REVACA   ,;			// 1-Plano/Revisão
										QI5->QI5_TPACAO,;								// 2-Etapa
										QI5->QI5_FILMAT,;								// 3-Filial Responsavel
										QI5->QI5_MAT,;                                  // 4-Codigo Responsavel
										cNomDepto,;										// 5-Departamento
										cPrazo,;										// 6-Previsão SLA
								    	STR0095})										// 7-Motivo # "Tarefa não inicializada/finalizada!"

					EndIf

				EndIf

        	EndIf

        EndIf

	Next nX

	RestArea(aQI2PRL)
	RestArea(aAF9PRL)
	RestArea(aQI5PRL)

EndIf

RestArea(aArea)

Return (aIncons)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
z±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PmsSlmPrd    ºAutor³Clóvis Magenta             º Data ³ 23/03/2010   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Consulta padrão para buscar do banco de composicoes ou do SX5       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ cCode:   	                                                       º±±
±±º			 ³		PRD - Cadastro de Produtos									   º±±
±±º			 ³		CC - Cadastro de Centro de Custo 							   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Exclusao de um produto - MATA010							           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSlmPrd(cCode)
Local lExclui:= .T.
       lExclui:=PmsExcProd(cCode)
Return lExclui

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ pmsWsSA    ºAutor³Reynaldo Miyashita         º Data ³ 09/04/2010    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Inclui ou exclui a amarracao com a solicitacao de Almoxerifado      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ cOper:   	                                                      º±±
±±º			 ³		"3" - Inclui												  º±±
±±º			 ³		"5" - Exclui												  º±±
±±º			 ³	aItPrjSA - projetos e tarefas									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Webservice WSMATA105								                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function pmsWsSA(cOper, aItPrjSA )
Local nZ:=0
Local nY := 0
Local cField := ""
Local cNumSA := ""
Local cItSA  := ""
Local nPosproj := 0	
Local nPosrevisa := 0
Local nPostarefa := 0
Local cBuscaSA := ""

Default aItPrjSA := {}

	If Len(aItPrjSA) >0
		Do case
			Case cOper == "3" .Or. cOper == "4" // incluir/altera
				For nZ := 1 to Len(aItPrjSA)
					cNumSA		:= aItPrjSA[nZ,aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_NUMSA"}) ,2]
					cItSA 		:= aItPrjSA[nZ,aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_ITEMSA"}),2]
					cBuscaSA := xFilial("AFH")+cNumSA+cItSA
					
					nPosproj := aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_PROJET"})
					nPosrevisa := aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_REVISA"})
					nPostarefa := aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_TAREFA"})
					
					If nPosproj > 0 .and. nPosrevisa > 0 .and. nPostarefa > 0
					
						cProjSA 	:= aItPrjSA[nZ,nPosproj,2]
						cRevSA 	:= aItPrjSA[nZ,nPosrevisa,2]
						cTaskSA 	:= aItPrjSA[nZ,nPostarefa,2]
						
						cBuscaSA += cProjSA+cRevSA+cTaskSA
					
					Endif	
					
					dbSelectArea("AFH")
					dbSetOrder(2)
					If MsSeek(cBuscaSA)
						lInclui := .F.
					Else 
						lInclui := .T.
					EndIf                   
					dbSelectArea('AFH')
		 			RecLock('AFH',lInclui)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os dados contidos na GetDados                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nY := 1 to Len(aItPrjSA[nZ])
						cField := Trim(aItPrjSA[nZ][nY][1])
						Replace &cField. With aItPrjSA[nZ][nY][2]
					Next nY
					AFH->AFH_FILIAL := xFilial()
					AFH->AFH_VIAINT := 'S'       
					
					MsUnlock()
				Next nZ
				
			Case cOper == "5" // excluir
				For nZ := 1 to Len(aItPrjSA)
					cNumSA		:= aItPrjSA[nZ,aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_NUMSA"}) ,2]
					cItSA 		:= aItPrjSA[nZ,aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_ITEMSA"}),2]
					cBuscaSA := xFilial("AFH")+cNumSA+cItSA
					
					nPosproj := aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_PROJET"})
					nPosrevisa := aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_REVISA"})
					nPostarefa := aScan(aItPrjSA[nZ],{|x| x[1] == "AFH_TAREFA"})
					
					If nPosproj > 0 .and. nPosrevisa > 0 .and. nPostarefa > 0
					
						cProjSA 	:= aItPrjSA[nZ,nPosproj,2]
						cRevSA 	:= aItPrjSA[nZ,nPosrevisa,2]
						cTaskSA 	:= aItPrjSA[nZ,nPostarefa,2]
						
						cBuscaSA += cProjSA+cRevSA+cTaskSA
					
					Endif	
					
					dbSelectArea("AFH")
					dbSetOrder(2)
					If MsSeek(cBuscaSA)
						dbSelectArea('AFH')
			 			RecLock('AFH',.F.)
						dbDelete()
						MsUnlock()
					Endif
				Next nZ
				
		EndCase
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ pmsWsSC    ºAutor³ Wilson Possani de Godoi   º Data ³ 28/06/2011    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Inclui ou exclui a amarracao com a solicitacao de Compras           ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ cOper:   	                  	                                   º±±
±±º			 ³		"3" - Inclui																	  º±±
±±º			 ³		"4" - Altera																	  º±±
±±º			 ³		"5" - Exclui																	  º±±
±±º			 ³	aItPrjSC - projetos e tarefas													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Webservice WSMAT110											                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function pmsWsSC(cOper, aItPrjSC )
Local nZ:=0
Local nY := 0
Local cField := ""
Local cNumSC := ""
Local cItSC  := ""
Local nPosproj := 0	
Local nPosrevisa := 0
Local nPostarefa := 0
Local cBuscaSC := ""

Default aItPrjSC := {}

	If Len(aItPrjSC) >0
		Do case
			Case cOper == "3" .Or. cOper == "4" // incluir/altera
				For nZ := 1 to Len(aItPrjSC)
					cNumSC		:= aItPrjSC[nZ,aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_NUMSC"}) ,2]
					cItSc 		:= aItPrjSC[nZ,aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_ITEMSC"}),2]
					cBuscaSC := xFilial("AFG")+cNumSC+cItSC
					
					nPosproj := aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_PROJET"})
					nPosrevisa := aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_REVISA"})
					nPostarefa := aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_TAREFA"})
					
					If nPosproj > 0 .and. nPosrevisa > 0 .and. nPostarefa > 0
					
						cProjSC 	:= aItPrjSC[nZ,nPosproj,2]
						cRevSC 	:= aItPrjSC[nZ,nPosrevisa,2]
						cTaskSC 	:= aItPrjSC[nZ,nPostarefa,2]
						
						cBuscaSC += cProjSC+cRevSC+cTaskSC
					
					Endif	
					
					dbSelectArea("AFG")
					dbSetOrder(2)
					If MsSeek(cBuscaSC)
						lInclui := .F.
					Else 
						lInclui := .T.
					EndIf                   
					dbSelectArea('AFG')
		 			RecLock('AFG',lInclui)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os dados contidos na GetDados                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nY := 1 to Len(aItPrjSC[nZ])
						cField := Trim(aItPrjSC[nZ][nY][1])
						Replace &cField. With aItPrjSC[nZ][nY][2]
					Next nY
					AFG->AFG_FILIAL := xFilial()
					AFG->AFG_VIAINT := 'S'       
					
					MsUnlock()
				Next nZ
			Case cOper == "5" // excluir
				For nZ := 1 to Len(aItPrjSC)
					cNumSC		:= aItPrjSC[nZ,aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_NUMSC"}) ,2]
					cItSc 		:= aItPrjSC[nZ,aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_ITEMSC"}),2]
					cBuscaSC := xFilial("AFG")+cNumSC+cItSC
					
					nPosproj := aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_PROJET"})
					nPosrevisa := aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_REVISA"})
					nPostarefa := aScan(aItPrjSC[nZ],{|x| x[1] == "AFG_TAREFA"})
					
					If nPosproj > 0 .and. nPosrevisa > 0 .and. nPostarefa > 0
					
						cProjSC 	:= aItPrjSC[nZ,nPosproj,2]
						cRevSC 	:= aItPrjSC[nZ,nPosrevisa,2]
						cTaskSC 	:= aItPrjSC[nZ,nPostarefa,2]
						
						cBuscaSC += cProjSC+cRevSC+cTaskSC
					
					Endif	
					
					dbSelectArea("AFG")
					dbSetOrder(2)
					If MsSeek(cBuscaSC)
						dbSelectArea('AFG')
			 			RecLock('AFG',.F.)
						dbDelete()      
						MsUnlock()
					EndIf                   
				Next nZ
		EndCase
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ pmsWs120   ºAutor³Reynaldo Miyashita         º Data ³ 09/04/2010    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Inclui ou exclui a amarracao com a pedido de compra            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ cOper:   	                                                      º±±
±±º			 ³		"3" - Inclui												  º±±
±±º			 ³		"5" - Exclui												  º±±
±±º			 ³	aItPrjPC - projetos e tarefas									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Webservice WSMATA120								                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function pmsWs120(cOper, aItPrjpc )
Local nZ:=0
Local nY := 0
Local cField := ""
Local cNumPC := ""
Local cItPC  := ""

Default aItPrjPC := {}

	If Len(aItPrjPC) >0
		Do case
			Case cOper == "3" .Or. cOper == "4" // incluir/altera
				For nZ := 1 to Len(aItPrjPC)
					cNumpc		:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_NUMPC"}) ,2]
					cItpc 		:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_ITEMPC"}),2]
					cProjPC 	:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_PROJET"}),2]
					cRevPC 	:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_REVISA"}),2]
					cTaskPC 	:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_TAREFA"}),2]
					dbSelectArea("AJ7")
					dbSetOrder(2)
					If MsSeek(xFilial()+cNumPC+cItPC+cProjPC+cRevPC+cTaskPC)
						lInclui := .F.
					Else 
						lInclui := .T.
					EndIf                   
					dbSelectArea('AJ7')
		 			RecLock('AJ7',lInclui)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza os dados contidos na GetDados                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nY := 1 to Len(aItPrjPC[nZ])
						cField := Trim(aItPrjPC[nZ][nY][1])
						Replace &cField. With aItPrjPC[nZ][nY][2]
					Next nY
					AJ7->AJ7_FILIAL := xFilial()
					AJ7->AJ7_VIAINT := 'S'       
					
					MsUnlock()
				Next nZ
				
			Case cOper == "5" // excluir
				For nz := 1 to Len(aItPrjPC)
					cNumpc 	:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_NUMPC"}) ,2]
					cItpc 		:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_ITEMPC"}),2]
					cProjPC 	:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_PROJET"}),2]
					cRevPC 	:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_REVISA"}),2]
					cTaskPC 	:= aItPrjPC[nZ,aScan(aItPrjPC[nZ],{|x| x[1] == "AJ7_TAREFA"}),2]
					dbSelectArea("AJ7")
					dbSetOrder(2)
					If MsSeek(xFilial()+cNumPC+cItPC+cProjPC+cRevPC+cTaskPC)
						RecLock("AJ7",.F.,.T.)
						dbDelete()
				       msUnLock()
                	EndIf
      			Next nZ
		EndCase
	EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ pmsWsCP    ºAutor³Clovis Magenta		        º Data ³ 12/04/2010    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Inclui ou exclui a amarracao com a Contas a Pagar	              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ cOper:   	                                                      º±±
±±º			 ³		"3" - Inclui												  º±±
±±º			 ³		"5" - Exclui												  º±±
±±º			 ³	aItPrjCP - projetos e tarefas									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Webservice WSFINA050												   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function pmsWsCP(cOper, aItPrjCP )
Local nZ:=0
Local nY := 0
Local cField := ""
Local cPrefix:= ""
Local cNum 	 := ""
Local cParcel:= ""
Local cTipo  := ""
Local cFornec:= ""
Local cLoja  := ""

Default aItPrjCP := {}

	If Len(aItPrjCP) >0
		Do case
			Case cOper == "3" // incluir
				dbSelectArea('AFR')
	 			RecLock('AFR',.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os dados contidos na GetDados                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nY := 1 to Len(aItPrjCP[1])
					cField := Trim(aItPrjCP[1][nY][1])
					Replace &cField. With aItPrjCP[1][nY][2]
				Next nY
				AFR->AFR_FILIAL := xFilial("AFR")
				AFR->AFR_VIAINT := 'S'
				MsUnlock()

			Case cOper == "5" // excluir

				For nZ:=1 to Len(aItPrjCP)

					cPrefix := aItPrjCP[ 1 ,aScan(aItPrjCP[nZ],{|x| x[1] == "AFR_PREFIX"}) ,2]
					cNum 	:= aItPrjCP[ 1 ,aScan(aItPrjCP[nZ],{|x| x[1] == "AFR_NUM"}) ,2]
					cParcel := aItPrjCP[ 1 ,aScan(aItPrjCP[nZ],{|x| x[1] == "AFR_PARCEL"}) ,2]
					cTipo 	:= aItPrjCP[ 1 ,aScan(aItPrjCP[nZ],{|x| x[1] == "AFR_TIPO"}) ,2]
					cFornec := aItPrjCP[ 1 ,aScan(aItPrjCP[nZ],{|x| x[1] == "AFR_FORNEC"}) ,2]
					cLoja 	:= aItPrjCP[ 1 ,aScan(aItPrjCP[nZ],{|x| x[1] == "AFR_LOJA"}) ,2]

					dbSelectArea("AFR")
					dbSetOrder(2) //AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA
					If MsSeek(xFilial('AFR')+cPrefix+cNum+cParcel+cTipo+cFornec+cLoja)
						RecLock("AFR",.F.,.T.)
						dbDelete()
				        msUnLock()
					EndIf

				Next nZ
		EndCase
	EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ pmsWsCR    ºAutor³Clovis Magenta		        º Data ³ 12/04/2010    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Inclui ou exclui a amarracao com a Contas a Receber	              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ cOper:   	                                                      º±±
±±º			 ³		"3" - Inclui												  º±±
±±º			 ³		"5" - Exclui												  º±±
±±º			 ³	aItPrjCR - projetos e tarefas									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Webservice WSFINA040												   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function pmsWsCR(cOper, aItPrjCR )
Local nZ:=0
Local nY := 0
Local cField := ""
Local cPrefix:= ""
Local cNum 	 := ""
Local cParcel:= ""
Local cTipo  := ""
Local cClient:= ""
Local cLoja  := ""
Default aItPrjCR := {}
	If Len(aItPrjCR) >0
		Do case
			Case cOper == "3" // incluir
				dbSelectArea('AFT')
	 			RecLock('AFT',.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os dados contidos na GetDados                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nY := 1 to Len(aItPrjCR[1])
					cField := Trim(aItPrjCR[1][nY][1])
					Replace &cField. With aItPrjCR[1][nY][2]
				Next nY
				AFT->AFT_FILIAL := xFilial("AFT")
				AFT->AFT_VIAINT := 'S'
				MsUnlock()

			Case cOper == "5" // excluir
				For nZ:=1 to Len(aItPrjCR)

					cPrefix := aItPrjCR[ 1 ,aScan(aItPrjCR[nZ],{|x| x[1] == "AFT_PREFIX"}) 	,2]
					cNum 	:= aItPrjCR[ 1 ,aScan(aItPrjCR[nZ],{|x| x[1] == "AFT_NUM"}) 	,2]
					cParcel := aItPrjCR[ 1 ,aScan(aItPrjCR[nZ],{|x| x[1] == "AFT_PARCEL"}) 	,2]
					cTipo 	:= aItPrjCR[ 1 ,aScan(aItPrjCR[nZ],{|x| x[1] == "AFT_TIPO"}) 	,2]
					cClient := aItPrjCR[ 1 ,aScan(aItPrjCR[nZ],{|x| x[1] == "AFT_CLIENT"}) 	,2]
					cLoja 	:= aItPrjCR[ 1 ,aScan(aItPrjCR[nZ],{|x| x[1] == "AFT_LOJA"}) 	,2]

					dbSelectArea("AFT")
					dbSetOrder(2) //AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA
					If MsSeek(xFilial('AFT')+cPrefix+cNum+cParcel+cTipo+cClient+cLoja)
						RecLock("AFT",.F.,.T.)
						dbDelete()
  			         msUnLock()
					EndIf

				Next nZ
		EndCase
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVldUserºAutor  ³Clovis Magenta      º Data ³  17/01/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que valida o campo AFN_TAREFA de acordo com usuario º±±
±±º          ³ e se necessario atualiza x3.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID e PMSXFUN                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsVldUser(lAtualiza)
Local lRet		:= .T.
Local aArea		:= getArea()
Local aAreaAF8	:= AF8->(getArea())
Local aAreaAF9	:= AF9->(getArea())
Local aAreaSX3	:= SX3->(getArea())
Local nPosProj	:= 0
Local nPosRev	:= 0
Local cTarefa	:= ""
Local cEDTPai	:= ""
Local cUserID	:= ""

Default lAtualiza := .F.

If !lAtualiza


	nPosProj	:= aScan(aHeader,{|x| x[2]=="AFN_PROJET" })
	nPosRev	:= aScan(aHeader,{|x| x[2]=="AFN_REVISA" })
	cTarefa	:= &(readvar())
	cEDTPai	:= ""
	cUserID	:= __cUserID

	If cUserID <> "000000"

		cEDTPai := Posicione("AF9",1,xFilial("AF9")+aCols[n][nPosProj]+aCols[n][nPosRev]+cTarefa,"AF9_EDTPAI")

		lRet := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,2,"NFE", aCols[n][nPosRev] ,cUserID,.T.)

	Endif
Endif

RestArea(aAreaSX3)
RestArea(aAreaAF9)
RestArea(aAreaAF8)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVldTar ºAutor  ³Andrea Verissimo    º Data ³  22/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que valida o campo TAREFA de acordo com o acesso do  º±±
±±º          ³usuario.                                                    º±±
±±º          ³Recebe o alias do arquivo como parametro para checagem.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Parametro cAlias (alias do arquivo a ser checado)          º±±
±±ºUso       ³ X3_VALID                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsVldTar(cAlias, aHead_ , aRatAFN_)
Local lRet		  := .F.
Local aArea		  := getArea()
Local aAreaAF9   := AF9->(GetArea())
Local aAreaAlias := {}
Local nPosProj	  := 0
Local nPosRev	  := 0
Local nPosTarefa := 0
Local cTarefa	  := ""
Local cEDTPai	  := ""
Local cUserID	  := ""
Local cProjeto   := ""
Local cRevisao   := ""
Local nA				:= 0
Local cSD3modI 	:= (Type("M->D3_PROJPMS")<>"U")

DEFAULT cALIAS 	:= "AFR"
DEFAULT aHead_ 	:= {}
DEFAULT aRatAFN_	:= {}

If Alias() <> cAlias
	aAreaAlias := (cAlias)->(getArea())
Endif

If !Empty(cAlias) .AND. (cUserID <> "000000") .and. Len(aRatAFN_) == 0 //Checar porque podem nao enviar o parametro necessario.
	lRet       := .T.
	cProjeto   := cAlias + "_PROJET"
	cRevisao   := cAlias + "_REVISA"
	cTarefa	:= &(readvar())

	If !(cAlias == "SD3")

		nPosProj:= aScan(aHeader,{|x| Alltrim(x[2]) == cProjeto})
		nPosRev	:= aScan(aHeader,{|x| Alltrim(x[2]) == cRevisao})
		cEDTPai	:= ""
		cEDTPai := Posicione("AF9",1,xFilial("AF9")+aCols[n][nPosProj]+aCols[n][nPosRev]+cTarefa,"AF9_EDTPAI")

	Else

		If cSD3modI // Mov. interno mod 1 -> campo em memoria
			cEDTPai	:= ""
			cEDTPai := Posicione("AF9",1,xFilial("AF9")+M->D3_PROJPMS+PmsRevAtu(M->D3_PROJPMS)+cTarefa,"AF9_EDTPAI")
		Else  // Mov. interno mod 2 -> Grid = aCols
			nPosProj:= aScan(aHeader,{|x| Alltrim(x[2]) == "D3_PROJPMS"})
			cEDTPai	:= ""
			cEDTPai := Posicione("AF9",1,xFilial("AF9")+aCols[n][nPosProj]+PmsRevAtu(aCols[n][nPosProj])+cTarefa,"AF9_EDTPAI")
		Endif

	Endif

	cUserID	:= __cUserID


	If Alltrim(cAlias) == 'AFL' // Contrato de Parceria
 		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"GERCP", aCols[n][nPosRev] ,cUserID,.T.)
	ElseIf Alltrim(cAlias) == 'AFH' // Solicitacao ao Armazem
		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"GERSA",aCols[n][nPosRev] ,cUserID,.T.)
	ElseIf Alltrim(cAlias) == 'AFG' // Solicitacao de Compras
		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"GERSC",aCols[n][nPosRev] ,cUserID,.T.)
	ElseIf Alltrim(cAlias) == 'AFR' // Despesas Financeira
		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"DESP", aCols[n][nPosRev] ,cUserID,.T.)
	ElseIf Alltrim(cAlias) == 'AFT' // Receitas Financeira
		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"RECEI", aCols[n][nPosRev] ,cUserID,.T.)
	ElseIf Alltrim(cAlias) == 'AFM' // Ordens de Producao
	   	lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"GEROP", aCols[n][nPosRev] ,cUserID,.T.)
	ElseIf Alltrim(cAlias) == 'AFN' // Nota Fiscal de Entrada
   		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"NFE", aCols[n][nPosRev] ,cUserID,.T.)
	ElseIf Alltrim(cAlias) == 'AJE' // Movimentos bancarios
   		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"DESP", aCols[n][nPosRev] ,cUserID,.T.)
 	ElseIf Alltrim(cAlias) == 'SD3' // Mov. Interno
 			If cSD3modI // mov. interno modelo 1 (campos como variaveis de memoria)
	   		lRet    := PmsChkUser(M->D3_PROJPMS,cTarefa,nil,cEDTPai,3,"REQUIS", PmsRevAtu(M->D3_PROJPMS) ,cUserID,.T.)
	   	Else // mov. interno mod 2, grid.
	   		lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"REQUIS", PmsRevAtu(aCols[n][nPosProj]) ,cUserID,.T.)
	   	Endif
	ElseIf Alltrim(cAlias) == 'AJ7' // Pedido de Compra
	   //Na funcao PmsChkUser foi enviado 'ESTRUT' pq nao tem campo especifico para bloqueio de pedido de compra.
   	lRet    := PmsChkUser(aCols[n][nPosProj],cTarefa,nil,cEDTPai,3,"ESTRUT", aCols[n][nPosRev] ,cUserID,.T.)
	Endif

Endif

If !Empty(cAlias) .AND. (cUserID <> "000000") .and. Len(aRatAFN_) > 0
	lRet       := .T.
	cProjeto   := cAlias + "_PROJET"
	cRevisao   := cAlias + "_REVISA"
	cTarefa    := cAlias + "_TAREFA"
	For nA := 1 To Len(aRatAFN_)

		nPosProj:= aScan(aHead_,{|x| Alltrim(x[2]) == cProjeto})
		nPosRev	:= aScan(aHead_,{|x| Alltrim(x[2]) == cRevisao })
		nPosTarefa	:= aScan(aHead_,{|x| Alltrim(x[2]) == cTarefa })
		cEDTPai	:= ""
		cUserID	:= __cUserID

		cEDTPai := Posicione("AF9",1,xFilial("AF9")+aRatAFN_[nA][nPosProj]+aRatAFN_[nA][nPosRev]+aRatAFN_[nA][nPosTarefa],"AF9_EDTPAI")
		If Alltrim(cAlias) == 'AFN' // Nota Fiscal de Entrada
		   	lRet := PmsChkUser(aRatAFN_[nA][nPosProj],aRatAFN_[nA][nPosTarefa],nil,cEDTPai,3,"NFE", aRatAFN_[nA][nPosRev] ,cUserID,.T.)
		Endif
	Next nA
Endif

If Alias() <> cAlias
	RestArea(aAreaAlias)
Endif

RestArea(aAreaAF9)
RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsDlgAN9VisºAutor  ³Fabricio Romera     º Data ³  07/06/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela para visualizacao dos tributos do projeto        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsDlgAN9Vis()
Local aParamBox  := {}
Local aRet		  := {}
Local aVetAN9    := {}
Local aDadosTrib := {}
Local aAux       := {}
Local aCodImp    := {}
Local aCab		  := {}
Local aAN9Graph  := {}
Local aInfo		  := MsAdvSize(,.F.,400)
Local aButtons   := {}
Local cQuery	  := ""
Local cProjeto   := ""
Local cRevisa    := ""
Local cEDTDe	  := ""
Local cEDTAte	  := ""
Local cTarefaDe  := ""
Local cTarefaAte := ""
Local nQtdeTaref := 0
Local nSerie
Local oDlg
Local oFld
Local oGraphic
Local I, J

DbSelectArea("AN9")

//Parametros
aAdd(aParamBox,{3,STR0096 ,1,{STR0097,STR0098},60,"",.T.})  //"Visualização de Custos" # "Analítico" # "Sintético"
aAdd(aParamBox,{1,STR0099 ,Space(12),"","","_AFC","M->(MV_PAR01) == 1",0,.F.}) //"EDT De"
aAdd(aParamBox,{1,STR0100 ,Space(12),"","","_AFC","M->(MV_PAR01) == 1",0,.F.}) //"EDT Até"
aAdd(aParamBox,{1,STR0101 ,Space(12),"","","_AF9","M->(MV_PAR01) == 1",0,.F.}) //"Tarefa De"
aAdd(aParamBox,{1,STR0102 ,Space(12),"","","_AF9","M->(MV_PAR01) == 1",0,.F.}) //"Tarefa Até"

If !ParamBox(aParamBox,"",@aRet,NIL,NIL,NIL,NIL,NIL,NIL,"PMSR390",.T.,.T.)
	Return
Endif

cProjeto	:= AF8->(AF8_PROJET)
cRevisa	:= AF8->(AF8_REVISA)

If MV_PAR01 = 1
	cEDTDe		:= MV_PAR02
	cEDTAte		:= MV_PAR03
	cTarefaDe	:= MV_PAR04
	cTarefaAte	:= MV_PAR05
End If


#IFDEF TOP

	//Carrega informacoes para VISUALIZACAO dos tributos
	cQuery := " SELECT "
	cQuery += " AN9_REVISA,"
	cQuery += " AF9_EDTPAI,"
	cQuery += " AN9_TAREFA,"
	cQuery += " AN9_CODIMP,"
	cQuery += " SUM(AN9_VALIMP) AN9_VALIMP "
	cQuery += " FROM " + RetSqlName("AN9") + " AN9 "
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("AF9")+" AF9 "
	cQuery += " ON  AN9_FILIAL = AF9_FILIAL "
	cQuery += " AND AN9_PROJET = AF9_PROJET "
	cQuery += " AND AN9_REVISA = AF9_REVISA "
	cQuery += " AND AN9_TAREFA = AF9_TAREFA "
	cQuery += " WHERE AN9_FILIAL = '" + xFilial("AN9") + "'"
	cQuery += " AND	  AN9_PROJET = '" + cProjeto       + "'"
	cQuery += " AND   AN9_REVISA = '" + cRevisa		   + "'"
	cQuery += " AND   AN9.D_E_L_E_T_ = ' '"
	If MV_PAR01 = 1
		cQuery += " AND	AF9_EDTPAI >= '" + cEDTDe   + "'"
		cQuery += " AND	AF9_EDTPAI <= '" + cEDTAte  + "'"
		cQuery += " AND	AN9_TAREFA >= '" + cTarefaDe   + "'"
		cQuery += " AND	AN9_TAREFA <= '" + cTarefaAte  + "'"
	End If
	cQuery += " GROUP BY"
	cQuery += " AN9_FILIAL,"
	cQuery += " AN9_PROJET,"
	cQuery += " AN9_REVISA,"
	cQuery += " AF9_EDTPAI,"
	cQuery += " AN9_TAREFA,"
	cQuery += " AN9_CODIMP"
	cQuery += " ORDER BY"
	cQuery += " AN9_FILIAL,"
	cQuery += " AN9_PROJET,"
	cQuery += " AN9_REVISA,"
	cQuery += " AF9_EDTPAI,"
	cQuery += " AN9_TAREFA,"
	cQuery += " AN9_CODIMP"
	cQuery := ChangeQuery(cQuery)

	cAliasTmp := "AN9TMP"
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T.)

	aAdd(aCab, "EDT") //Ajustar para buscar da tabela de Tributos x EDT
	aAdd(aCab, RetTitle("AN9_TAREFA"))
	cCodTaref := ""

	dbSelectArea(cAliasTmp)
	While (cAliasTmp)->(!Eof())

		//Controle de quantidade de tarefas
		If cCodTaref != (cAliasTmp)->(AN9_TAREFA)
			nQtdeTaref ++
		End If

		//Controle dos codigos dos impostos existentes
		If aScan(aCodImp, { |x| x == (cAliasTmp)->(AN9_CODIMP) } )  = 0
			aAdd(aCodImp, (cAliasTmp)->(AN9_CODIMP)) 					 //Cod. de Impostos
			aAdd(aCab   , PMSGetAN9Desc( (cAliasTmp)->(AN9_CODIMP) ))	 //Cabec. ListBox
		End If

		cCodTaref  := (cAliasTmp)->(AN9_TAREFA)

		aAdd( aDadosTrib , {(cAliasTmp)->(AF9_EDTPAI), ;
							(cAliasTmp)->(AN9_TAREFA), ;
							(cAliasTmp)->(AN9_CODIMP), ;
							(cAliasTmp)->(AN9_VALIMP)} )

		(cAliasTmp)->(!DbSkip())

	End

	//Determina o tamanho do array de trib. de acordo com a qtde de impostos
	cCodTaref := ""
	aAux      := Array(2+Len(aCodImp))

	//Monta array de exibicao dos tributos por tarefa
	For I := 1 to Len(aDadosTrib)

		//Controla se ja esta na prox. tarefa
		If cCodTaref != aDadosTrib[I][2]
			aAdd(aVetAN9, aClone(aAux) )
		End If

		aVetAN9[Len(aVetAN9)][1] := aDadosTrib[I][1] //Codigo EDT
		aVetAN9[Len(aVetAN9)][2] := aDadosTrib[I][2] //Codigo tarefa

		//Verifica vetor de impostos para adicionar na posicao corresponte o valor correspondente
		For J := 1 to Len(aCodImp)

			If aCodImp[J] = aDadosTrib[I][3]
				aVetAN9[Len(aVetAN9)][J+2] := Transform( aDadosTrib[I][4], "@E 999,999.99" ) //Alltrim( Str( ))
			End If

			If Empty(aVetAN9[Len(aVetAN9)][J+2])
				aVetAN9[Len(aVetAN9)][J+2] := Transform( 0, "@E 999,999.99" ) //""
			End If

		Next

		cCodTaref := aDadosTrib[I][2]

	Next

	(cAliasTmp)->(DbCloseArea())

	//Carrega informacoes para o GRAFICO dos tributos
	cQuery := " SELECT "
	cQuery += " AN9_CODIMP,"
	cQuery += " AN9_PERC,"
	cQuery += " SUM(AN9_VALIMP) AN9_VALIMP "
	cQuery += " FROM " + RetSqlName("AN9") + " AN9"
	cQuery += " LEFT OUTER JOIN " + RetSqlName("AF9") + " AF9"
	cQuery += " ON  AN9_FILIAL = AF9_FILIAL "
	cQuery += " AND AN9_PROJET = AF9_PROJET "
	cQuery += " AND AN9_REVISA = AF9_REVISA "
	cQuery += " AND AN9_TAREFA = AF9_TAREFA "
	cQuery += " WHERE AN9_FILIAL = '" + xFilial("AN9") + "'"
	cQuery += " AND	  AN9_PROJET = '" + cProjeto       + "'"
	cQuery += " AND	  AN9_REVISA = '" + cRevisa        + "'"
	cQuery += " AND   AN9.D_E_L_E_T_ = ' '"
	If MV_PAR01 = 1
		cQuery += " AND	AF9_EDTPAI >= '" + cEDTDe   + "'"
		cQuery += " AND	AF9_EDTPAI <= '" + cEDTAte  + "'"
		cQuery += " AND	AN9_TAREFA >= '" + cTarefaDe   + "'"
		cQuery += " AND	AN9_TAREFA <= '" + cTarefaAte  + "'"
	End If
	cQuery += " GROUP BY"
	cQuery += " AN9_FILIAL,"
	cQuery += " AN9_PROJET,"
	cQuery += " AN9_REVISA,"
	cQuery += " AN9_CODIMP,"
	cQuery += " AN9_PERC"
	cQuery += " ORDER BY"
	cQuery += " AN9_FILIAL,"
	cQuery += " AN9_PROJET,"
	cQuery += " AN9_REVISA,"
	cQuery += " AN9_CODIMP,"
	cQuery += " AN9_PERC"
	cQuery := ChangeQuery(cQuery)

	cAliasTmp := "AN9GRAPH"
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T.)

	dbSelectArea(cAliasTmp)
	While (cAliasTmp)->(!Eof())
		aAdd( aAN9Graph, { PMSGetAN9Desc( (cAliasTmp)->(AN9_CODIMP) ) + " - " + AllTrim(Str((cAliasTmp)->(AN9_PERC))) + "%",;
						   (cAliasTmp)->(AN9_VALIMP) })
		(cAliasTmp)->(DbSkip())
	End

	(cAliasTmp)->(DbCloseArea())

#ENDIF

	//Verificar se existe dados para exibicao
	If Empty(aVetAN9)
		Aviso(STR0103, STR0104 ,{"OK"},2) //"Aviso" # "Nenhum registro encontrado com os parâmetros especificados."
		Return
	End If

	aSize := MsAdvSize(,.F.,400)
	aObjects := {}

	AAdd( aObjects, { 100, 100 , .T., .T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )


	//Tela de visualizacao de tributos
	DEFINE MSDIALOG oDlg TITLE STR0105 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL  //"Gerenciamento de Projetos"
	    oDlg:lMaximized := .T.

	    oTFont := TFont():New('Tahoma',,22,) //12

		@ aPosObj[1,1],aPosObj[1,2] FOLDER oFld OF oDlg PROMPT STR0106, STR0107 PIXEL SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] //"&Planilha de Valores" # "&Representação Gráfica"

	    oFld:Align := CONTROL_ALIGN_ALLCLIENT

		//Planilha de Valores
		oLbx := TWBrowse():New(2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aCab,,oFld:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLbx:SetArray( aVetAN9 )
		oLbx:bLine := {|| aEval(aVetAN9[oLbx:nAt],{|z,w| aVetAN9[oLbx:nAt,w] } ) }

		//Representacao Grafica
		oGraphic := TMSGraphic():New( 01,01,oFld:aDialogs[2],oTFont,,RGB(239,239,239),260,184)
		oGraphic:SetTitle("","", CLR_BLACK, A_CENTER, .F. )
		oGraphic:SetMargins(180,180,180,180)
		oGraphic:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)
		oGraphic:l3D := .t.

		//nSerie := oGraphic:CreateSerie( GRP_PIE ) // GRP_PIE=10
		nSerie := oGraphic:CreateSerie( 10,,2,.T.)  //.T.

		For I:= 1 to Len(aAN9Graph)
			oGraphic:Add(nSerie, aAN9Graph[I][2], aAN9Graph[I][1], 35000 * I ) //35000
		Next

	    oGraphic:Align := CONTROL_ALIGN_ALLCLIENT

	    //Define botoes da EnchoiceBar
	    aAdd( aButtons, {BMP_IMPRIMIR , {|| PMSPrintAN9(MV_PAR01, cProjeto, cEDTDe, cEDTAte, cTarefaDe, cTarefaAte, cRevisa)} , STR0108}) //"Imprimir"

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons)



Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSPrintAN9ºAutor  ³Fabricio Romera     º Data ³  07/08/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao de Relatorio de Tributos das tarefas.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSPrintAN9(nOpc, cProjeto, cEDTDe, cEDTAte, cTarefaDe, cTarefaAte, cRevisa)

Local oReport
Local oAN9
Local oBreak
Local oBreak1
Local bDescrImp := {||  PMSGetAN9Desc(AN9_CODIMP) }
Private oAN91

//Pergunte("REPORT",.F.)

DEFINE REPORT oReport NAME "PMSRelAN901" TITLE STR0109 ACTION {|oReport| PrntRptAN9(oReport, nOpc, cProjeto, cEDTDe, cEDTAte, cTarefaDe, cTarefaAte)} //"Impostos das Tarefas"

	DEFINE SECTION oAN9 OF oReport TITLE STR0113 TABLES "AN9" LEFT MARGIN 2 LINES BEFORE 2//PAGE HEADER //TOTAL IN COLUMN // //"Tarefas"

		DEFINE CELL NAME "AN9_PROJET" 	OF oAN9 ALIAS "AN9" SIZE 15
		DEFINE CELL NAME "AF8_DESCRI" 	OF oAN9 ALIAS "AN9"	SIZE 30
		DEFINE CELL NAME "AF9_EDTPAI" 	OF oAN9 ALIAS "AN9"
		DEFINE CELL NAME "AFC_DESCRI" 	OF oAN9 ALIAS "AN9"	SIZE 30
		DEFINE CELL NAME "AN9_TAREFA" 	OF oAN9 ALIAS "AN9"
		DEFINE CELL NAME "AF9_DESCRI" 	OF oAN9 ALIAS "AN9"	SIZE 30

		DEFINE BREAK oBreak OF oAN9 WHEN oAN9:Cell("AN9_TAREFA") TOTAL IN LINE // TOTAL IN LINE TITLE "Total Imposto"

	DEFINE SECTION oAN91 OF oAN9 TITLE STR0110 TABLES "AN9" LEFT MARGIN 6 LINES BEFORE 2//TOTAL IN COLUMN //PAGE HEADER		//"Produtos"

		DEFINE CELL NAME "AN9_PRODUT" 	OF oAN91 ALIAS "AN9"
		DEFINE CELL NAME "B1_DESC"			OF oAN91 ALIAS "AN9"
		DEFINE CELL NAME "AN9_VALIMP"   	OF oAN91 ALIAS "AN9"

	If nOpc = 2 //Sintetico

		DEFINE FUNCTION FROM oAN91:Cell("AN9_VALIMP") FUNCTION SUM BREAK oBreak	TITLE STR0111  NO END SECTION //Total Impostos

	Else //Analitico

		oAN91:Cell("AN9_VALIMP"):Disable()

        DEFINE BREAK oBreak1 OF oAN91 WHEN oAN91:Cell("AN9_PRODUT") //TOTAL IN LINE

		DEFINE SECTION oAN92 OF oAN91 TITLE STR0112 TABLES "AN9" LEFT MARGIN 20 LINES BEFORE 1 COLUMNS 5//TOTAL IN COLUMN //PAGE HEADER //"Impostos"

			DEFINE CELL NAME "AN9_CODIMP" 	OF oAN92 ALIAS "AN9" TITLE STR0112 ALIGN LEFT   BLOCK bDescrImp SIZE 30	//"Imposto"
			DEFINE CELL NAME "AN9_PERC"  	OF oAN92 ALIAS "AN9" 			   ALIGN CENTER                         //"Aliquota"
			DEFINE CELL NAME "AN9_VALIMP"	OF oAN92 ALIAS "AN9" TITLE STR0114 ALIGN RIGHT	SIZE 20   			    //"Valor"

		DEFINE FUNCTION FROM oAN92:Cell("AN9_VALIMP") OF oAN91 FUNCTION SUM BREAK oBreak TITLE STR0111  NO END SECTION 	//"Total Imposto"

	EndIf

oReport:ParamReadOnly()
oReport:PrintDialog()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrntRptAN9 ºAutor  ³Fabricio Romera     º Data ³  07/08/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Traz dados do relatorio de tributos			              	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrntRptAN9(oReport, nOpc, cProjeto, cEDTDe, cEDTAte, cTarefaDe, cTarefaAte)

#IFDEF TOP
	Local cAlias := GetNextAlias()

	//MakeSqlExp("REPORT")

	BEGIN REPORT QUERY oReport:Section(1)

	//Sintetico
	If nOpc = 2

		BeginSql alias cAlias
			SELECT
			AN9_FILIAL,
			AN9_PROJET,
			AF8_DESCRI,
			AN9_REVISA,
			AF9_EDTPAI,
			AFC_DESCRI,
			AN9_TAREFA,
			AF9_DESCRI,
			AN9_PRODUT,
			B1_DESC,
			SUM(AN9_VALIMP) AN9_VALIMP
			FROM %table:AN9% AN9
			LEFT JOIN %table:AF8% AF8
			ON AN9_PROJET = AF8_PROJET
			LEFT JOIN %table:AF9% AF9
			ON  AN9_FILIAL = AF9_FILIAL
			AND AN9_PROJET = AF9_PROJET
			AND AN9_REVISA = AF9_REVISA
			AND AN9_TAREFA = AF9_TAREFA
			LEFT JOIN %table:AFC% AFC
			ON  AN9_FILIAL = AFC_FILIAL
			AND AN9_PROJET = AFC_PROJET
			AND AN9_REVISA = AFC_REVISA
			AND AF9_EDTPAI = AFC_EDT
			LEFT JOIN %table:SB1% SB1
			ON AN9_PRODUT = B1_COD
			WHERE AN9_FILIAL = %xFilial:AN9%
			AND	  AN9_PROJET = %Exp:cProjeto%
			AND   AN9_REVISA = %Exp:cRevisa%
			AND   AN9.D_E_L_E_T_ = ' '
			GROUP BY
			AN9_FILIAL,
			AN9_PROJET,
			AF8_DESCRI,
			AN9_REVISA,
			AF9_EDTPAI,
			AFC_DESCRI,
			AN9_TAREFA,
			AF9_DESCRI,
			AN9_PRODUT,
			B1_DESC
		EndSql

	//Analitico
	Else

		BeginSql alias cAlias
			SELECT
			AN9_FILIAL,
			AN9_PROJET,
			AF8_DESCRI,
			AN9_REVISA,
			AF9_EDTPAI,
			AFC_DESCRI,
			AN9_TAREFA,
			AF9_DESCRI,
			AN9_PRODUT,
			AN9_CODIMP,
			AN9_PERC,
			B1_DESC,
			SUM(AN9_VALIMP) AN9_VALIMP
			FROM %table:AN9% AN9
			LEFT JOIN %table:AF8% AF8
			ON AN9_PROJET = AF8_PROJET
			LEFT JOIN %table:AF9% AF9
			ON  AN9_FILIAL = AF9_FILIAL
			AND AN9_PROJET = AF9_PROJET
			AND AN9_REVISA = AF9_REVISA
			AND AN9_TAREFA = AF9_TAREFA
			LEFT JOIN %table:AFC% AFC
			ON  AN9_FILIAL = AFC_FILIAL
			AND AN9_PROJET = AFC_PROJET
			AND AN9_REVISA = AFC_REVISA
			AND AF9_EDTPAI = AFC_EDT
			LEFT JOIN %table:SB1% SB1
			ON AN9_PRODUT = B1_COD
			WHERE AN9_FILIAL = %xFilial:AN9%
			AND	  AN9_PROJET = %Exp:cProjeto%
			AND   AN9_REVISA = %Exp:cRevisa%
			AND	AF9_EDTPAI   BETWEEN %Exp:cEDTDe% 		AND %Exp:cEDTAte%
			AND	AN9_TAREFA   BETWEEN %Exp:cTarefaDe%	AND %Exp:cTarefaAte%
			AND AN9.D_E_L_E_T_ = ' '
			GROUP BY
			AN9_FILIAL,
			AN9_PROJET,
			AF8_DESCRI,
			AN9_REVISA,
			AF9_EDTPAI,
			AFC_DESCRI,
			AN9_TAREFA,
			AF9_DESCRI,
			AN9_PRODUT,
			AN9_CODIMP,
			AN9_PERC,
			B1_DESC
		EndSql

	End if

	END REPORT QUERY oReport:Section(1)

	oAN91:SetParentQuery()
	oAN91:SetParentFilter({|cParam| (cAlias)->( AN9_FILIAL + AN9_PROJET + AN9_REVISA + AF9_EDTPAI + AN9_TAREFA ) == cParam },{|| (cAlias)->( AN9_FILIAL + AN9_PROJET + AN9_REVISA + AF9_EDTPAI + AN9_TAREFA )})

	If nOpc = 1//Analitico
		oAN92:SetParentQuery()
		oAN92:SetParentFilter({|cParam| (cAlias)->( AN9_FILIAL + AN9_PROJET + AN9_REVISA + AF9_EDTPAI + AN9_TAREFA + AN9_PRODUT ) == cParam },{|| (cAlias)->( AN9_FILIAL + AN9_PROJET + AN9_REVISA + AF9_EDTPAI + AN9_TAREFA + AN9_PRODUT )})
	End If

	oReport:Section(1):Print()
#ENDIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAN9ImpEDT()ºAutor  ³Fabricio Romera º Data ³  15/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o total de impostos das tarefas de uma EDT.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAN9ImpEDT(cProjeto, cRevisa,cEDTPai)

Local aArea		:= GetArea()
Local aAreaPrj	:= AF8->(GetArea())
Local aAreaTrf	:= AF9->(GetArea())
Local aAreaEDT	:= AFC->(GetArea())
Local nValImp	:= 0

DEFAULT cProjeto:= AF9->AF9_PROJET
DEFAULT cRevisa := AF9->AF9_REVISA
DEFAULT cEDTPai := AF9->AF9_EDTPAI

dbSelectArea("AFC")
dbSelectArea("AF9")

If !Empty(cEdtPai)

	AFC->(dbSetOrder(2))
	If AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDTPai))
		While AFC->(!Eof()) .And. (xFilial("AFC") + cProjeto + cRevisa + cEDTPai) == AFC->(AFC_FILIAL + AFC_PROJET + AFC_REVISA + AFC->AFC_EDTPAI)
			nValImp += AFC->AFC_TOTIMP
			AFC->(dbSkip())
		End
	EndIf

	AF9->(dbSetOrder(2))
	If AF9->(MsSeek(xFilial("AF9") + cProjeto + cRevisa + cEDTPai))
		While AF9->(!Eof()) .And. (xFilial("AF9") + cProjeto + cRevisa + cEDTPai) == AF9->(AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI)
			nValImp += AF9->AF9_TOTIMP
			AF9->(dbSkip())
		End
	EndIf

	AFC->(dbSetOrder(1))
	If AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDTPai))

		RecLock("AFC",.F.)
			AFC->AFC_TOTIMP := nValImp
		MsUnlock()

		PMSAN9ImpEDT(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDTPAI)
	EndIf

EndIf

RestArea(aAreaEDT)
RestArea(aAreaTrf)
RestArea(aAreaPrj)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAN9RclcImp  ºAutor ³Fabricio Romera º Data ³  20/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recaulcula os impostos do projeto.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsAN9RclcImp(cProjeto, cRevisa)
Local aArea		  := GetArea()
Local aAreaPrj	  := AF8->(GetArea())
Local aAreaTrf	  := AF9->(GetArea())
Local aAreaEDT	  := AFC->(GetArea())
Local nTotImpEDT  := 0
Local cEDTUlt	  := ""

DEFAULT cProjeto:= AF8->AF8_PROJET
DEFAULT cRevisa := AF8->AF8_REVISA

dbSelectArea("AFC")
dbSetOrder(3)
If AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa ) )
	While AFC->(!Eof()) .And. (xFilial("AFC") + cProjeto + cRevisa) == AFC->(AFC_FILIAL + AFC_PROJET + AFC_REVISA)
		//Verifica impostos das Tarefas da EDT atual
		nTotImpEDT += PmsVerTarefa(AFC->AFC_PROJET,AFC->AFC_REVISA,Iif(Empty(AFC->AFC_EDT),AFC->AFC_PROJET, AFC->AFC_EDT) )
		cEDTUlt := AFC->AFC_EDT
		AFC->(DbSkip())
	End
EndIf

//Totaliza custos para as EDTs do Projeto
PmsAN9ImpEDT(cProjeto, cRevisa,cEDTUlt)

RestArea(aAreaEDT)
RestArea(aAreaTrf)
RestArea(aAreaPrj)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVerTarefa    ºAutor³Fabricio Romera º Data ³  20/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica tarefas e atualiza total de impostos da EDT.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PmsAN9RclcImp                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsVerTarefa(cProjeto, cRevisa, cEDTPai)

Local nTotImpEDT := 0
Local aArea		  := GetArea()
Local aAreaEDT	  := AFC->(GetArea())

dbSelectArea("AF9")
dbSelectArea("AFC")

	AF9->(dbSetOrder(2))
	If AF9->(MsSeek(xFilial("AF9") + cProjeto + cRevisa + cEDTPai))
		While AF9->(!Eof()) .And. (xFilial("AF9") + cProjeto + cRevisa + cEDTPai) == AF9->(AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI)
			//Verifica os impostos da tarefa atual para recalculo
			nTotImpEDT += PmsVerImpostos(cProjeto, cRevisa, cEDTPai, AF9->AF9_TAREFA)
			AF9->(dbSkip())
		End
	EndIf

	//Atualiza total de imposto da EDT
	AFC->(dbSetOrder(1))
	If AFC->( MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDTPai) )
		RecLock("AFC",.F.)
			AFC->AFC_TOTIMP := nTotImpEDT
		MsUnlock()
	EndIf

RestArea(aAreaEDT)
RestArea(aArea)

Return nTotImpEDT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsVerImpostos  ºAutor³Fabricio Romera º Data ³  20/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica e recalcula impostos dos produtos da tarefa.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PmsVerTarefa                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsVerImpostos(cProjeto, cRevisa, cEDTPai, cTarefa)

Local aArea			:= GetArea()
Local cItem			:= ""
Local cProd	   		:= ""
Local cRecurso  	:= ""
Local nQtde	   		:= 0
Local nPrecoUnit	:= 0
Local aImposto		:= {}
Local J				:= 0
Local nTotImpTrf	:= 0

DbSelectArea("AF9")

DbSelectArea("AFA")
AFA->(DbSetOrder(1))

DbSelectArea("AN9")
AN9->(DbSetOrder(1))

//Verifica se existem impostos de produtos excluidos
AN9->( MsSeek(xFilial("AN9") + cProjeto + cRevisa + cTarefa) )
While AN9->(!Eof()) .And. (xFilial("AN9") + cProjeto + cRevisa + cTarefa) == AN9->(AN9_FILIAL + AN9_PROJET + AN9_REVISA + AN9_TAREFA)
	If AFA->( ! MsSeek(xFilial("AFA") + cProjeto + cRevisa + cTarefa + AN9->(AN9_ITEM + AN9_PRODUT + AN9_RECURS) ) )
		RecLock("AN9",.F.,.T.)
			AN9->( dbDelete() )
		MsUnlock()
	End If
	AN9->(DbSkip())
End

//Recaulcula impostos dos produtos da tarefa
If AFA->( MsSeek(xFilial("AFA") + cProjeto + cRevisa + cTarefa) )
	While AFA->(!Eof()) .And. (xFilial("AFA") + cProjeto + cRevisa + cTarefa) == AFA->(AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA)

		cItem 	   := AFA->AFA_ITEM
		cProd	   := AFA->AFA_PRODUT
		cRecurso   := AFA->AFA_RECURS
		nQtde	   := AFA->AFA_QUANT
		nPrecoUnit := AFA->AFA_CUSTD
		aImposto   := {}

		//Calcula impostos para o produto
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+ cProd))
		PMSAN9ClcImp(@aImposto, cProd, nQtde, nPrecoUnit )

		AN9->(DbSetOrder(1))
		cChave := xFilial("AN9") + cProjeto + cRevisa + cTarefa + cItem + cProd + cRecurso
		AN9->(DbSeek(cChave))

		//Verifica Excluidos
        While AN9->(!Eof()) .And. ;
       	  cChave = xFilial("AN9") + AN9->(AN9_PROJET + AN9_REVISA + AN9_TAREFA + AN9_ITEM + AN9_PRODUT + AN9_RECURS)

            //Exclui imposto
			If aScan(aImposto, {|x| x[1]== AN9->AN9_CODIMP}) = 0
				RecLock("AN9",.F.,.T.)
					dbDelete()
				MsUnlock()
			End If

			AN9->(DbSkip())
		End

		AN9->(DbSetOrder(1))

		//Verifica Incluidos/Alterados
		For J := 1 to Len(aImposto)

			cChave := xFilial("AN9") + cProjeto  + cRevisa + cTarefa + cItem + cProd + cRecurso + aImposto[J][1]

			If AN9->(DbSeek(cChave))
			    //Altera valor do imposto
				If AN9->(AN9_PERC) != aImposto[J][2] .Or. AN9->(AN9_VALIMP) != aImposto[j][3]

					RecLock("AN9", .F.)
						AN9->(AN9_PERC)   := aImposto[J][2]
						AN9->(AN9_VALIMP) := aImposto[j][3]
					MsUnlock()

				End If
			Else
				//Inclui
				RecLock("AN9", .T.)
					AN9->(AN9_FILIAL) := xFilial("AN9")
					AN9->(AN9_PROJET) := cProjeto
					AN9->(AN9_REVISA) := cRevisa
					AN9->(AN9_TAREFA) := cTarefa
					AN9->(AN9_ITEM)   := cItem
					AN9->(AN9_PRODUT) := cProd
					AN9->(AN9_RECURS) := cRecurso
					AN9->(AN9_CODIMP) := aImposto[J][1]
					AN9->(AN9_PERC)   := aImposto[J][2]
					AN9->(AN9_VALIMP) := aImposto[j][3]
				MsUnlock()
			End If
		Next

		//Totaliza Impostos da Tarefa
		For J := 1 to Len(aImposto)
			nTotImpTrf += aImposto[J][3]
		Next

		//Atualiza total de imposto da Tarefa
		AF9->(dbSetOrder(1))
		If AF9->( MsSeek(xFilial("AF9") + cProjeto + cRevisa + cTarefa) )
			RecLock("AF9",.F.)
				AF9->AF9_TOTIMP := nTotImpTrf
			MsUnlock()
		End If

		AFA->(DbSkip())
	End

EndIf

RestArea(aArea)
Return nTotImpTrf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSGetAN9Desc ºAutor  ³Fabricio Romera     º Data ³  07/12/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna descricao do codigo de imposto passado.              º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSGetAN9Desc(cCodImp)

Local cDescrImp := cCodImp

If cCodImp = "ICM"

	cDescrImp := "ICMS"

ElseIf cCodImp = "SOL"

	cDescrImp := "ICMS Solidario"

ElseIf cCodImp = "IRR"

	cDescrImp := "IR"

ElseIf cCodImp = "INS"

	cDescrImp := "INSS"

ElseIf cCodImp = "PIS"

	cDescrImp := "PIS"

ElseIf cCodImp = "COF"

	cDescrImp := "COFINS"

ElseIf cCodImp = "CMP"

	cDescrImp := "ICMS Complementar"

ElseIf cCodImp = "CSL"

	cDescrImp := "CSLL"

ElseIf cCodImp = "PS2"

	cDescrImp := "PIS/Pasep - Via apuracao"

ElseIf cCodImp = "CF2"

	cDescrImp := "COFINS - Via apuracao"
End If


Return cDescrImp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PmsSlEmail   ºAutor  ³Totvs               º Data ³ 18/03/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para selecao de email para notificacao                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsSlEmail( aLista, aCntsObrig )
Local aContatos	:= {}
Local cRet		:= ""
Local lCntObri	:= GetMV( "MV_NTRJEML" ) == "1"			// Se verifica contatos obrigatorios
Local lRet		:= .F.
Local nChkLst	:= 1
Local nInc		:= 0
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
Local oBtn1
Local oBtn2
Local oBtn3
Local oChkLst
Local oDlg
Local oSay1

Default aLista	:= { { "", "" } }

// Nao apresenta a tela se nao houver contatos
If Empty( aLista )
	Return cRet
EndIf

// Verifica se os contatos obrigatrios tambem estao na lista
If lCntObri
	For nInc := 1 To Len( aCntsObrig )
		If aScan( aLista, { |x| AllTrim( Lower( x[2] ) ) == aCntsObrig[nInc][2] } ) == 0
			aAdd( aLista, { aCntsObrig[nInc][1], aCntsObrig[nInc][2] } )
		EndIf
	Next
EndIf

// Monta os itens da selecao para que aparecam todos selecionados
For nInc := 1 To Len( aLista )
	aAdd( aContatos, { .T., aLista[nInc][1], aLista[nInc][2] } )
Next

// Classificar por nome para facilitar a localizacao
aContatos := aSort( aContatos,,, { |x,y| AllTrim( x[2] ) < AllTrim( y[2] ) } )

// Monta a Tela
DEFINE MSDIALOG oDlg TITLE STR0117 FROM 0, 0 TO 350,550 PIXEL //"Seleção de Contatos"

@ 005, 007 SAY oSay1 	PROMPT 	STR0118 SIZE 104, 7 OF oDlg PIXEL //"Selecione os contatos pra envio do email:"

@ 014, 007  LISTBOX oChkLst VAR nChkLst FIELDS	COLSIZES 30, 100 HEADER  "", STR0115, STR0116 SIZE 265, 140 OF oDlg PIXEL  //"Nome","E-Mail"
oChkLst:SetArray( aContatos )
oChkLst:bLine     	:= { || { IIf(aContatos[oChkLst:nAt,1],oOk,oNo), aContatos[oChkLst:nAt][2], aContatos[oChkLst:nAt][3] } }
oChkLst:blDblClick	:= { || ( PMSVldCnt( @aContatos, aCntsObrig, lCntObri, oChkLst:nAt ), oChkLst:Refresh() ) }

@ 160, 155 BUTTON oBtn1 PROMPT STR0119		SIZE 37, 12 ACTION ( PmsAddEmail( @aContatos ), oChkLst:Refresh() )	OF oDlg PIXEL //"Adicionar"
@ 160, 195 BUTTON oBtn2 PROMPT STR0120  	SIZE 37, 12 ACTION ( lRet := .F., oDlg:End() ) 						OF oDlg PIXEL //"Cancela"
@ 160, 235 BUTTON oBtn3 PROMPT STR0121 		SIZE 37, 12 ACTION ( lRet := .T., oDlg:End() )							OF oDlg PIXEL //"Ok"
ACTIVATE MSDIALOG oDlg CENTERED

If lRet
	For nInc := 1 To Len( aContatos )
		If aContatos[nInc][1] .AND. !Empty( aContatos[nInc][3] )
			If !Empty( cRet )
				cRet += ";"
			EndIf

			cRet += aContatos[nInc][3]
		EndIf
	Next
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PmsAddEmail  ºAutor  ³Totvs               º Data ³ 18/03/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona contatos na lista de email.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsAddEmail( aContatos )
Local cNome		:= Space( 040 )
Local cEmail	:= Space( 250 )
Local oDlg
Local oGet1
Local oGet2
Local oSay1
Local oSay2

// Monta a Tela
DEFINE MSDIALOG oDlg FROM 0, 0 TO 110,395 PIXEL //"Seleção de Contatos"

@ 005, 007 SAY oSay1 PROMPT STR0115			SIZE 104, 7 OF oDlg PIXEL //"Nome:"
@ 020, 007 SAY oSay2 PROMPT STR0116 		SIZE 104, 7 OF oDlg PIXEL //"E-Mail:"

@ 005, 027 MSGET oGet1 VAR cNome			SIZE 165,010 OF oDlg PIXEL
@ 020, 027 MSGET oGet2 VAR cEmail			SIZE 165,010 OF oDlg PIXEL

@ 040, 115 BUTTON oBtn2 PROMPT STR0121		SIZE 37, 12 ACTION ( IIf( lRet := PMSVldAddCnt( cNome, cEMail ), oDlg:End(),) )	OF oDlg PIXEL //"Cancela"
@ 040, 155 BUTTON oBtn3 PROMPT STR0120		SIZE 37, 12 ACTION ( lRet := .F., oDlg:End() ) 									OF oDlg PIXEL //"Confirmar"
ACTIVATE MSDIALOG oDlg CENTERED

If lRet
	aAdd( aContatos, { .T., AllTrim( cNome ), AllTrim( cEmail ) } )

	// Classificar por nome para facilitar a localizacao
	aContatos := aSort( aContatos,,, { |x,y| AllTrim( x[2] ) < AllTrim( y[2] ) } )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMSVldCnt    ºAutor  ³Totvs               º Data ³ 19/03/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se os contatos obrigatorios foram selecionados     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSVldCnt( aContatos, aCntsObrig, lCntObri, nAt )

If lCntObri
	If aScan( aCntsObrig, { |x| x[2] == aContatos[nAt][3] } ) > 0
		Help( " ", 1, "PMSVLDCNT",, STR0122, 1, 0 ) //"Este contato é obrigatório!"
		aContatos[nAt,1] := .T.
	Else
		aContatos[nAt,1] := !aContatos[nAt,1]
	EndIf
Else
	aContatos[nAt,1] := !aContatos[nAt,1]
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMSVldAddCnt ºAutor  ³Totvs               º Data ³ 19/03/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica campos na inclusao de novos contatos               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSVldAddCnt( cNome, cEMail )
Local lRet := !Empty( cNome ) .AND. !Empty( cEMail )

If !lRet
	Help( " ", 1, "PMSVLDADD",, STR0123, 1, 0 ) //"Os campos desta tela são obrigatórios!"
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSGrvMotivo³ Autor ³ Totvs            	³ Data ³ 14/03/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava os motivos das rejeicoes conforme tipo de controle		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSGrvMotivo( lRejTrf, aMotivos, cUser, nRecAF9, nRecAN8, cEtpRej, cAlias, cQNCRej )
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->( GetArea() )
Local aAreaAF9	:= AF9->( GetArea() )
Local aAreaAN8	:= AN8->( GetArea() )
Local nInc		:= 0

DEFAULT cEtpRej := AF9->AF9_TPACAO
DEFAULT cQNCRej := AF9->AF9_TPACAO

// Garante posicionamento nas tabelas AF9
AF9->( DbGoTo( nRecAF9 ) )

If lRejTrf		// Rejeicao da Tarefa
	cAlias := "ANB"
	// Garante posicionamento nas tabelas AN8
	// Pois quando ocorre rejeicao por tarefa (AF8_PAR002=2)
	// é gravado um registro na tabela AN8
	AN8->( DbGoTo( nRecAN8 ) )
	For nInc := 1 To Len( aMotivos )
		RecLock( "ANB", .T. )
		ANB->ANB_FILIAL	:= xFilial( "ANB" )
		ANB->ANB_FILREJ	:= AN8->AN8_FILIAL
		ANB->ANB_PROJET	:= AN8->AN8_PROJET
		ANB->ANB_REVISA	:= AN8->AN8_REVISA
		ANB->ANB_TAREFA	:= AN8->AN8_TAREFA
		ANB->ANB_TRFORI := AN8->AN8_TRFORI
		ANB->ANB_DATA	:= AN8->AN8_DATA
		ANB->ANB_HORA	:= AN8->AN8_HORA
		ANB->ANB_ITEM	:= StrZero( nInc, TamSX3( "ANB_ITEM" )[1] )
		ANB->ANB_TIPERR	:= aMotivos[nInc][1]
		ANB->ANB_MOTIVO	:= aMotivos[nInc][2]
		ANB->ANB_REJEIT	:= cUser
		ANB->ANB_EXEC	:= cUser
		ANB->ANB_ETPREJ	:= AF9->AF9_TPACAO
		ANB->ANB_ETPEXE	:= AF9->AF9_TPACAO
		if Len(aMotivos[nInc]) > 2
			aMotivos[nInc,3] := ANB->( Recno())
		Endif
		MsUnLock()
	Next

Else			// Rejeicao do Plano de Acao
	cAlias := "ANC"
	For nInc := 1 To Len( aMotivos )
		RecLock( "ANC", .T. )
		ANC->ANC_FILIAL	:= xFilial( "ANC" )
		ANC->ANC_PROJET	:= AF9->AF9_PROJET
		ANC->ANC_REVISA	:= AF9->AF9_REVISA
		ANC->ANC_TAREFA	:= AF9->AF9_TAREFA
		ANC->ANC_DATA	:= dDataBase
		ANC->ANC_HORA	:= substr( Time(), 1, 5 )
		ANC->ANC_ITEM	:= StrZero( nInc, TamSX3( "ANC_ITEM" )[1] )
		ANC->ANC_TIPERR	:= aMotivos[nInc][1]
		ANC->ANC_MOTIVO	:= aMotivos[nInc][2]
		ANC->ANC_REJEIT	:= cUser
		ANC->ANC_EXEC	:= cUser
		ANC->ANC_ETPREJ	:= cEtpRej
		ANC->ANC_ETPEXE	:= AF9->AF9_TPACAO
		if Len(aMotivos[nInc]) > 2
			aMotivos[nInc,3] := ANC->( Recno())
		Endif
		MsUnLock()
	Next
EndIf

RestArea( aAreaAN8 )
RestArea( aAreaAF9 )
RestArea( aAreaAF8 )
RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PMSCtrlRej ºAutor³ Totvs                     º Data ³ 31/03/2011    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Verifica se o projeto realiza controle de rejeicao de tarefas       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSCtrlRej( cCodProj )
Local aArea 	:= GetArea()
Local aAreaAF8	:= AF8->( GetArea() )
Local lRet 		:= .F.

Default cCodProj := AF8->AF8_PROJET

	AF8->( DbSetOrder( 1 ) )
	lRet := AF8->( DbSeek( xFilial( "AF8" ) + cCodProj ) ) .AND. ( AF8->AF8_PAR002 == "1" .OR. AF8->AF8_PAR002 == "2" )

RestArea( aAreaAF8 )
RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsConvertºAutor  ³ Clovis Magenta     º Data ³  05/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao chamada a partir de gatilho do campo AFR_VALOR -    º±±
±±º          ³ Titulo a pagar x PMS - para realizar a conversao de moedas º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsConvert(nValor, nMoedaD, nMoedaO, dData)
Local nVlrConv := 0
Local cCampo	:= ReadVar()
Local nCmpTam		:= 0
DEFAULT nValor := 0
DEFAULT nMoedaD:= 1
DEFAULT nMoedaO:= 1
DEFAULT dData	:= dDataBase

If "AFR_VALOR1" $ cCampo
	
	nCmpTam := TamSX3("AFR_VALOR"+CvalToChar(nMoedaD))[2]
		
	nVlrConv := Round(xMoeda(nValor , nMoedaO , nMoedaD , dData ,nCmpTam + 5 , ,IIF(M->E2_MOEDA = nMoedaD , IIF(M->E2_TXMOEDA > 0, M->E2_TXMOEDA , Nil), Nil)),nCmpTam)
	
	If M->E2_MOEDA > 1
		// nValor = valor digitado para moeda 1
		nVlrMax := Round(NoRound(xMoeda(M->E2_VALOR , M->E2_MOEDA , 1 , dData , 3, IIF(M->E2_TXMOEDA > 0, M->E2_TXMOEDA , Nil)),3),2)
		If (nVlrMax<> 0) .and. (nValor > nVlrMax)
			If (M->E2_MOEDA == nMoedaD)
				Help( " ", 1, "PMSMOED1",, STR0124, 1, 0 )// Valor digitado é maior que o valor deste título na moeda corrente.
				nVlrConv := 0
			Else
				nVlrConv := 0
			Endif
		Endif
	Endif

ELSEIF "AFT_VALOR1" $ cCampo

	nVlrConv := Round(NoRound(xMoeda(nValor , nMoedaO , nMoedaD , dData , 3, ,IIF(M->E1_MOEDA = nMoedaD , IIF(M->E1_TXMOEDA > 0, M->E1_TXMOEDA , Nil), Nil)),3),2)

	If M->E1_MOEDA > 1
		// nValor = valor digitado para moeda 1
		nVlrMax := Round(NoRound(xMoeda(M->E1_VALOR , M->E1_MOEDA , 1 , dData , 3, IIF(M->E1_TXMOEDA > 0, M->E1_TXMOEDA , Nil)),3),2)
		If (nVlrMax<> 0) .and. (nValor > nVlrMax)
			If (M->E1_MOEDA == nMoedaD)
				Help( " ", 1, "PMSMOED1",, STR0124, 1, 0 )// Valor digitado é maior que o valor deste título na moeda corrente.
				nVlrConv := 0
			Else
				nVlrConv := 0
			Endif
		Endif
	Endif

Endif

Return nVlrConv

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSExibeCpoImp ºAutor  	³TOTVS  º 		Data ³  21/06/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita/desabilita campos totalizadores de impostos das    º±±
±±º          ³EDTs/Tarefas do Projeto conforme conteudo do campo          º±±
±±º          ³AF8_PAR006										          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PMS200Dlg / PMS410Dlg                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSExibeCpoImp(lCalcTrib)

Local aArea 	:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local cCpoAFC 	:= "AFC_TOTIMP"
Local cCpoAF9 	:= "AF9_TOTIMP"
Local cUsado	:= "€€€€€€€€€€€€€€ "
Local cNaoUsado	:= "€€€€€€€€€€€€€€€"

Default lCalcTrib := .F.

PMSX3Field(cCpoAFC,"X3_USADO",IIf(lCalcTrib,cUsado,cNaoUsado))
PMSX3Field(cCpoAF9,"X3_USADO",IIf(lCalcTrib,cUsado,cNaoUsado))

RestArea(aAreaAF8)
RestArea(aArea)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSCvtCusN³ Autor ³ Clovis Magenta        ³ Data ³ 22-09-2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de conversao de moeda do custo previsto nas tarefas.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Custo a ser convertido                                 ³±±
±±³          ³ExpN2: Moeda do Custo a ser convertido                        ³±±
±±³          ³ExpC3: Tipo de Taxa                                           ³±±
±±³          ³ExpD4: Data fixa para conversao                               ³±±
±±³          ³ExpD5: Data inicial da tarefa                                 ³±±
±±³          ³ExpD6: Data final da tarefa                                   ³±±
±±³          ³ExpA7: Array de retorno do Custo ( Opcional )                 ³±±
±±³          ³ExpA8: Array das Taxas de Conversao Informadas pelo Usuario   ³±±
±±³          ³ExpA9: Trunca (1) Arredonda (2)							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nCustoMX (onde X é a moeda escolhida para conversao)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function xMoedaPMS(nCusto,nMoedaO,nMoedaD,cCnvPRV,dDtConv,dStart,dFinish,nTXMoedO,nTXMoedD,cTrunca,nQuantTrf,cTabela)

Local nx
Local dAuxConv
Local nDecCst	:= 0
Local cCampo
Local cCpoTaxO := ""
Local cCpoTaxD := ""
Local aDecCst  := {TamSX3("AF9_CUSTO")[2], TamSX3("AF9_CUSTO2")[2], TamSX3("AF9_CUSTO3")[2], TamSX3("AF9_CUSTO4")[2], TamSX3("AF9_CUSTO5")[2]}
Local nIdxCpo  := 1 // indice do vetor aCampos (default AF9)
Local aCampos  := {	{"AF9","AF9_CUSTO"	,"1",.T.,.T.},;
							{"AFU","AFU_CUSTO"	,"1",.T.,.F.},;
							{"AJC","AJC_CUSTO"	,"1",.T.,.F.},;
							{"AFB","AFB_VALOR"	,"" ,.F.,.F.},;
							{"SD1","D1_CUSTO"		,"" ,.T.,.F.},;
							{"SD2","D2_CUSTO"		,"1",.T.,.F.},;
							{"SD3","D3_CUSTO"		,"1",.T.,.F.},;
							{"AFR","AFR_VALOR"	,"1",.T.,.F.},;
							{"SE5","E5_VALOR"		,"" ,.F.,.F.},;
							{"AJE","AJE_VALOR"	,"" ,.F.,.F.},;
							{"AE8","AE8_VALOR"	,"" ,.F.,.F.},;
							{"AFB","AE8_VALOR"	,"" ,.F.,.F.},;
							{"SB1","B1_CUSTD"		,"" ,.F.,.F.}}
// aCampos[x,1] -> ALIAS DA TABELA
// aCampos[x,2] -> RAIZ DO CAMPO
// aCampos[x,3] -> INICIO DA NUMERACAO DOS CAMPOS - "1" ou "" (1 se comeca com CUSTO1 e branco se comeca com CUSTO)
// aCampos[x,4] -> INDICA SE TEM MAIS CAMPOS OU SE E CAMPO UNICO - .T. = VARIOS CAMPOS NUMERADOS; .F. = CAMPO UNICO
// aCampos[x,5] -> .T. = CONVERTE PELA TAXA ; .F. CONVERTE PELA DATA DO PROJETO OU DO DIA
//

DEFAULT nMoedaO   := 1
DEFAULT nMoedaD   := 1
DEFAULT dStart    := AF9->AF9_START
DEFAULT dFinish   := AF9->AF9_FINISH
DEFAULT nQuantTrf := AF9->AF9_QUANT
DEFAULT nTxMoedO  := nMoedaO
DEFAULT nTxMoedD  := nMoedaD
DEFAULT cTabela   := "AF9"
DEFAULT cTrunca	:= "1"

// se for qualquer tabela diferente de AF9 - deve sempre usar o custo gravado na tabela para calcular
// pois na consulta PMSC010 funciona assim
if cTabela <> "AF9"
	cCnvPRV := "7"
	nIdxCpo := Ascan(aCampos,{|e| e[1] == cTabela})
//	if nIdxCpo == 0
//		nIdxCpo := 1
//	Endif
Endif

if nTxMoedO == Nil .or. nTxMoedO <= 1
	nTaxaO   := 1
Else
	cCpoTaxO := "AF9_TXMO"+Alltrim(STR(nTxMoedO))
	nTaxaO   := AF9->( &cCpoTaxO )
Endif

if nTxMoedD == Nil .or. nTxMoedD <= 1
	nTaxaD   := 1
Else
	cCpoTaxD := "AF9_TXMO"+Alltrim(STR(nTxMoedD))
	nTaxaD   := AF9->( &cCpoTaxD )
Endif

cCampo := "AF9_CUSTO"+IIF(nMoedaD > 1, Alltrim(STR(nMoedaD)) ,"1")

if Empty(cCnvPrv) .or. Empty(dDtConv)
	// localiza a data e o tipo de conversao
	PmsVerConv(@dDtConv,@cCnvPrv)
Endif

// Default para a data e tipo de conversao
cCnvPRV := if(Empty(cCnvPrv),"1",cCnvPrv)
dDtConv := if(Empty(dDtConv),dDataBase,dDtConv)

If AF9->(ColumnPos(cCampo)>0)
	nDecCst:=TamSX3(cCampo)[2]
Else
	nDecCst:=TamSX3("AF9_CUSTO")[2]
Endif

If nMoedaD <= 0
	Return nCusto
EndIf

Do Case
	Case cCnvPrv == "2" // Data Fixa
		nCusto	:= PmsTrunca(cTrunca,xMoeda(nCusto,nMoedaO,nMoedaD,dDtConv,nDecCst),nDecCst,nQuantTrf)

	Case cCnvPrv == "3" // Taxa Media ( 3 Valores )

		dAuxConv := dStart
		nCustAux := 0
		For nx := 1 to 3
			nCustAux	+= xMoeda(nCusto,nMoedaO,nMoedaD,dAuxConv,aDecCst[nMoedaD])
			dAuxConv += (dFinish-dStart)/3
		Next nx
		nCusto	:= PmsTrunca(cTrunca,nCustAux/3,nDecCst,nQuantTrf)

	Case cCnvPrv == "4" // Taxa Media ( 15 Valores )

		dAuxConv := dStart
		nCustAux := 0
		For nx := 1 to 15
			nCustAux	+= xMoeda(nCusto,nMoedaO,nMoedaD,dAuxConv,aDecCst[nMoedaD])
			dAuxConv	+= (dFinish-dStart)/15
		Next nx
		nCusto	:= PmsTrunca(cTrunca,nCustAux/15,nDecCst,nQuantTrf)

	Case cCnvPrv == "5" // Data Inicial
		nCusto	:= PmsTrunca(cTrunca,xMoeda(nCusto,nMoedaO,nMoedaD,dStart,nDecCst),nDecCst,nQuantTrf)

	Case cCnvPrv == "6" // Data Final
		nCusto	:= PmsTrunca(cTrunca,xMoeda(nCusto,nMoedaO,nMoedaD,dFinish,nDecCst),nDecCst,nQuantTrf)

	Case cCnvPrv == "7" // Usuario Informa
		If nTaxaD == 0
			nCusto	:= 0
		Else
			if cTabela == "AF9"
				nCusto	:= PmsTrunca(cTrunca,xMoeda(nCusto,nMoedaO,nMoedaD,,nDecCst,nTaxaO,nTaxaD),nDecCst,nQuantTrf)
			Else
				cCampo := aCampos[nIdxCpo,2]
				if aCampos[nIdxCpo,4] // campos multiplos de custo
					if Empty(aCampos[nIdxCpo,3]) // comeca com custo
						if nMoedaD > 1 // posiciona no campo custox
							cCampo := cCampo + Str(nMoedaD,1)
						Endif
					Else // comeca com custo1
						cCampo := cCampo + Str(nMoedaD,1)
					Endif
				Endif

				nCusto	:= &(cTabela+"->"+cCampo)

			Endif
		EndIf

	OtherWise	// Data Base
		nCusto	:= PmsTrunca(cTrunca,xMoeda(nCusto,nMoedaO,nMoedaD,,nDecCst),nDecCst,nQuantTrf)

EndCase

Return nCusto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsAtuSucesºAutor  ³Clovis Magenta      º Data ³  22/05/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina usada para recalcular as datas previstas de suces-  º±±
±±º          ³ soras a partir da nova data de inicio da predecessora.	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamada no PMSXFUN - PmsAF8Calc() -> REPROGRAMACAO			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmsAtuSuces(aTsk,lReprParc,nMetodo)
Local aArea			:= GetArea()
Local aAreaAF9		:= AF9->(GetArea())
Local aBaseDados	:= {}
Local aAtuEDT		:= {}

PmsSimScs(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,.F., {} , lReprParc, @aBaseDados)
If Len(aBaseDados)>0
	PA203GrvTrf(aBaseDados, @aAtuEDT ) // grava os dados simulados e validados anteriormente
Endif

RestArea(aAreaAF9)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSVldRes  ºAutor  ³Clovis Magenta      º Data ³  08/06/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida as novas datas e horas de uma determinada tarefa	  º±±
±±º          ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSVldRes(aDados, nReg, lAviso)

Local aArea	 	:= GetArea()
Local aAreaAFD 	:= AFD->(GetArea())
Local aAreaAF9 	:= AF9->(GetArea())
Local cStart 	:= DtoS(aDados[1])
Local cFinish	:= DtoS(aDados[3])
Local cHorai 	:= SubStr(aDados[2],1,2)+SubStr(aDados[2],4,2)
Local cHoraF 	:= SubStr(aDados[4],1,2)+SubStr(aDados[4],4,2)

Local cRestricao:= ""
Local cDataRest := ""
Local cHoraRest := ""
Local lOk	 	:= .T.

DEFAULT lAviso	:= !isAuto()
DEFAULT nReg	:= AF9->(Recno()) //SUBENTENDE-SE QUE A AF9 ESTEJA POSICIONADA CASO NAO PASSE O NREG

dbselectarea("AF9")
AF9->(dbGoTo(nReg))

cRestricao := AF9->AF9_RESTRI
cDataRest  := DTOS(AF9->AF9_DTREST)
cHoraRest  := SubStr(AF9->AF9_HRREST,1,2)+SubStr(AF9->AF9_HRREST,4,2)

If !Empty(cDataRest) .AND. !Empty(cHoraRest)
 	Do case
		Case cRestricao == "1"  // iniciar em

			If (cStart+cHorai)<>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0020,STR0132+Alltrim(AF9->AF9_TAREFA)+".",{STR0034},1,STR0133) //"A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa "
				Endif
			EndIf

		Case cRestricao == "2"  // terminar em

			If (cFinish+cHoraF) <> (cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0020,STR0134+Alltrim(AF9->AF9_TAREFA)+".",{STR0034},1,STR0133) // "A Data/Hora Final da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "3"  // nao iniciar antes
			If (cStart+cHorai)<(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0020,STR0133+Alltrim(AF9->AF9_TAREFA)+".",{STR0034},1,STR0133) // "A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "4"  // nao iniciar depois
			If (cStart+cHorai)>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0020,STR0133+Alltrim(AF9->AF9_TAREFA)+".",{STR0034},1,STR0133) // "A Data/Hora Inicial da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "5"  // nao terminar antes
			If (cFinish+cHoraF)<(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0020,STR0134+Alltrim(AF9->AF9_TAREFA)+".",{STR0034},1,STR0133) // "A Data/Hora Final da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf

		Case cRestricao == "6"  // nao terminar depois
			If (cFinish+cHoraF)>(cDataRest+cHoraRest)
				lOk := .F.
				If lAviso
					Aviso(STR0020,STR0134+Alltrim(AF9->AF9_TAREFA)+".",{STR0034},1,STR0133) // "A Data/Hora Final da Tarefa inconsistente com a restrição da tarefa "
				EndIf
			EndIf
	EndCase

EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFD)
RestArea(aArea)

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |PmsVerAFR ºAutor  ³CLOVIS MAGENTA      º Data ³  20/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o titulo em questao no financeiro esta atreladoº±±
±±º          ³ a algum projeto                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION PmsVerAFR()
Local aSaveArea:= GetArea()
Local lRet := .F.

dbSelectArea("AFR")
dbSetOrder(2)//AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA
If dbSeek(xFilial("AFR")+ __SUBS->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),.T.)
	lRet:= .T.
EndIf

RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsIncAFR ºAutor  ³Clovis Magenta		  º Data ³  20/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz tratativa da substituicao de titulos PR no financeiro  º±±
±±º          ³ para saber se existe vinculo com tabela AFR                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA050                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsIncAFR()
Local aArea:= GetArea()
Local aAreaAFR:=AFR->(GetArea())
Local cProjeto
Local cRevisa
Local cTarefa
Local aRet := {}

dbSelectArea("AFR")
dbSetOrder(2)//AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA
If dbSeek(xFilial("AFR")+ __SUBS->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),.T.)

	cRevisa := PmsAF8Ver(AFR->AFR_PROJET)

	AFR->(dbSetOrder(2)) //AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA
	If dbSeek(xFilial("AFR")+ __SUBS->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+AFR->(AFR_PROJET+cRevisa+AFR_TAREFA))

		cProjeto		:= AFR->AFR_PROJET
		cRevisa		:= AFR->AFR_REVISA
		cTarefa		:= AFR->AFR_TAREFA
		cTipoDe		:= AFR->AFR_TIPOD

		Reclock("AFR" ,.F.)
			AFR->(dbDelete())
		AFR->(MsUnlock())

		aAdd(aRet,xFilial("AFR"))
		aAdd(aRet,cProjeto)
		aAdd(aRet,cRevisa)
		aAdd(aRet,cTarefa)
		aAdd(aRet,SE2->E2_PREFIXO)
		aAdd(aRet,SE2->E2_NUM)
		aAdd(aRet,SE2->E2_PARCELA)
		aAdd(aRet,SE2->E2_TIPO)
		aAdd(aRet,SE2->E2_FORNECE)
		aAdd(aRet,SE2->E2_LOJA)
		aAdd(aRet,SE2->E2_VENCREA)
		aAdd(aRet,xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO))
		aAdd(aRet,xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,2,SE2->E2_EMISSAO))
		aAdd(aRet,xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,3,SE2->E2_EMISSAO))
		aAdd(aRet,xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,4,SE2->E2_EMISSAO))
		aAdd(aRet,xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,5,SE2->E2_EMISSAO))
		aAdd(aRet,cTipoDe)
	EndIf
EndIf

RestArea(aAreaAFR)
RestArea(aArea)
Return aRet


/*/{Protheus.doc} PmsVldSC

Função para validar o item da solicitacao de compra com o rateio nos projetos e tarefas

@author (desconhecido)

@since (desconhecido)

@version P11

@param aHeader,   array, header da tabela SC1
@param aCols,    array, Cols da tabela SC1
@param cNumSC,    caracter, Codigo do numero da solicitacao de compra
@param lExclui,    logico,   Se é uma exclusão de item de solicitacao de comrpa

@return logico, Verdadeiro que passou pela validacao.

/*/
Function PmsVldSC(aHeader,aCols,cNumSC, lExclui)

Local aArea		:= GetArea()
Local aAreaSC1	:= SC1->(GetArea())
Local aAreaAFG	:= AFG->(GetArea())
Local lOk		:= .T.
Local lMt110	:= Alltrim(FUNNAME()) == "MATA110"
Local nX		:= 0
Local nTamArray	:= Len(aCols[1])

Local lPmsScBlq	:= SuperGetMv("MV_PMSCBLQ",,.F.)
Local lPmsAltSC := ExistBlock("PmsAltSC")

Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C1_ITEM"	})
Local nPQuant	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C1_QUANT"	})
Local nPosPrd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C1_PRODUTO"	})
Local nPosDt	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C1_DATPRF" 	})

Default lExclui := .F.

If lMt110 //validação somente para rotina MATA110
	If lPmsAltSC

		lOk := ExecBlock("PmsAltSC",.F.,.F., {aHeader,aCols,cNumSC,lExclui} )

	ElseIf lPmsScBlq

		If lExclui
			dbSelectArea("AFG")
			dbSetOrder(2)
			For nX:=1 to Len(aCols)
				If dbSeek(xFilial("AFG")+cNumSC+aCols[nX][nPItem])
		        	If !Empty(AFG->AFG_PLANEJ)
						lOk := .F.
						EXIT
					Endif
				Endif
			Next nX
		Else
			DbSelectArea("SC1")
			dbSetOrder(1)//C1_FILIAL+C1_NUM+C1_ITEM

			For nX:=1 to Len(aCols)

				If Dbseek(xFilial("SC1") + cNumSC + aCols[nX][nPItem] )

					If aCols[nX][nTamArray]
						lOk := .F.
					ElseIf (SC1->C1_QUANT <> aCols[nX][nPQuant]) .or. (SC1->C1_PRODUTO <> aCols[nX][nPosPrd]) .or. (SC1->C1_DATPRF <> aCols[nX][nPosDt])
						lOk := .F.
						Exit
					EndIf
				Endif
			Next nX
		Endif

		If !lOk
			If lExclui
				Help( " ", 1, "PMSSLC1",, STR0140, 1, 0 )//"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não sera possível excluí-la. Verificar parâmetrp MV_PMSCBLQ."
			Else
				Help( " ", 1, "PMSSLC2",, STR0139, 1, 0 )//"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não será possível alterar informações principais. Verificar parâmetro MV_PMSCBLQ."
			Endif
		Endif
	Endif

Endif

RestArea(aAreaAFG)
RestArea(aAreaSC1)
RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PmsPriRecno ºAutor  ³Microsiga         º Data ³  12/20/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o primeiro recno do arquivo temporario              º±±
±±º          ³necessario no PMS pois apos zap/pack em arquivo em ambiente º±±
±±º          ³ctree o retorno da funcao Recno() era igual a 2             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsPriRecno(cArquivo)
Local nRegPri := 1
Local nRegAtu := (cArquivo)->(Recno())  //salva o recno atual do arquivo

(cArquivo)->(dbGoTop()) //vai pra topo do arquivo
nRegPri := (cArquivo)->(Recno())  //salva o recno do topo do arquivo

If nRegAtu > 0
	(cArquivo)->(dbGoto(nRegAtu))  //restaura o recno atual
EndIf

Return(nRegPri)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsCpoPrj ³ Autor ³ Mauricio Pequim Jr     ³ Data ³ 21-01-2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do filtro da consulta ANE (SX8)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ *ExpC1 = Indicador de tipo do objeto que contem os campos      ³±±
±±³          ³     '1' =  Enchoice ou Model Field (MVC)                       ³±±
±±³          ³     '2' =  GetDados (padrão) ou Model Grid (MVC)               ³±±
±±³          ³ *ExpC2 = Nome do campo do codigo do projeto                    ³±±
±±³          ³ *ExpC3 = Nome do campo do codigo da revisao do projeto         ³±±
±±³          ³  ExpC4 = Nome do model que contem os campos acima (MVC)        ³±±
±±³          ³  ExpA5 = aHeader (caso os campos estejam em MsGetDados)        ³±±
±±³          ³  ExpA6 = aCols (caso os campos estejam em MsGetDados)          ³±±
±±³          ³                                                                ³±±
±±³          ³ *Informacoes obrigatorias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//239.02 - PROJETO X CONTRATOS
Function PmsCpoPrj(cProc,cCpoPrj,cCpoRev,cMyModel,aHeadE,aColsE)

DEFAULT cProc    := ""
DEFAULT cMyModel := ""
DEFAULT cCpoPrj  := ""
DEFAULT cCpoRev  := ""
DEFAULT aHeadE   := {}
DEFAULT aColsE   := {}


/*------ Exemplos de chamadas
OBS: Colocar a chamada da funcao sempre no campo When do campo de contrato

Enchoice
--------
PmsCpoPrj("1","AFN_PROJET","AFN_REVISA")

Model Field (MVC)
-----------------
PmsCpoPrj("1","AFN_PROJET","AFN_REVISA","AFNDETAIL")

MsGetDados ou MsNewGetDados
---------------------------
PmsCpoPrj("2","AFN_PROJET","AFN_REVISA",,aHeader,aCols)

Model Grid (MVC)
----------------
PmsCpoPrj("2","AFN_PROJET","AFN_REVISA","AFNDETAIL")
*/

If !Empty(cProc)
	cTipoObj := cProc
Endif

If !Empty(cMyModel) .and. ValType(cMyModel) == "C"
	cModelCpo := cMyModel
Endif

If !Empty(cCpoPrj)
	cCpoCodPrj := cCpoPrj
Endif

If !Empty(cCpoRev)
	cCpoCodRev := cCpoRev
Endif

aHeadS := aHeadE
aColsS := aColsE

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsPrjXCt ³ Autor ³ Mauricio Pequim Jr     ³ Data ³ 21-01-2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do filtro da consulta ANE (SX8)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Indicador de retorno da operacao                       ³±±
±±³          ³         1 = Retorna codigo do projeto                          ³±±
±±³          ³         2 = Retorna codigo do revisao do projeto               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsPrjXCt(nOper)

Local cProjeto	:= ""
Local cVersao	:= ""
Local cChave	:= ""

//Se nao forem passados os dados obrigatorios ==> consulta vazia
If !Empty(cCpoCodPrj) .and. !Empty(cCpoCodRev) .and. !Empty(cTipoObj)
	//MVC
	If !Empty(cModelCpo)
		oModelo  := FWModelActive()
		cProjeto := oModelo:GetValue(cModelCpo,cCpoCodPrj)
		cVersao  := oModelo:GetValue(cModelCpo,cCpoCodRev)
	Else
		//Enchoice
		If cTipoObj == '1'
			cProjeto := M->&cCpoCodPrj
			cProjeto := M->&cCpoCodRev

		//Getdados
		ElseIf cTipoObj == '2' .and. ValType(aHeadS) == "A"	.and. !Empty(aHeadS)
			cProjeto := aColsS[n][aScan(aHeadS,{|x|Alltrim(x[2])==cCpoCodPrj})]
			cVersao  := aColsS[n][aScan(aHeadS,{|x|Alltrim(x[2])==cCpoCodRev})]
		Endif
	Endif
Endif

If nOper == 1
	cChave := cProjeto
Else
	cChave := cVersao
Endif

Return cChave

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PMSVersion ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 21-01-2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificacao de Versao/Release                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSVersion()

If lVersion == NIL
	//Indica se e release compativel
	//Neste caso, superior a versão 11 release 11.80
	lVersion := ( VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() > "R6" ) .Or. VAL(GetVersao(.F.)) > 11

Endif

Return lVersion

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PMSCtrChk ³ Autor ³ Mauricio Pequim Jr     ³ Data ³ 21-01-2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo AFN_CONTRA                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do contrato                                     ³±±
±±³          ³ ExpL2 = Mostra Help                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSCtrChk(cContrato,lHelp)

Local lRet		:= .T.
Local aAreaANE	:= ANE->(GetArea())
Local cProjeto	:= aColsS[n][aScan(aHeadS,{|x|Alltrim(x[2])=="AFN_PROJET"})]
Local cVersao	:= aColsS[n][aScan(aHeadS,{|x|Alltrim(x[2])=="AFN_REVISA"})]

DEFAULT cContrato := ""
DEFAULT lHelp := .T.

ANE->(dbSetOrder(1))

If !Empty(cContrato) .and. !(ANE->(MsSeek(xFilial("ANE")+cProjeto+cVersao+cContrato)))
	Help( " ", 1, "PMSCTRCHK",,STR0141+CRLF+STR0142, 1, 0 ) //"O número de contrato informado não está relacionado ao Projeto/Revisão."###"Utilize a consulta F3 para verificar os contratos relacionados a este Projeto/Revisão"
	lRet := .F.
Endif

RestArea(aAreaANE)

Return lRet



//-------------------------------------------------------------------
/*{Protheus.doc} PMSALTTRF(cTabela,aGetCpos)
Funcao para Rotina automatica que troca os codigos de Tarefa ou EDT no PMS

@param cTabela, caracter,  Alias da tabela o qual os codigos pertencem
@param aGetCpos, Array, vetor com os campos a serem trocados

@return lRet, logico, Verdadeiro se houve a troca do codigo

@author Jandir Deodato
@since 29/01/2013
@version MP11.80
*/
//-------------------------------------------------------------------
Function PMSALTTRF(cTabela,aGetCpos)
Local cEntida	:= ""
Local aCampoTop	:= {}
Local aArea		:= GetArea()
Local aAreaTMP	:= {}
Local nPosCod	:=0
Local lRet		:=.F.
Local cFili		:=''
Local cProjet	:=''
Local cRevisa	:=''
Local cCodeAtual	:=''
Private cCodeNovo := ""
Private cAlias	:=''
Private cChave	:=''
Private cChaveOld:=''
Default aGetCpos	:={}
DEFAULT cTabela	:= ""

PmsVersion()
cAlias := cTabela

If lVersion
	If lDefTop
		If !Empty(aGetCpos)
			Do Case
				Case cAlias == "AF9"
					If (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == 'AF9_TAREFA'}))>0
						cCodeAtual := Padr(aGetCpos[nPosCod][2],Tamsx3("AF9_TAREFA")[1])
						If (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == 'NEW_AF9_TAREFA'}))>0
							cCodeNovo := Padr(aGetCpos[nPosCod][2],Tamsx3("AF9_TAREFA")[1])
						EndIf
					Endif
					PMSGetChv(@cFili,@cProjet,@cRevisa,aGetCpos,cAlias)
					cChave:=cFili+cProjet+cRevisa+cCodeNovo
					cChaveOld:=cProjet+cRevisa+cCodeAtual
					aValidGet := {}
					Aadd(aValidGet,{'cCodeAtual' ,cCodeAtual,"ExistCpo('AF9',cChaveOld)",.t.})
					Aadd(aValidGet,{'cCodeNovo'  ,cCodeNovo,"NoExistCod(cAlias,cChave,cCodeNovo)",.t.})
					If AF9->(MsVldGAuto(aValidGet)) // consiste os gets
						lRet := .T.
					Endif
					IF lRet
						dbSelectArea("AF9")
						aAreaTMP := AF9->(GetArea())
						AF9->(dbSetOrder(1))	//AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
						AF9->(dbSeek(cFili+cProjet+cRevisa+cCodeAtual))
						Begin Transaction
							cEntida := PmsGetEnt("AF9", AF9->(Recno()))
							aAdd(aCampoTOP, {"AF9", "AF9_TAREFA", "AF9_FILIAL", "AF9_PROJET", "AF9_REVISA", AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA+"' AND AF9_TAREFA = '"+AF9->AF9_TAREFA, , cCodeNovo}) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
							// Efetua a alteração do codigo da EDT no projeto referido.
							// Busca em todas as tabelas relacionada com o codigo da EDT substituindo.
							//
							AF9RecRelTables(AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA, cCodeAtual, cCodeNovo ,,@aCampoTOP)

							// altera o codigo da tarefa nas tabelas de acordo com o array aCampoTop
							PMSAltera(@aCampoTOP,{})

							// Libera os codigo reservados
							FreeUsedCode(.T.)

							PmsAltAC9("AF9", AF9->(Recno()) ,cCodeNovo , cEntida)
						End Transaction
						RestArea(aAreaTMP)
					Endif
				Case cAlias=="AFC"
					IF (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == 'AFC_EDT'}))>0
						cCodeAtual := Padr(aGetCpos[nPosCod][2],Tamsx3("AFC_EDT")[1])
					Endif
					If (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == 'NEW_AFC_EDT'}))>0
						cCodeNovo := Padr(aGetCpos[nPosCod][2],Tamsx3("AFC_EDT")[1])
					EndIf
					PMSGetChv(@cFili,@cProjet,@cRevisa,aGetCpos,cAlias)
					cChave:=cFili+cProjet+cRevisa+cCodeNovo
					cChaveOld:=cProjet+cRevisa+cCodeAtual
					 aValidGet := {}
					Aadd(aValidGet,{'cCodeAtual' ,cCodeAtual,"ExistCpo('AFC',cChaveOld)",.t.})
					Aadd(aValidGet,{'cCodeNovo'  ,cCodeNovo,"NoExistCod(cAlias,cChave,cCodeNovo)",.t.})
					If AFC->(MsVldGAuto(aValidGet)) // consiste os gets
						lRet := .T.
					Endif
					If lRet
						dbSelectArea("AFC")
						aAreaTMP := AFC->(GetArea())
						AFC->(dbSetOrder(1))//AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
						AFC->(dbSeek(cFili+cProjet+cRevisa+cCodeAtual))
						Begin Transaction
							cEntida := PmsGetEnt("AFC", AFC->(Recno()))
							// EDT Selecionada
							aAdd(aCampoTOP, {"AFC", "AFC_EDT", "AFC_FILIAL", "AFC_PROJET", "AFC_REVISA", AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA+"' AND AFC_EDT = '"+AFC->AFC_EDT, , cCodeNovo})
							// Tarefas filho da EDT
							aAdd(aCampoTOP, {"AF9","AF9_EDTPAI","AF9_FILIAL","AF9_PROJET","AF9_REVISA",AFC->AFC_FILIAL,AFC->AFC_PROJET,AFC->AFC_REVISA+" ' AND AF9_EDTPAI ='"+AFC->AFC_EDT,, cCodeNovo })
							// Efetua a alteração do codigo da EDT no projeto referido.
							// Busca em todas as tabelas relacionada com o codigo da EDT substituindo.
							//
							AFCRecRelTables(cFili, cProjet, cRevisa, cCodeAtual, cCodeNovo,, aCampoTOP)
							PmsAltAC9("AFC", AFC->(Recno()) ,cCodeNovo , cEntida)

						End Transaction
						RestArea(aAreaTMP)
					Endif
			EndCase
		Endif
	Else
		Help(,,"TOPCONN",,STR0143,1,0)//'A rotina está preparada para ser processada somente em ambientes TOPCONNECT/DBACCESS.'
	EndIf
Else
	Help(,,"VER1180",,STR0144,1,0)//"Para utilizar este recurso, é necessário o Release 11.80 do Protheus ou superior. Entre em contato com o suporte TOTVS."
	lRet:=.F.
Endif
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} NoExistCod

Verifica se o conteudo não existe na tabela e se o codigo passado esta vazio

@param cAlias, caracter, Alias da tabela a ser verificada
@param cChave, caracter,  Chave do registro do seek
@param cCodeNovo, caracter, Novo codigo a ser atribuido ao registro

@return lRet, logico, Verdadeiro o codigo informado não existe na base

@author Reynaldo Tetsu Miyashita
@since 17/01/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function NoExistCod(cAlias,cChave,cCodeNovo)
Local lRet		:= .T.
Local aArea		:=GetArea()
Local aAreaAux	:={}
Default cChave 	:= ""
Default cCodeNovo	:=''
If !Empty (cCodeNovo)
	If cAlias=="AFC"
		If !Empty(cChave)
			dbSelectArea("AFC")
			aAreaAux:=AFC->(GetArea())
			dbSetOrder(1)
			If dbSeek(cChave)
				Help(,,"EXISTCOD",,STR0145,1,0)//"O código sugerido para troca já existe!"
				lRet := .F.
				cCodeNovo:=''
			EndIf
			RestArea(aAreaAux)
		Else
			lRet := .F.
		EndIf
	ElseIF cAlias=="AF9"
		If !Empty(cChave)
			dbSelectArea("AF9")
			aAreaAux:=AF9->(GetArea())
			dbSetOrder(1)
			If dbSeek(cChave)
				Help(,,"EXISTCOD",,STR0145,1,0)//"O código sugerido para troca já existe!"
				lRet := .F.
				cCodeNovo:=''
			EndIf
			RestArea(aAreaAux)
		Else
			lRet := .F.
		EndIf
	Else
		Help(,,"NOTABE",,STR0146,1,0)//"Não foi informada a tabela de pesquisa."
		lRet := .F.
	Endif
Else
	Help(,,"NONEWCODE",,STR0147,1,0)//"Não foi informado o novo código do registro."
	lRet := .F.
Endif

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} PMSGetCHV
Funcao que vai carregar as variaveis de filial, projeto e revisao do registro a partir do array automatico

@param cFili, caracter, Recebera a filial do registro
@param cProjet, caracter, recebera o projeto do registro
@param cRevisa, caracter, recebera a revisão do registro
@param aGetcPos, array, com os campos a serem alterados
@param cAlias, caracter, Alias da tabela

@return Nil

@author Jandir Deodato
@since 29/01/2013
@version MP11.80
*/
//-------------------------------------------------------------------

Function PMSGetCHV(cFili,cProjet,cRevisa,aGetCpos,cAlias)
Local nPosCod	:=0
Local aArea:=GetArea()
Local aAreaAF8:={}
DbSelectArea("AF8")
aAreaAF8:=AF8->(getArea())
AF8->(dbSetOrder(1))//filial+projeto
If (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == (cAlias+'_FILIAL')}))>0
	cFili:=Padr(aGetCpos[nPosCod][2],Tamsx3((cAlias+'_FILIAL'))[1])
Endif
If (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == (cAlias+'_PROJET')}))>0
	cProjet:=Padr(aGetCpos[nPosCod][2],Tamsx3((cAlias+'_PROJET'))[1])
Endif
If AF8->(DbSeek(cFili+cProjet))
	cRevisa:=AF8->AF8_REVISA
Endif

RestArea(aAreaAF8)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} PmsRatPrj
	Função que verifica se o existe rateio de projeto para o título


	@param cAlias, caracter, Alias da tabela de busca
	@Param cfili, caracter, Filial da busca
	@param cPrefix, caracter, Prefixo do titulo
	@param cNum, caracter, numero do título
	@param cParcel, caracter, Parcela do titulo
	@param cTipo, caracter, Tipo do titulo
	@param cFornece, caracter, Fornecedor do titulo
	@param cLoja, caracter, Loja do titulo
	@param aRateios, array, array que recebera os rateios do projeto

	@return lRet, logico, Verdadeiro se existe rateio

	@author	Jandir Deodato
	@version	P11
	@since	06/02/2013
*/
//-------------------------------------------------------------------

Function PmsRatPrj(cAlias,cfili,cPrefix,cNum,cParcel,cTipo,cFornece,cLoja,aRateios)

Local aArea :=GetArea()
Local aAreaAux
Local aAreaAF8
Local lRet:=.F.
Default cAlias:=''
Default aRateios:=nil
dbSelectArea('AF8')
aAreaAF8:=AF8->(GetArea())
AF8->(DbSetOrder(1))//Filial+projeto

If Upper(AllTrim(cAlias))=="SE2"
	Default cFili := xFilial("AFR")
Else
	Default cFili:= xFilial("AFT")
Endif
Default cFornece:=''
Default cLoja:=''

Do Case
	Case Upper(AllTrim(cAlias))=="SE2"
		DbSelectArea("AFR")
		aAreaAux:=AFR->(GetArea())
		AFR->(dbSetOrder(2))//AFR_FILIAL+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA+AFR_PROJET+AFR_REVISA+AFR_TAREFA
		IF AFR->(dbSeek(cFili+cPrefix+cNum+cParcel+cTipo+cFornece+cLoja))
			While AFR->(!EOF()) .and. cfili == AFR->AFR_FILIAL .and. cPrefix==AFR->AFR_PREFIX .and. cNum==AFR->AFR_NUM .and. cParcel==AFR->AFR_PARCEL .and.;
			cTipo==AFR->AFR_TIPO .and. cFornece==AFR->AFR_FORNECE .and. cLoja==AFR->AFR_LOJA
				AF8->(MsSeek(xFilial("AF8")+AFR->AFR_PROJET))
				If AF8->AF8_REVISA==AFR->AFR_REVISA
					lREt:=.T.
					IF !ValType(aRateios)=="A" //nao carrega o array, pode sair
						Exit
					Endif
					aadd(aRateios,{{"AFR_PROJET",AFR->AFR_PROJET,nil},{"AFR_TAREFA",AFR->AFR_TAREFA,nil},{"AFR_TIPOD",AFR->AFR_TIPOD,nil},{"AFR_VALOR1",AFR->AFR_VALOR1,nil},{"AFR_REVISA",AFR->AFR_REVISA,nil}})
					AFR->(dbSkip())
				Else
					AFR->(dbSkip())
				Endif
			End
		Endif
		RestArea(aAreaAux)
	Case Upper(AllTrim(cAlias))=="SE1"
		DbSelectArea("AFT")
		aAreaAux:=AFT->(GetArea())
		AFT->(dbSetOrder(2))//AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA+AFT_PROJET+AFT_REVISA+AFT_TAREFA
		IF AFT->(dbSeek(cFili+cPrefix+cNum+cParcel+cTipo))
			While AFT->(!EOF()) .and. cfili == AFT->AFT_FILIAL .and. cPrefix==AFT->AFT_PREFIX .and. cNum==AFT->AFT_NUM .and. cParcel==AFT->AFT_PARCEL .and.;
			cTipo==AFT->AFT_TIPO
				AF8->(MsSeek(xFilial("AF8")+AFT->AFT_PROJET))
				If AF8->AF8_REVISA==AFT->AFT_REVISA
					lREt:=.T.
					IF !ValType(aRateios)=="A" //nao carrega o array, pode sair
						Exit
					Endif
					aadd(aRateios,{{"AFT_PROJET",AFT->AFT_PROJET,nil},{"AFT_TAREFA",AFT->AFT_TAREFA,nil},{"AFT_TIPOD",AFT->AFT_TIPOD,nil},{"AFT_VALOR1",AFT->AFT_VALOR1,nil},{"AFT_REVISA",AFT->AFT_REVISA,nil}})
					AFT->(dbSkip())
				Else
					AFT->(dbSkip())
				Endif
			End
		Endif
		RestArea(aAreaAux)
EndCase
RestArea(aAreaAF8)
RestArea(aArea)
Return lRet



//-------------------------------------------------------------------
/*{Protheus.doc} PmsRetCust
	Função que retorna o custo médio ou previsto das tarefas de um projeto

	@param cProjeto, caracter,	Projeto que se deseja buscar o custo
	@param cTarefa, caracter,	Tarefa que se deseja buscar o custo
	@param dDataRef, date, Data de referencia do custo - Opcional - Default dDataBase
	@param nOpc, numerico, Opção de custo: 1-custo médio, 2-custo previsto - Opcional - Default 1
	@param nMoeda, numerico, Moeda do custo - Opcional - Default 1

	@return nCusto, numerico, Custo na moeda desejada

	@author	Jandir Deodato
	@version	P11
	@since	25/03/2013
*/
//-------------------------------------------------------------------


Function PmsRetCust(cProjeto,cTarefa,dDataRef,nOpc,nMoeda)//Retorna os custos reais ou previstos do projeto

Local aAuxCusto:={}
Local nCusto:=0
local cRevisa:=''
Local aArea:=GetArea()
Local aAreaAF8:={}
Local aAreaAF9:={}
Local lRet:=.T.
Default dDataRef:=dDataBase
Default nOpc:=1 // custo real
Default cProjeto:=''
Default cTarefa:=''
Default nMoeda:=1

dbSelectArea('AF8')
aAReaAF8:=AF8->(GetArea())
AF8->(dbSetOrder(1))//Filial+Projeto
dbSelectArea('AF9')
aAreaAF9:=AF9->(GetArea())
AF9->(dbSetOrder(1))//Filial+Projeto+revisao+tarefa
If nMoeda < 6
	cProjeto:=Padr(cProjeto,TamSx3('AF8_PROJET')[1])
	cTarefa:=Padr(cTarefa,TamSx3('AF9_TAREFA')[1])
	If !Empty (cProjeto) .and. !Empty(cTarefa)
		If AF8->(dbSeek(xFilial('AF8')+cProjeto))
			cRevisa:=AF8->AF8_REVISA
			If !AF9->(dbSeek(xFilial('AF9')+cProjeto+cRevisa+cTarefa))
				lRet:=.F.
			Endif
		Else
			lRet:=.F.
		Endif
	Else
		lRet:=.F.
	Endif
	If lRet
		Do Case
			Case nOpc==1 // custo real
				aAuxCusto := PmsIniCRTE(cProjeto,cRevisa,dDataRef,cTarefa,cTarefa)
				nCusto := PmsRetCRTE(aAuxCusto,1,cTarefa)[nMoeda]
			Case nOpc==2//previsto
				aAuxCusto := PmsIniCOTP(cProjeto,cRevisa,dDataRef,cTarefa,cTarefa)
				nCusto	  := PmsRetCOTP(aAuxCusto,1,cTarefa)[nMoeda]
		EndCase
	Endif
Endif
RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aArea)
Return nCusto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSVldTrPr ³ Autor ³ Rodrigo M. Pontes    ³ Data ³ 11-09-2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função para validar se o projeto ou tarefa pode ser alterado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³PMSXFUN                           							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSVldTrPr()

Local lRet			:= .T.
Local cNumSA		:= PadR(AllTrim(SCP->CP_NUM),TamSx3("CP_NUM")[1])
Local cMsgAlert	:= STR0150 //"Solicitação de armazem já vinculada a um projeto/tarefa via TOP e não pode ser alterada."
Local cIntegracao	:= SuperGetMv("MV_INTPMS")
Local aArea		:= GetArea()

If cIntegracao == "S"
	//Solicitação de Armazem e Baixa pré-requis
	If AllTrim(FunName()) == "MATA105" .Or. AllTrim(FunName()) == "MATA185"
		DbSelectArea("AFH")
		AFH->(DbSetOrder(2))
		If AFH->(DbSeek(xFilial("AFH") + cNumSA))
			If AllTrim(ReadVar()) == "M->AFH_PROJET"
				If ExistCpo("AF8")
					If AllTrim(&(ReadVar())) <> AllTrim(AFH->AFH_PROJET) .And. AllTrim(AFH->AFH_VIAINT) == "S" //Veio da integração com o TOP
						MsgAlert(cMsgAlert)
						lRet := .F.
					Endif
				Else
					lRet := .F.
				Endif
			Elseif AllTrim(ReadVar()) == "M->AFH_TAREFA"
				If AllTrim(&(ReadVar())) <> AllTrim(AFH->AFH_TAREFA) .And. AllTrim(AFH->AFH_VIAINT) == "S" //Veio da integração com o TOP
					MsgAlert(cMsgAlert)
					lRet := .F.
				Endif
			Elseif AllTrim(ReadVar()) == "M->D3_PROJPMS"
				If AllTrim(&(ReadVar())) <> AllTrim(AFH->AFH_PROJET) .And. AllTrim(AFH->AFH_VIAINT) == "S" //Veio da integração com o TOP
					MsgAlert(cMsgAlert)
					lRet := .F.
				Endif
			Elseif AllTrim(ReadVar()) == "M->D3_TASKPMS"
				If AllTrim(&(ReadVar())) <> AllTrim(AFH->AFH_TAREFA) .And. AllTrim(AFH->AFH_VIAINT) == "S" //Veio da integração com o TOP
					MsgAlert(cMsgAlert)
					lRet := .F.
				Endif
			Endif
		Endif
	Endif
Endif

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSLoadSH7ºAutor  ³Clovis Magenta      º Data ³  13/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que realiza a carga inicial dos dados na tabela AEG º±±
±±º          ³ e tambem realiza as atualizações, conforme SH7             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSLoadSH7(cCalendario)
Local aDatas 	:= {}
Local nTotQuant	:= 0
Local nCount	:= 1
Local nBuffer	:= 0
Local nItem		:= 1
Local nPrecisao	:= ( 60 / SuperGetMV("MV_PRECISA") )
Local bWhile	:= {|| .T.}

DEFAULT cCalendario := ""

If Empty(cCalendario)
	bWhile:= {|| SH7->(!EOF()) }
	dbSelectArea("SH7")
	SH7->(DbGoTop())
Else
	bWhile:= {|| SH7->H7_CODIGO == cCalendario }
	dbSelectArea("SH7")
Endif

dbselectArea("AEG")
dbSetOrder(3) // AEG_FILIAL+AEG_CODIGO+AEG_TIPO+str(aeg_semana)

Begin Transaction

While Eval(bWhile)

	aDatas := AEGCalend(SH7->H7_CODIGO)

 	For nCount:=1 to Len(aDatas)
		nTotQuant 	:= Len(aDatas[nCount])-1
		nGravado 	:= 1
		nItem		:= 1
		lDiaSemTrb := (nTotQuant==0)

		If !dbSeek(xFilial("AEG")+SH7->H7_CODIGO+"C"+Alltrim(STR(aDatas[nCount][1])))

			While (nGravado <= nTotQuant) .or. (lDiaSemTrb)

				nBuffer++
				RecLock("AEG",.T.)
				AEG_FILIAL	:= xFilial("AEG")
				AEG_CODIGO	:= SH7->H7_CODIGO
				AEG_ITEM	:= STRZERO(nItem,3)
				AEG_SEMANA	:= aDatas[nCount][1]
				If lDiaSemTrb
					AEG_HORAI 	:= '00:00'
					AEG_HORAF 	:= '00:00'
					AEG_HUTEIS	:= 0
					lDiaSemTrb := !lDiaSemTrb
				Else
					AEG_HORAI 	:= aDatas[nCount][nGravado+1]
					AEG_HORAF 	:= aDatas[nCount][nGravado+2]
					AEG_HUTEIS	:= ABS(PMSTimeDiff( "00"+aDatas[nCount][nGravado+2] , "00"+aDatas[nCount][nGravado+1] ))
				Endif
				AEG_PRECIS  := nPrecisao
				AEG_TIPO	:= "C"

				nItem++
				nGravado += 2

				If nBuffer > 1000
					nBuffer	:= 0
					AEG->( MsUnlockAll() )
				Endif

				Loop
			EndDo

		Endif

	Next nCount

	SH7->(DbSkip())
EndDo

If (nBuffer <> 0)
	AEG->( MsUnlockAll() )
Endif

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AEGCalend ºAutor  ³Clovis Magenta      º Data ³  12/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adaptação da função A690Calend() existente no MATA690A.     º±±
±±º          ³Retorna todas os ranges de horas trabalhadas para AEG.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AEGCalend(cCalend)
Local nTamanho
Local cAloc, x, y
Local aArray 	:= {}, aRet := {}
Local cAlias  	:= Alias()
Local nRecSH7 	:= SH7->(RecNo())
Local cHoraFim	:= ""
Local nTotHrs	:=0

dbSelectArea("SH7")
If ! dbSeek(xFilial("SH7")+cCalend)
	dbGoto(nRecSH7)
	dbSelectArea(cAlias)
	Return(aArray)
Endif

cAloc    := Upper(SH7->H7_ALOC)
nTamanho := Len(cAloc) / 7
Aadd(aArray, "")

While Len(cAloc) > 0
	Aadd(aArray, SubStr(cAloc, 1, nTamanho) + " ")
	cAloc := SubStr(cAloc, nTamanho + 1)
Enddo

aArray[1] := aArray[8]
aDel(aArray, 8)
aSize(aArray, 7)
For x := 1 to Len(aArray)

	If nTotHrs <> 0
		Aadd(aRet[Len(aRet)], nTotHrs)
	Endif

	nPos1 	:= 0
	nPos2 	:= 0
	nTotHrs	:= 0
	Aadd(aRet, {x})

	For y := 1 to Len(aArray[x])
		If substr(aArray[x], y, 1) == "X" .and. nPos1 = 0
			nPos1 := y
		ElseIf substr(aArray[x], y, 1) == " " .And. nPos1 # 0
			nPos2 := y
			If Len(aRet[Len(aRet)]) < 16
				Aadd(aRet[Len(aRet)], Substr(Bit2Tempo(nPos1-1),3))
				cHoraFim := SubStr(Bit2Tempo(nPos2-1), 3) + ":00"
				cHoraFim := A690Sec2Time(Secs(cHoraFim))
				Aadd(aRet[Len(aRet)], Substr(cHoraFim,3))
			Endif
			nPos1 := 0
		Endif
	Next y

Next x
dbGoto(nRecSH7)
dbSelectArea(cAlias)
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PMSDelSH7³ Autor ³ Clovis Magenta        ³ Data ³ 13/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta todos os itens do calendario escolhido(AEG)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = 3: INCLUSAO										  ³±±
±±³          ³         4: ALTERACAO										  ³±±
±±³          ³         5: EXCLUSAO										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA780 - CADASTRO DE CALENDARIO PCP          			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSDelSH7(cCalendario)
Local cQuery	:= ""
Local cRet		:= ""
Local cFilAEG 	:= xFilial('AEG')
Local aArea		:= GetARea()

cQuery	:= "DELETE "+RetSqlName("AEG")
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalendario+"' "

cRet:=TcSQLExec(cQuery)

If cRet <> 0
	If !IsBlind()
		MsgAlert('Err:' + TCSqlError() )  //'Erro criando a Stored Procedure:'
		conout('SQL Error')
		conout("Err:"+MsParseError() )
	Endif
Endif

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PmsGrvAEG³ Autor ³ Clovis Magenta        ³ Data ³ 12/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza nova tabela de calendario do SIGAPMS (AEG)        ³±±
±±³          ³ de acordo com o calendário antigo, SH7.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = 3: INCLUSAO										  ³±±
±±³          ³         4: ALTERACAO										  ³±±
±±³          ³         5: EXCLUSAO										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA780 - CADASTRO DE CALENDARIO PCP          			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsGrvAEG(nOpcao,cCalend)
Local aArea := GetARea()

Do Case
	Case nOpcao == 3
		PMSLoadSH7(cCalend)
	Case nOpcao == 4
		PMSDelSH7(cCalend)
		PMSLoadSH7(cCalend)
	Case nOpcao == 5
		PMSDelSH7(cCalend)
EndCase
RestARea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSLoadAFYºAutor  ³Clovis Magenta      º Data ³  13/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que realiza a carga inicial dos dados na tabela AEG º±±
±±º          ³ e tambem realiza as atualizações, conforme AFY             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSLoadAFY(cExcecao)
Local aDatas 	:= {}
Local nTotQuant	:= 0
Local nCount	:= 1
Local nBuffer	:= 0
Local nItem		:= 1
Local nPrecisao	:= ( 60 / SuperGetMV("MV_PRECISA") )
Local bWhile	:= {|| .T.}
Local nRecno	:= 0
Local lPos_MALOC:= AFY->(ColumnPos("AFY_MALOC")) > 0
Local nTamItem	:= TAMSX3("AEG_ITEM")[1]
Local aArea		:= GetARea()
DEFAULT cExcecao := ""

If !lPos_MALOC
	Return
Endif

If Empty(cExcecao)
	bWhile:= {|| AFY->(!EOF()) }
	dbSelectArea("AFY")
	AFY->(DbGoTop())
Else
	nItem := Val(PmsAEGItem())
	nRecno := AFY->(Recno())
	bWhile:= {|| AFY->(Recno()) == nRecno }
	dbSelectArea("AFY")
Endif

dbselectArea("AEG")
dbSetOrder(4) // 'AEG_FILIAL+AEG_CODIGO+AEG_TIPO+DTOS(AEG_DATAI)+AEG_RECURS+AEG_PROJET'

Begin Transaction

While Eval(bWhile)

	aDatas := AFYCalend( AFY->AFY_MALOC )

	For nCount:=1 to Len(aDatas)
		nTotQuant 	:= Len(aDatas[nCount])-1
		nGravado 	:= 1
		lDiaSemTrb := (nTotQuant==0)

		If !dbSeek(xFilial("AEG")+"AFY"+"E"+DtoS(AFY->AFY_DATA)+AFY->AFY_RECURS+AFY->AFY_PROJET)

			While (nGravado <= nTotQuant) .or. (lDiaSemTrb)
				nBuffer++

				RecLock("AEG",.T.)
				AEG_FILIAL	:= xFilial("AEG")
				AEG_CODIGO	:= "AFY"
				AEG_ITEM	:= STRZERO(nItem,nTamItem)
				AEG_SEMANA	:= aDatas[nCount][1]
				If lDiaSemTrb
					AEG_HORAI 	:= '00:00'
					AEG_HORAF 	:= '00:00'
					AEG_HUTEIS	:= 0
					lDiaSemTrb := !lDiaSemTrb
				Else
					AEG_HORAI 	:= aDatas[nCount][nGravado+1]
					AEG_HORAF 	:= aDatas[nCount][nGravado+2]
					AEG_HUTEIS	:= ABS(PMSTimeDiff( "00"+aDatas[nCount][nGravado+2] , "00"+aDatas[nCount][nGravado+1] ))
				Endif
				AEG_PRECIS  := nPrecisao
				AEG_TIPO	:= "E"

				AEG_PROJET	:= AFY->AFY_PROJET
				AEG_RECURS	:= AFY->AFY_RECURS
				AEG_DATAI	:= AFY->AFY_DATA
				AEG_DATAF	:= AFY->AFY_DATAF

				nItem++
				nGravado += 2

				If nBuffer > 1000
					nBuffer	:= 0
					AEG->( MsUnlockAll() )
				Endif

				Loop
			EndDo

		Endif
	Next nCount

	AFY->(DbSkip())
EndDo

If (nBuffer <> 0)
	AEG->( MsUnlockAll() )
Endif

End Transaction

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AEGCalend ºAutor  ³Clovis Magenta      º Data ³  12/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adaptação da função A690Calend() existente no MATA690A.     º±±
±±º          ³Retorna todas os ranges de horas trabalhadas para AEG.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFYCalend(cAloc)
Local nTamanho
Local x, y
Local aArray 	:= {}
Local aRet 		:= {}
Local aArea		:= GetArea()
Local aAreaAFY	:= AFY->(GetArea())
Local cHoraFim	:= ""
Local nTotHrs	:=0

cAloc    := STRTran(cAloc,"X" ,"x")

nTamanho := Len(cAloc)

While Len(cAloc) > 0
	Aadd(aArray, SubStr(cAloc, 1, nTamanho) + " ")
	cAloc := SubStr(cAloc, nTamanho + 1)
Enddo

//aArray[1] := aArray[8]
//aDel(aArray, 8)
aSize(aArray, 1)

For x := 1 to Len(aArray)

	If nTotHrs <> 0
		Aadd(aRet[Len(aRet)], nTotHrs)
	Endif

	nPos1 	:= 0
	nPos2 	:= 0
	nTotHrs	:= 0

	Aadd(aRet, {x})

	For y := 1 to Len(aArray[x])
		If substr(aArray[x], y, 1) == "x" .and. nPos1 = 0
			nPos1 := y
		ElseIf substr(aArray[x], y, 1) == " " .And. nPos1 # 0
			nPos2 := y
			If Len(aRet[Len(aRet)]) < 16
				Aadd(aRet[Len(aRet)], Substr(Bit2Tempo(nPos1-1),3))
				cHoraFim := SubStr(Bit2Tempo(nPos2-1), 3) + ":00"
				cHoraFim := A690Sec2Time(Secs(cHoraFim))
				Aadd(aRet[Len(aRet)], Substr(cHoraFim,3))
			Endif
			nPos1 := 0
		Endif
	Next y

Next x

RestArea(aAreaAFY)
RestArea(aArea)

Return(aRet)

Function PmsAEGItem()
Local cQuery	:= ""
Local cFilAEG 	:= xFilial('AEG')
Local nItem		:= 0
Local cAliasAEG	:= "cAliasAEG"

cQuery	:= "SELECT MAX(AEG_ITEM) AEG_ITEM FROM "+RetSqlName("AEG")
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = 'AFY' "

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasAEG, .T., .T. )

(cAliasAEG)->(DbGoTop())
If (cAliasAEG)->(!EOF())
	nItem := (cAliasAEG)->(AEG_ITEM)
Endif

(cAliasAEG)->(dbCloseArea())

Return Soma1(nItem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PMSDelSH7³ Autor ³ Clovis Magenta        ³ Data ³ 13/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta todos os itens do calendario escolhido(AEG)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = 3: INCLUSAO										  ³±±
±±³          ³         4: ALTERACAO										  ³±±
±±³          ³         5: EXCLUSAO										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA780 - CADASTRO DE CALENDARIO PCP          			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSDelAFY(dDataI, cProjeto, cRecurso)
Local cQuery	:= ""
Local cRet		:= ""
Local cFilAEG 	:= xFilial('AEG')
Local aArea		:= GetArea()

cQuery	:= "DELETE "+RetSqlName("AEG")
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = 'AFY' "
cQuery	+= " AND AEG_DATAI = '"+DtoS(dDataI)+"' AND AEG_PROJET = '"+cProjeto+"' AND AEG_RECURS = '"+cRecurso+"' "

cRet:=TcSQLExec(cQuery)

If cRet <> 0
	If !IsBlind()
		MsgAlert('Err:' + TCSqlError() )  //'Erro criando a Stored Procedure:'
		conout('SQL Error')
		conout("Err:"+MsParseError() )
	Endif
Endif

RestArea(aArea)
Return

/*/{Protheus.doc} PMSDtFim

Calcula a data e Hora Final da tarefa a partir da Hora Inicial.
Função desenvolvida em SUBSTITUICAO DA FUNCAO PMSDTaskF() para calculos baseados na tabela AEG.

@param dStart, data, data de inicio do periodo (DD/MM/YYYY)
@param cHorai, character, hora de inicio do periodo (HH:MM)
@param cCalend, caracter, Calendario a ser considerado no calculo
@param nDurHrs, numerico, Duração do periodo
@param cProjet, caracter, Codigo do projeto envolvido
@param cRecurso, caracter, Codigo do recurso envolvido
@param cDtIniPred, data, data de inicio da tarefa predecessora
@param cHrIniPred, caracter, hora de inicio da tarefa predecessora
@param lMsg, booleana, (Não usado)

@return array, contem o periodo calculado
				[1] - data de inicio
				[2] - hora de inicio
				[3] - data de fim
				[4] - hora de fim

@obs:
Função Original:	PMSDTaskF(dStart,cHoraIni,cCalend,nDuracao,cProjeto,cRecurso,dStartArq,cHoraIniArq,lMsg)
Chamada Original:	PMSDTaskF(M->AF9_START,M->AF9_HORAI,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)

@author clovism
@since 07-03-2014
@version 1.0

/*/
FUNCTION PMSDtFim(dStart, cHorai, cCalend, nDurHrs, cProjet, cRecurso, cDtIniPred, cHrIniPred, lMsg)

Local aArea		:= GetArea()
Local aAreaAEG	:= {}
Local aDadosExc	:= {}
Local cQuery		:= ""
Local cHoraIni	:= ""
Local cHoraFim	:= ""
Local cDataIni	:= ""
Local cDataFim	:= ""
Local cAliasAEG	:= ""
Local cAlias		:= ""
Local cQuery2		:= ""
Local cQryHrsUts	:= ""
Local cQryFim		:= ""
Local cAliasITVL	:= ""
Local cFilAEG		:= xFilial('AEG')
Local nPrecisao	:= 0
Local nMinuts		:= 0
Local nPerc		:= 0
Local nValAdd		:= 0
Local nDOW			:= 0
Local nDuracao	:= nDurHrs
Local lFirst		:= .T.

DEFAULT cProjet	:= ""
DEFAULT cRecurso	:= ""
DEFAULT lMsg		:= .T.
DEFAULT cDtIniPred:= dStart
DEFAULT cHrIniPred:=	cHoraIni
DEFAULT lNewCalend:= SuperGetMv("MV_PMSCALE" , .T. , .F. )

dbSelectArea("AEG")
aAreaAEG:= AEG->(GetArea())
dbSetOrder(1) // 'AEG_FILIAL+AEG_CODIGO+AEG_TIPO+AEG_PROJET'
If MsSeek(xFilial("AEG")+cCalend+"C" )

	cAlias		:= "CALF"+GetNextAlias()
	cQuery2	:= "CALF"+GetNextAlias()
	cQryHrsUts	:= "CALF"+GetNextAlias()
	cQryFim	:= "CALF"+GetNextAlias()
	cAliasITVL	:= "ITV1"+GetNextAlias()
	cAliasAEG	:= RetSqlName("AEG")

	dStart	:= If(Empty(dStart),dDataBase+1,dStart)
	nDOW	:= Dow(dStart)

	//³Se o fim da predecessora eh na mesma data que o inicio informado no cadastro,³
	//³a hora de inicio deve ser a maior entre o fim da predecessora e o inicio in- ³
	//³formado no cadastro.															³
	If dStart == cDtIniPred
		cHoraIni := If(cHoraI>cHrIniPred,cHoraI,cHrIniPred)
	//³Se o fim da predecessora eh anterior a data de inicio informado no cadastro, ³
	//³a data e hora de inicio devem ser as informadas no cadastro.					³
	ElseIf dStart < cDtIniPred
		dStart	:= cDtIniPred
		cHoraI	:= cHrIniPred
	Endif

	// Horas Uteis do calendário escolhido
	cQuery	:= "SELECT SUM(AEG_HUTEIS) HRS_UTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

	// Horas do dia da semana da data Início
	cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_SEMANA, AEG_PRECIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY AEG_SEMANA , AEG_ITEM "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasITVL , .T. , .T. )

	// Horas do dia da semana da data Início
	cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_HUTEIS, AEG_PRECIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery	+= " AND AEG_SEMANA = "+STR(nDOW)
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQuery2 , .T. , .T. )

	nPrecisao	:= (cQuery2)->(AEG_PRECIS)

	// Horas uteis por dia da semana
	cQuery	:= "SELECT MIN(AEG_HORAI) AEG_HORAI, MAX(AEG_HORAF) AEG_HORAF, AEG_SEMANA, SUM(AEG_HUTEIS) HRSUTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " GROUP BY AEG_SEMANA"
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryHrsUts , .T. , .T. )

	(cQuery2)->(dbGoTop())

	// Garante posicionar no primeiro dia da semana com horas uteis
	While (cQuery2)->(AEG_HUTEIS) == 0
		(cQuery2)->(dbCloseArea())
		cQuery2	:= GetNextAlias()
		dStart++
		nDOW++
		If nDow > 7
			nDow := 1
		Endif
		// Datas e horas do dia da semana do dia Início
		cQuery	:= "SELECT AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
		cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
		cQuery 	+= " AND AEG_TIPO = 'C'"
		cQuery	+= " AND AEG_SEMANA = "+STR(nDOW)
		cQuery	+= " AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQuery2 , .T. , .T. )

		Loop
	EndDo

	While (cQryHrsUts)->( AEG_SEMANA ) <> nDow
		(cQryHrsUts)->( dbSkip() )
		If (cQryHrsUts)->( EOF() )
			(cQryHrsUts)->( dbGoTop() )
		Endif
		Loop
	EndDo

	//########################################################//
	//***************** Parte do cálculo *********************//
	//########################################################//
	If Empty(cHoraIni)
		cHoraIni := (cQuery2)->(AEG_HORAI)
	ElseIf (cHorai >= (cQuery2)->(AEG_HORAI))
		cHoraIni := cHorai
	Else
		cHoraIni := (cQuery2)->(AEG_HORAI)
	Endif

	cDataIni := dStart
	cDataFim := dStart

	If nDuracao==0
		cHoraFim := cHoraIni
	ElseIf ( (cQryHrsUts)->(HRSUTEIS) >= nDuracao ) .and. ( (cQryHrsUts)->(AEG_HORAF) != cHoraIni )
		cQuery	:= "SELECT AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
		cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
		cQuery	+= " AND AEG_SEMANA = "+STR( (cQryHrsUts)->(AEG_SEMANA) )
		cQuery 	+= " AND AEG_TIPO = 'C'"
		cQuery	+= " AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryFim , .T. , .T. )
		While (cQryFim)->(!EOF())

			If lFirst .AND. ( PmsHrUtil(cDataIni,cHoraIni,cHoraFim,cCalend,{},cProjet) < nDuracao ) // vemos se ate o final do dia temos horas uteis suficientes para esta duracao
				If (cQryHrsUts)->(AEG_HORAI) < cHoraIni
					nDuracao	+=  PMSTimeDiff(  "00"+cHoraIni , "00"+ (cQryHrsUts)->(AEG_HORAI) )
				ElseIf  (cQryHrsUts)->(AEG_HORAF) < cHoraIni
					(cQryFim)->(dbSkip())
					Loop
				Endif
			EndIf

			If nDuracao > (cQryFim)->(AEG_HUTEIS) // Se ainda precisamos de mais horas

				nDuracao -= (cQryFim)->(AEG_HUTEIS)

			ElseIf nDuracao == (cQryFim)->(AEG_HUTEIS) // Se este período é exatamento do que precisamos

				nDuracao -= (cQryFim)->(AEG_HUTEIS)
				cHoraFim := (cQryFim)->(AEG_HORAF)
				Exit

			Else

				nDuracao 	:= nDuracao * 3600 // Quantos Minutos a partir da HORA INICIAL
				cHoraFim 	:= A690Sec2Time(Secs((cQryFim)->(AEG_HORAI)) + nDuracao)
				cHoraFim 	:= Substr(cHoraFim,3)
				Exit

			Endif
			lFirst := .F.
			(cQryFim)->(dbSkip())
		EndDo

		If nDuracao > 0 // sobrou residuo para outro dia
			cDataFim++
			While (cQryHrsUts)->( AEG_SEMANA ) <> Iif( nDow+1==8, 1, nDow+1)
				(cQryHrsUts)->( dbSkip() )
				If (cQryHrsUts)->( EOF() )
					(cQryHrsUts)->( dbGoTop() )
				Endif
				Loop
			EndDo
			If Select(cQryFim)>0
				(cQryFim)->(DbCloseArea())
			Endif
			cQuery	:= "SELECT AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
			cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
			cQuery	+= " AND AEG_SEMANA = "+STR( (cQryHrsUts)->(AEG_SEMANA) )
			cQuery 	+= " AND AEG_TIPO = 'C'"
			cQuery	+= " AND D_E_L_E_T_ = ' ' "
			dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryFim , .T. , .T. )

			While (cQryFim)->(!EOF())

				If nDuracao > (cQryFim)->(AEG_HUTEIS) // Se ainda precisamos de mais horas

					nDuracao -= (cQryFim)->(AEG_HUTEIS)

				ElseIf nDuracao == (cQryFim)->(AEG_HUTEIS) // Se este período é exatamento do que precisamos

					nDuracao -= (cQryFim)->(AEG_HUTEIS)
					cHoraFim := (cQryFim)->(AEG_HORAF)
					Exit

				Else

					nDuracao 	:= nDuracao * 3600 // Quantos Minutos a partir da HORA INICIAL
					cHoraFim 	:= A690Sec2Time(Secs((cQryFim)->(AEG_HORAI)) + nDuracao)
					cHoraFim 	:= Substr(cHoraFim,3)
					Exit

				Endif

				(cQryFim)->(dbSkip())
			EndDo

		Endif
	Else
		nDuracao -= GetFirstDay(	cDataIni, cHoraIni, cProjet, cRecurso, cQryHrsUts, cAliasITVL)
		If (cQryHrsUts)->( EOF() )
			(cQryHrsUts)->( dbGoTop() )
		Else
			(cQryHrsUts)->( dbSkip() )
			If (cQryHrsUts)->( EOF() )
				(cQryHrsUts)->( dbGoTop() )
			Endif
		Endif
		cDataFim++

		While nDuracao > 0

			If (cQryHrsUts)->(HRSUTEIS) >= nDuracao
				Exit
			Endif
			aDadosExc	:= PmsAEGExc( {cDataFim,cDataFim} , cProjet, cRecurso, cQryHrsUts, .F.,.T.)

			If aDadosExc[1, 7]
				nDuracao -= aDadosExc[1, 1]
			Else
				nDuracao -= aDadosExc[1, 8]
			Endif
			cDataFim++

			If (cQryHrsUts)->( EOF() )
				(cQryHrsUts)->( dbGoTop() )
				Loop
			Else
				(cQryHrsUts)->( dbSkip() )
				If (cQryHrsUts)->( EOF() )
					(cQryHrsUts)->( dbGoTop() )
				Endif
				Loop
			Endif

		EndDo

		If nDuracao > 0
			cQuery	:= "SELECT AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
			cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
			cQuery	+= " AND AEG_SEMANA = "+STR( (cQryHrsUts)->(AEG_SEMANA) )
			cQuery 	+= " AND AEG_TIPO = 'C'"
			cQuery	+= " AND D_E_L_E_T_ = ' ' "
			dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryFim , .T. , .T. )

			While (cQryFim)->(!EOF())

				If nDuracao > (cQryFim)->(AEG_HUTEIS) // Se ainda precisamos de mais horas

					nDuracao -= (cQryFim)->(AEG_HUTEIS)

				ElseIf nDuracao == (cQryFim)->(AEG_HUTEIS) // Se este período é exatamento do que precisamos

					nDuracao -= (cQryFim)->(AEG_HUTEIS)
					cHoraFim := (cQryFim)->(AEG_HORAF)
					Exit

				Else

					nDuracao 	:= nDuracao * 3600 // Quantos Minutos a partir da HORA INICIAL
					cHoraFim 	:= A690Sec2Time(Secs((cQryFim)->(AEG_HORAI)) + nDuracao)
					cHoraFim 	:= Substr(cHoraFim,3)
					Exit

				Endif

				(cQryFim)->(dbSkip())
			EndDo
		Endif
	Endif

	(cAliasITVL)->(DbCloseArea())
	(cAlias)->(DbCloseArea())
	(cQryHrsUts)->(DbCloseArea())
	(cQuery2)->(DbCloseArea())

	If Select(cQryFim)>0
		(cQryFim)->(DbCloseArea())
	Endif

	/********* Tratamento do MV_PRECISA *********/
	nMinuts	:= Val(Substr(cHoraIni,4,2))
	If ( nMinuts%nPrecisao ) <> 0  // se resto da divisao for diferente de zero
		nPerc := (nMinuts/nPrecisao)
		nValAdd	:= Round(nPerc,0)-nPerc
		If nValAdd <> nPrecisao
			nMinuts += (nValAdd*nPrecisao)
		Endif
		cHoraIni := Substr(cHoraIni,1,3)+StrZero(nMinuts,2)
	Endif

	nMinuts	:= Val(Substr(cHoraFim,4,2))
	If ( nMinuts%nPrecisao ) <> 0  // se resto da divisao for diferente de zero
		nPerc := (nMinuts/nPrecisao)
		nValAdd	:= Round(nPerc,0)-nPerc
		If nValAdd <> nPrecisao
			nMinuts += (nValAdd*nPrecisao)
		Endif
		cHoraFim := Substr(cHoraFim,1,3)+ StrZero(nMinuts,2)
	Endif

Else
	Alert(STR0158+cCalend+STR0159) //"Calendário " - " não cadastrado na tabela AEG. Favor Verificar"
Endif

restArea(aAreaAEG)
RestArea(aArea)
Return {cDataIni, cHoraIni, cDataFim, cHoraFim}



/* SUBSTITUICAO DA FUNCAO PMSDTaskI()
Função Original:	PMSDTaskI(dFinish,cHoraFim,cCalend,nDuracao,cProjeto,cRecurso)
Chamada Original:	PMSDTaskI(M->AF9_FINISH,M->AF9_HORAF,M->AF9_CALEND,@M->AF9_HDURAC,M->AF9_PROJET,Nil)
Retorno	: 			aAuxRet
					M->AF9_START := aAuxRet[1]
					M->AF9_HORAI := aAuxRet[2]
					M->AF9_FINISH:= aAuxRet[3]
					M->AF9_HORAF := aAuxRet[4]
*/
FUNCTION PMSDtIni(dFinish, cHoraf, cCalend, nDurHrs, cProjet, cRecurso)
Local aArea		:= GetArea()
Local aDadosExc	:= {}

Local cQuery	:= ""
Local cHoraIni	:= ""
Local cHoraFim	:= ""
Local cDataIni	:= ""
Local cDataFim	:= ""
Local cAliasAEG	:= RetSqlName("AEG")
Local cAlias	:= "CALI"+GetNextAlias()
Local cQuery2	:= "CALI"+GetNextAlias()
Local cAliasExc	:= ""
Local cQryHrsUts:= "CALI"+GetNextAlias()
Local cQryFim	:= "CALI"+GetNextAlias()
Local cFilAEG 	:= xFilial('AEG')
Local nPrecisao	:= 0
Local nMinuts	:= 0
Local nPerc 	:= 0
Local nValAdd	:= 0
Local nDOW		:= Dow(dFinish)
Local cAliasITVL:= "ITV2"+GetNextAlias()
Local nDuracao	:= nDurHrs
Local lConsidExc:= .F.
Local lFirst 	:= .T.

DEFAULT cProjet	:=	""
DEFAULT cRecurso:=	""
DEFAULT lNewCalend	:= SuperGetMv("MV_PMSCALE" , .T. , .F. )

If !lNewCalend .OR. ( !__lTopConn .or. !AliasinDic("AEG") )
	Return PMSDTaskI(dFinish, cHoraf, cCalend, Durac, cProjet, cRecurso)
Endif

dFinish := If(Empty(dFinish),dDataBase+1,dFinish)
nDOW		:= Dow(dFinish)

dbSelectArea("AEG")
dbSetOrder(1) // 'AEG_FILIAL+AEG_CODIGO+AEG_TIPO+AEG_PROJET'
If !msSeek(xFilial("AEG")+cCalend+"C" )
	Alert(STR0158+cCalend+STR0159) //"Calendário " - " não cadastrado na tabela AEG. Favor Verificar"
	Return {cDataIni, cHoraIni, cDataFim, cHoraFim}
Endif

// Horas Uteis do calendário escolhido
cQuery	:= "SELECT SUM(AEG_HUTEIS) HRS_UTEIS FROM "+cAliasAEG
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
cQuery 	+= " AND AEG_TIPO = 'C'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

// Horas do dia da semana da data Início
cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_SEMANA, AEG_PRECIS FROM "+cAliasAEG
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
cQuery 	+= " AND AEG_TIPO = 'C' "
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY AEG_SEMANA , AEG_ITEM DESC"

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasITVL , .T. , .T. )

// Horas do dia da semana da data Início
cQuery	:= "SELECT AEG_ITEM, AEG_HORAI,AEG_HORAF, AEG_HUTEIS, AEG_PRECIS FROM "+cAliasAEG
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
cQuery	+= " AND AEG_SEMANA = "+STR(nDOW)
cQuery 	+= " AND AEG_TIPO = 'C'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY AEG_ITEM DESC"
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQuery2 , .T. , .T. )

nPrecisao	:= (cQuery2)->(AEG_PRECIS)

// Horas uteis por dia da semana
cQuery	:= "SELECT MIN(AEG_HORAI) AEG_HORAI, MAX(AEG_HORAF) AEG_HORAF, AEG_SEMANA, SUM(AEG_HUTEIS) HRSUTEIS FROM "+cAliasAEG
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
cQuery 	+= " AND AEG_TIPO = 'C'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " GROUP BY AEG_SEMANA "
cQuery	+= " ORDER BY AEG_SEMANA DESC"
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryHrsUts , .T. , .T. )

(cQuery2)->(dbGoTop())

// Garante posicionar no primeiro dia da semana com horas uteis
While (cQuery2)->(AEG_HUTEIS) == 0
	(cQuery2)->(dbCloseArea())
	cQuery2	:= GetNextAlias()
	dFinish++
	nDOW++
	If nDow > 7
		nDow := 1
	Endif
	// Datas e horas do dia da semana do dia Início
	cQuery	:= "SELECT AEG_ITEM, AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery	+= " AND AEG_SEMANA = "+STR(nDOW)
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY AEG_ITEM DESC"
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQuery2 , .T. , .T. )

	Loop
EndDo

While (cQryHrsUts)->( AEG_SEMANA ) <> nDow
	(cQryHrsUts)->( dbSkip() )
	If (cQryHrsUts)->( EOF() )
		(cQryHrsUts)->( dbGoTop() )
	Endif
	Loop
EndDo

//########################################################//
//***************** Parte do cálculo *********************//
//########################################################//
cDataIni	:= dFinish //Novo dia início, caso o dia da semana escolhido não tenha horas de trabalho
cDataFim	:= dFinish

If (cHoraf >= (cQuery2)->(AEG_HORAF))
	cHoraFim := (cQuery2)->(AEG_HORAF)
Else
	cHoraFim := cHoraf
Endif

If nDuracao==0
	cHoraIni 	:= cHoraFim
ElseIf ( (cQryHrsUts)->(HRSUTEIS) >= nDuracao ) .and. ( (cQryHrsUts)->(AEG_HORAI) != cHoraFim )

	cQuery	:= "SELECT AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery	+= " AND AEG_SEMANA = "+STR( (cQryHrsUts)->(AEG_SEMANA) )
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY AEG_HORAI DESC "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryFim , .T. , .T. )

	While (cQryFim)->(!EOF())

		If lFirst
			If  (cQryHrsUts)->(AEG_HORAF) > cHoraFim

				While (cQuery2)->(!EOF())
					If cHoraFim < (cQuery2)->(AEG_HORAI)
						nDuracao	+=  PMSTimeDiff(  "00"+(cQuery2)->(AEG_HORAF) , "00"+(cQuery2)->(AEG_HORAI) )
					Elseif cHoraFim > (cQuery2)->(AEG_HORAI) .AND. cHoraFim < (cQuery2)->(AEG_HORAF)
						nDuracao	+=  PMSTimeDiff(  "00"+(cQuery2)->(AEG_HORAF) , "00"+cHoraFim )
					Endif
					(cQuery2)->(dbSkip())
				EndDo

			ElseIf  (cQryHrsUts)->(AEG_HORAF) < cHoraIni
				(cQryFim)->(dbSkip())
				Loop
			Endif
		EndIf

		If nDuracao > (cQryFim)->(AEG_HUTEIS) // Se ainda precisamos de mais horas

			nDuracao -= (cQryFim)->(AEG_HUTEIS)

		ElseIf nDuracao == (cQryFim)->(AEG_HUTEIS) // Se este período é exatamento do que precisamos

			nDuracao -= (cQryFim)->(AEG_HUTEIS)
			cHoraIni := (cQryFim)->(AEG_HORAI)
			Exit

		Else

			nDuracao 	:= nDuracao * 3600 // Quantos Minutos a partir da HORA INICIAL
			cHoraIni 	:= A690Sec2Time(Secs((cQryFim)->(AEG_HORAF)) + nDuracao)
			cHoraIni 	:= Substr(cHoraFim,3)
			Exit

		Endif
		lFirst := .F.
		(cQryFim)->(dbSkip())
	EndDo

	If nDuracao > 0 // sobrou residuo para outro dia

		cDataIni--
		While (cQryHrsUts)->( AEG_SEMANA ) <> Iif( nDow-1==0, 7, nDow-1)
			(cQryHrsUts)->( dbSkip() )
			If (cQryHrsUts)->( EOF() )
				(cQryHrsUts)->( dbGoTop() )
			Endif
			Loop
		EndDo
		If Select(cQryFim)>0
			(cQryFim)	->	(DbCloseArea())
		Endif
		cQuery	:= "SELECT AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
		cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
		cQuery	+= " AND AEG_SEMANA = "+STR( (cQryHrsUts)->(AEG_SEMANA) )
		cQuery 	+= " AND AEG_TIPO = 'C'"
		cQuery	+= " AND D_E_L_E_T_ = ' ' "
		cQuery	+= " ORDER BY AEG_HORAI DESC "
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryFim , .T. , .T. )

		While (cQryFim)->(!EOF())

			If nDuracao > (cQryFim)->(AEG_HUTEIS) // Se ainda precisamos de mais horas

				nDuracao -= (cQryFim)->(AEG_HUTEIS)

			ElseIf nDuracao == (cQryFim)->(AEG_HUTEIS) // Se este período é exatamento do que precisamos

				nDuracao -= (cQryFim)->(AEG_HUTEIS)
				cHoraIni := (cQryFim)->(AEG_HORAI)
				Exit

			Else

				nDuracao 	:= nDuracao * 3600 // Quantos Minutos a partir da HORA INICIAL
				cHoraIni 	:= A690Sec2Time(Secs((cQryFim)->(AEG_HORAF)) - nDuracao)
				cHoraIni 	:= Substr(cHoraIni,3)
				Exit

			Endif

			(cQryFim)->(dbSkip())
		EndDo
	Endif

Else
	nDuracao	-= GetLastDay(	cDataIni, , cProjet, cRecurso, cQryHrsUts, cAliasITVL, cHoraFim)

	If (cQryHrsUts)->( EOF() )
		(cQryHrsUts)->( dbGoTop() )
	Else
		(cQryHrsUts)->( dbSkip() )
		If (cQryHrsUts)->( EOF() )
			(cQryHrsUts)->( dbGoTop() )
		Endif
	Endif
	cDataIni--

	While nDuracao > 0

		If (cQryHrsUts)->(HRSUTEIS) >= nDuracao
			Exit
		Endif
		aDadosExc	:= PmsAEGExc( {cDataIni,cDataIni} , cProjet, cRecurso, cQryHrsUts, .F.,.T.)

		If !aDadosExc[1][7]
			nDuracao -= aDadosExc[1][8]
			cDataIni--
		Else
			If aDadosExc[1][1] <= nDuracao

				If aDadosExc[1][1] == nDuracao
					lConsidExc := .T.
				Endif
				nDuracao -= aDadosExc[1][1]
				cDataIni--

			Else



				lConsidExc := .T.
				Exit
			Endif
		Endif

		If (cQryHrsUts)->( EOF() )
			(cQryHrsUts)->( dbGoTop() )
			Loop
		Else
			(cQryHrsUts)->( dbSkip() )
			If (cQryHrsUts)->( EOF() )
				(cQryHrsUts)->( dbGoTop() )
			Endif
			Loop
		Endif

	EndDo

	If lConsidExc

		cQuery := " SELECT AEG_ITEM, AEG_RECURS,AEG_PROJET, AEG_DATAI, AEG_DATAF, AEG_HORAI, AEG_HORAF, AEG_HUTEIS, R_E_C_N_O_ RECNO_ "
		cQuery += " FROM "+cAliasAEG
		cQuery += " WHERE AEG_CODIGO = 'AFY' "
		cQuery += " AND AEG_TIPO = 'E'"

		cQuery += " AND ( AEG_PROJET = ' ' "
		cQuery += " OR AEG_PROJET = '"+cProjet+"' ) "

		cQuery += " AND ( AEG_RECURS = ' '
		If Len(cRecurso) > 0
			cQuery += " OR AEG_RECURS = '"+cRecurso+"' ) "
		Else
			cQuery += ") "
		Endif

		cQuery += " AND ( "
		cQuery += "		( AEG_DATAI <= '"+Dtos(cDataIni)+"' AND AEG_DATAF >= '"+Dtos(cDataIni)+"'  ) "
		cQuery += " 	OR ( AEG_DATAI <= '"+Dtos(cDataIni)+"' AND AEG_DATAF >= '"+Dtos(cDataIni)+"'  ) "
		cQuery += " 	OR ( AEG_DATAI BETWEEN '"+Dtos(cDataIni)+"' AND '"+Dtos(cDataIni)+"' ) "
		cQuery += " ) "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY AEG_DATAI DESC, AEG_ITEM DESC, AEG_RECURS DESC, AEG_PROJET DESC"

		cAliasExc	:= "EXCI"+GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasExc , .T. , .T. )

		While (cAliasExc)->(!EOF())

			If nDuracao > (cAliasExc)->(AEG_HUTEIS) // Se ainda precisamos de mais horas

				nDuracao -= (cAliasExc)->(AEG_HUTEIS)

			ElseIf nDuracao == (cAliasExc)->(AEG_HUTEIS) // Se este período é exatamento do que precisamos

				nDuracao -= (cAliasExc)->(AEG_HUTEIS)
				cHoraIni := (cAliasExc)->(AEG_HORAI)
				Exit

			Else

				nDuracao 	:= nDuracao * 3600 // Quantos Minutos a partir da HORA INICIAL
				cHoraIni 	:= A690Sec2Time(Secs((cAliasExc)->(AEG_HORAF)) - nDuracao)
				cHoraIni 	:= Substr(cHoraIni,3)
				Exit

			Endif

			(cAliasExc)->(dbSkip())
		EndDo
		(cAliasExc)->(dbCloseArea())
	ElseIf nDuracao > 0

		cQuery	:= "SELECT AEG_HORAI,AEG_HORAF,AEG_HUTEIS FROM "+cAliasAEG
		cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
		cQuery	+= " AND AEG_SEMANA = "+STR( (cQryHrsUts)->(AEG_SEMANA) )
		cQuery 	+= " AND AEG_TIPO = 'C'"
		cQuery	+= " AND D_E_L_E_T_ = ' ' "
		cQuery	+= " ORDER BY AEG_HORAI DESC "
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryFim , .T. , .T. )

		While (cQryFim)->(!EOF())

			If nDuracao > (cQryFim)->(AEG_HUTEIS) // Se ainda precisamos de mais horas

				nDuracao -= (cQryFim)->(AEG_HUTEIS)

			ElseIf nDuracao == (cQryFim)->(AEG_HUTEIS) // Se este período é exatamento do que precisamos

				nDuracao -= (cQryFim)->(AEG_HUTEIS)
				cHoraIni := (cQryFim)->(AEG_HORAI)
				Exit

			Else

				nDuracao 	:= nDuracao * 3600 // Quantos Minutos a partir da HORA INICIAL
				cHoraIni 	:= A690Sec2Time(Secs((cQryFim)->(AEG_HORAF)) - nDuracao)
				cHoraIni 	:= Substr(cHoraIni,3)
				Exit

			Endif

			(cQryFim)->(dbSkip())
		EndDo
	Endif

Endif

(cAliasITVL)->	(DbCloseArea())
(cAlias)	->	(DbCloseArea())
(cQryHrsUts)->	(DbCloseArea())
(cQuery2)	->	(DbCloseArea())
If Select(cQryFim)>0
	(cQryFim)->(DbCloseArea())
Endif

RestArea(aArea)

/********* Tratamento do MV_PRECISA *********/
nMinuts	:= Val(Substr(cHoraIni,4,2))
If ( nMinuts%nPrecisao ) <> 0  // se resto da divisao for diferente de zero
	nPerc 	:= (nMinuts/nPrecisao)
	nValAdd	:= Round(nPerc,0)-nPerc
	If nValAdd <> nPrecisao
		nMinuts += (nValAdd*nPrecisao)
	Endif
	cHoraIni := Substr(cHoraIni,1,3)+StrZero(nMinuts,2)
Endif

nMinuts	:= Val(Substr(cHoraFim,4,2))
If ( nMinuts%nPrecisao ) <> 0  // se resto da divisao for diferente de zero
	nPerc 	:= (nMinuts/nPrecisao)
	nValAdd	:= Round(nPerc,0)-nPerc
	If nValAdd <> nPrecisao
		nMinuts += (nValAdd*nPrecisao)
	Endif
	cHoraFim := Substr(cHoraFim,1,3)+ StrZero(nMinuts,2)
Endif

Return {cDataIni, cHoraIni, cDataFim, cHoraFim}



/* SUBSTITUICAO DA FUNCAO PmsHrsItv2()
Função Original:	PmsHrsItv2(dDataIni,cHoraIni,dDataFim,cHoraFim,cCalend,cProjeto,cRecurso,lPcP,lAponta,cAliasAFY)
Chamada Original:	PmsHrsItvl(M->AF9_START,M->AF9_HORAI,M->AF9_FINISH,M->AF9_HORAF,M->AF9_CALEND,cCodProjeto,AE8->AE8_RECURS)
Descrição:			Retorna o numero de horas uteis em um determinado intervalo
Retorno	: 			nDuracao
*/
Function PmsAEGItvl(dDataIni,cHoraIni,dDataFim,cHoraFim,cCalend,cProjeto,cRecurso,aTrbs)
Local aArea		:= GetArea()
Local aDadosExc	:= {}
Local cAlias	:= ""
Local cAliasIT2	:= ""
Local cAliasITVL:= ""
Local cQryHrsUts:= ""
Local cTotHrs	:= ""
Local cQuery	:= ""
Local cAliasAEG	:= ""
Local cFilAEG 	:= ""
Local nDow		:= 0
Local nHrsUteis	:= 0
Local lNovaData	:= .T.
Local lTemStatic:= .F.
Local lSincroPMS:= .F.
Local lOneDay	:= dDataIni==dDataFim

DEFAULT aExcecoes:= {}
DEFAULT aTrbs	:= {}

DEFAULT lNewCalend	:= SuperGetMv("MV_PMSCALE" , .T. , .F. )

If !lNewCalend .OR. ( !__lTopConn .or. !AliasinDic("AEG") )
	PmsHrsItvl(dDataIni,cHoraIni,dDataFim,cHoraFim,cCalend,cProjeto,cRecurso)
Endif

lSincroPMS	:= "PMSC010" $ Alltrim(FUNNAME())
cAlias		:= "AlIt"+GetNextAlias()
cAliasIT2	:= "IT2" +GetNextAlias()
cAliasITVL	:= "ITVL"+GetNextAlias()
cQryHrsUts	:= "UTS" +GetNextAlias()
cTotHrs		:= "TOT" +GetNextAlias()
cQuery		:= ""
cAliasAEG	:= RetSqlName("AEG")
cFilAEG 	:= xFilial('AEG')


dbSelectArea("AEG")
dbSetOrder(1) // 'AEG_FILIAL+AEG_CODIGO+AEG_TIPO+AEG_PROJET'
If !msSeek(xFilial("AEG")+cCalend+"C" )
	Alert(STR0158+cCalend+STR0159) //"Calendário " - " não cadastrado na tabela AEG. Favor Verificar"
	Return 0
Endif

lTemStatic:= Len(aExcecoes) > 0

If Len(aTrbs)>0 // queries cacheadas
	cAlias		:= aTrbs[2]
	cAliasIT2	:= aTrbs[3]
	cAliasITVL	:= aTrbs[4]
	cQryHrsUts	:= aTrbs[5]
	cTotHrs		:= aTrbs[6]
Else
	cAlias		:= "AlIt"+GetNextAlias()
	cAliasIT2	:= "IT2" +GetNextAlias()
	cAliasITVL	:= "ITVL"+GetNextAlias()
	cQryHrsUts	:= "UTS" +GetNextAlias()
	cTotHrs		:= "TOT" +GetNextAlias()

	// Horas Uteis do calendário escolhido
	cQuery	:= "SELECT SUM(AEG_HUTEIS) HRS_UTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

	// Horas do dia da semana da data Início
	cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_SEMANA, AEG_PRECIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY AEG_SEMANA , AEG_ITEM "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasITVL , .T. , .T. )

	// Horas do dia da semana da data Início
	cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_SEMANA, AEG_PRECIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY AEG_SEMANA DESC, AEG_ITEM DESC "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasIT2 , .T. , .T. )

	// Horas uteis por dia da semana
	cQuery	:= "SELECT AEG_SEMANA, SUM(AEG_HUTEIS) HRSUTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " GROUP BY AEG_SEMANA "
	cQuery	+= " ORDER BY AEG_SEMANA "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryHrsUts , .T. , .T. )

	// Horas Uteis do calendário escolhido
	cQuery	:= "SELECT SUM(AEG_HUTEIS) HRS_UTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTotHrs, .T., .T. )

Endif

dDataItv 	:= (dDataIni+1)
nDow		:= DOW(dDataItv)

If dDataIni == dDataFim
	nHrsUteis	+= GetFirstDay(	dDataIni, cHoraIni, cProjeto, cRecurso, cQryHrsUts, cAliasITVL, cHoraFim )
Else
	nHrsUteis	+= GetFirstDay(	dDataIni, cHoraIni, cProjeto, cRecurso, cQryHrsUts, cAliasITVL)
Endif
//posiciona no dia da semana correto (data inicio)
(cQryHrsUts)->( dbGoTop() )
While (cQryHrsUts)->( AEG_SEMANA ) <> nDow
	(cQryHrsUts)->( dbSkip() )
	If (cQryHrsUts)->( EOF() )
		(cQryHrsUts)->( dbGoTop() )
	Endif
	Loop
EndDo

//posiciona no dia da semana correto (data inicio)
(cAliasITVL)->( dbGoTop() )
While (cAliasITVL)->( AEG_SEMANA ) <> nDow
	(cAliasITVL)->( dbSkip() )
	If (cAliasITVL)->( EOF() )
		(cAliasITVL)->( dbGoTop() )
	Endif
	Loop
EndDo

While (dDataFim > dDataItv)

	If lNovaData
		If lTemStatic
			If ( nPos := aScan( aExcecoes, { |x| x[1] == dDataItv .and. x[2] == cProjeto } ) ) > 0
				nHrsUteis	+= aExcecoes[nPos][4]
				lNovaData	:= .F.
			Elseif !lSincroPMS .AND. ( nPos := aScan( aExcecoes, { |x| x[1] == dDataItv } ) ) > 0
				nHrsUteis	+= aExcecoes[nPos][4]
				lNovaData	:= .F.
			Endif
		Else
			aDadosExc	:= PmsAEGExc( {dDataItv,dDataItv} , cProjeto, cRecurso, cQryHrsUts, .F. , .T., "00:00" )
		Endif

	Endif

	If ( !lTemStatic .and. aDadosExc[1][7] )

		nHrsUteis 	+= aDadosExc[1][1]

	ElseIf lTemStatic .and. (nPos>0) // ja encontrei as horas uteis deste dia em excecao

	    nDow := (cAliasITVL)->AEG_SEMANA

		(cAliasITVL)->(dbSkip())
		dDataItv++
		If 	(cAliasITVL)->(EOF())
			(cAliasITVL)->(dbGoTop())
		Endif
		While nDow == (cAliasITVL)->AEG_SEMANA
			(cAliasITVL)->(dbSkip())
		EndDo
		lNovaData := .T.
		Loop

	Else
		nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+(cAliasITVL)->AEG_HORAI )
	Endif

    nDow := (cAliasITVL)->AEG_SEMANA

	(cAliasITVL)->(dbSkip())

	If 	(cAliasITVL)->(EOF())
		(cAliasITVL)->(dbGoTop())
	Endif

	If ( !lTemStatic .and. aDadosExc[1][7] ) .OR. (nDow <> (cAliasITVL)->AEG_SEMANA)
		dDataItv++
		While nDow == (cAliasITVL)->AEG_SEMANA
			(cAliasITVL)->(dbSkip())
		EndDo
		lNovaData := .T.
	Endif

EndDo

aDadosExc	:= PmsAEGExc( {dDataItv,dDataItv} , cProjeto, cRecurso, cQryHrsUts, .F. , .T., "00:00", cHoraFim )

If !aDadosExc[1][7]

	While dDataFim == dDataItv

		If (cAliasITVL)->AEG_HORAF == cHoraFim // SE FOR O MESMO FIM

			If (nHrsUteis==0) .and. (cAliasITVL)->AEG_HORAI <= cHoraIni
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+cHoraIni )
			Else
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+(cAliasITVL)->AEG_HORAI )
			Endif
			Exit

		ElseIf ( (cAliasITVL)->AEG_HORAI <= cHoraFim ) .AND. ( (cAliasITVL)->AEG_HORAF >= cHoraFim ) // SE ESTIVER ENTRE O RANGE

			If (nHrsUteis==0) .and. (cAliasITVL)->AEG_HORAI <= cHoraIni .and. lOneDay
				nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+ cHoraIni )
			Else
				nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+ (cAliasITVL)->AEG_HORAI )
			Endif
			Exit

		Elseif ( cHoraFim > (cAliasITVL)->AEG_HORAF ) // SE HORA FINAL APÓS HORA FIM UTIL DO PERIODO

			If (nHrsUteis==0) .and. (cAliasITVL)->AEG_HORAI <= cHoraIni
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+cHoraIni )
			Else
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+(cAliasITVL)->AEG_HORAI )
			Endif

	    Endif

	    nDow := (cAliasITVL)->AEG_SEMANA

		(cAliasITVL)->(dbSkip())

		If 	(cAliasITVL)->(EOF())
			Exit
		Endif

		If nDow <> (cAliasITVL)->AEG_SEMANA
			dDataItv++
		Endif

	Enddo

Else
	nHrsUteis 	+= aDadosExc[1][1]
Endif

If Len(aTrbs)==0
	(cAlias)->(dbCloseArea())
	(cAliasIT2)->(dbCloseArea())
	(cAliasITVL)->(dbCloseArea())
	(cQryHrsUts)->(dbCloseArea())
	(cTotHrs)->(dbCloseArea())
Endif
RestArea(aArea)

Return nHrsUteis

/* SUBSTITUICAO DA FUNCAO PmsHrUtil()
Função Original:	PmsHrUtil(dData,cHoraIni,cHoraFim,cCalend,aForaDeUso,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
Chamada Original:	PmsHrUtil(dDataIni,"0000:00","0024:00",cCalend,,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY)
Descrição:			Retorna o numero de horas uteis em um determinado intervalo
Retorno	: 			nHrsUteis
*/
Function PmsAEGUteis(dData,cHoraIni,cHoraFim,cCalend,aForadeUso,cProjeto,cRecurso,lPcp,cAloc,nTamanho,lAponta,cAliasAFY,lFirstDay,lLastDay, aTrbs)
Local aArea		:= GetArea()
Local nDow		:= DOW(dData)
Local nHrsUteis	:= 0
Local nPos		:= 0
Local aDadosExc	:= {}
Local cAliasITVL:= "I"+GetNextAlias()
Local cQryHrs	:= ""
Local cQuery	:= ""
Local cAliasAEG	:= RetSqlName("AEG")
Local cFilAEG 	:= xFilial('AEG')
Local lSincroPMS:= "PMSC010" $ Alltrim(FUNNAME())
Local lTemStatic:= Len(aExcecoes) > 0
DEFAULT cProjeto:= ""
DEFAULT cRecurso:= ""
DEFAULT aExcecoes	:= {}
DEFAULT lFirstDay	:= .F.
DEFAULT lLastDay 	:= .F.
DEFAULT	cHoraFim 	:= "24:00"
DEFAULT	aTrbs		:= {}

If Len(aTrbs)>0
	//cacheado
	cQryHrs := aTrbs[2]

Else
	cQryHrs	:= "U"+GetNextAlias()
	// Horas uteis por dia da semana
	cQuery	:= "SELECT AEG_SEMANA, SUM(AEG_HUTEIS) HRSUTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " GROUP BY AEG_SEMANA "
	cQuery	+= " ORDER BY AEG_SEMANA"
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryHrs , .T. , .T. )
Endif
// Horas do dia da semana da data Início
cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_SEMANA, AEG_PRECIS FROM "+cAliasAEG
cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
cQuery 	+= " AND AEG_TIPO = 'C' "
cQuery	+= " AND AEG_SEMANA = '"+STR(nDow)+"' "
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY AEG_ITEM "

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasITVL , .T. , .T. )

If !lTemStatic
	aDadosExc	:= PmsAEGExc( {dData,dData} , cProjeto, cRecurso, cQryHrs, .F. , .T., cHoraIni , cHoraFim,lFirstDay,lLastDay)
ElseIf ( nPos := aScan( aExcecoes, { |x| x[1] == dData .and. x[2] == cProjeto } ) ) > 0
	aDadosExc	:= PmsAEGExc( {dData,dData} , cProjeto, cRecurso, cQryHrs, .F. , .T., cHoraIni , cHoraFim,lFirstDay,lLastDay)
Elseif !lSincroPMS .And. ( nPos := aScan( aExcecoes, { |x| x[1] == dData } ) ) > 0
	aDadosExc	:= PmsAEGExc( {dData,dData} , cProjeto, cRecurso, cQryHrs, .F. , .T., cHoraIni , cHoraFim,lFirstDay,lLastDay)
Endif

If nPos==0 .or. ( (nPos>0) .and. !aDadosExc[1][7] )
	While (cAliasITVL)->(!EOF()) .AND. (cAliasITVL)->AEG_SEMANA == nDow

		If ( cHoraIni=="00:00" ) .AND. ( cHoraFim == (cAliasITVL)->AEG_HORAI )
			Exit
		EndIf
		If cHoraIni >= (cAliasITVL)->AEG_HORAF // proximo item do calendario
			(cAliasITVL)->(dbSkip())
		    Loop

		Elseif (cAliasITVL)->AEG_HORAI == cHoraIni // SE FOR O MESMO INICIO

			If cHoraFim=="24:00" .or. cHoraFim > (cAliasITVL)->AEG_HORAF
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+cHoraIni )
			Else
				nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+cHoraIni )
			Endif

		ElseIf ((cAliasITVL)->AEG_HORAI <= cHoraIni ) .AND. ( (cAliasITVL)->AEG_HORAF >= cHoraIni ) // SE ESTIVER ENTRE O RANGE

			If cHoraFim=="24:00" .or. cHoraFim > (cAliasITVL)->AEG_HORAF
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+cHoraIni )
			Else
				nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+cHoraIni )
			Endif

		Elseif ( cHoraFim > (cAliasITVL)->AEG_HORAI ) .AND. ( cHoraFim <= (cAliasITVL)->AEG_HORAF ) // SE HORA FIM ANTERIOR AO FINAL UTIL DO PERIODO

			nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasITVL)->AEG_HORAI )

		Elseif ( cHoraIni < (cAliasITVL)->AEG_HORAI ) .AND. ( cHoraFim >= (cAliasITVL)->AEG_HORAF )// SE HORA INICIAL ANTERIOR AO INICIO UTIL DO PERIODO

			nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+(cAliasITVL)->AEG_HORAI )

		Endif

		(cAliasITVL)->(dbSkip())
	EndDo

Else

	nHrsUteis 	+= aDadosExc[1][1]

Endif

If Len(aTrbs)==0
	(cQryHrs)->(dbCloseArea())
Endif
(cAliasITVL)->(dbCloseArea())

RestArea(aArea)
Return nHrsUteis

/*	Função PmsAEGExc()
	Verificar em um período o Calendario x Exceção, retornando horas a serem desconsideradas e a data inicio e fim
*/
Function PmsAEGExc(aChkExc, cProjeto, cRecurso, cQryHrsUts, lContrario,lOneDay,cHoraIni,cHoraFim,lFirstDay, lLastDay)
Local aArea		:= GetArea()
Local aDiasSem	:= {{},{},{},{},{},{},{}}
Local aDatas	:= {}
Local aPeriodo	:= {}
Local nResto	:= 0
Local nHrsExc	:= 0
Local nCont		:= 7
Local nRecIni	:= 0
Local nRecFim	:= 0
Local nOldSemana:= (cQryHrsUts)->(AEG_SEMANA)
Local cQuery	:= ''
Local cHrExcIni	:= ''
Local cHrExcFim	:= ''
Local cAliasExc	:= "EXCE"+getNextAlias()
Local cAliasAEG	:= RetSqlName("AEG")
Local lVldFim 	:= .F.
Local dDataIni	:= aChkExc[1]
Local dDataFim	:= aChkExc[2]
Local dDataI
Local dDataF
Local lTemRec	:= !empty(cRecurso)
Local lTemProj	:= !empty(cProjeto)
Local lFirst	:= .T.
Local lAchou	:= .F.
Local nHrsSem	:= 0
Local nPos		:= 0
Local nProjet	:= 0
DEFAULT lOneDay	:= .F.
DEFAULT lFirstDay	:= .F.
DEFAULT cProjeto:= ''
DEFAULT cRecurso:= ''
DEFAULT lContrario:= .F.
DEFAULT cHoraIni:= '00:00'
DEFAULT cHoraFim:= '24:00'
DEFAULT lLastDay:= !("24:00"$cHoraFim)

lVldFim 	:= !("24:00"$cHoraFim)


(cQryHrsUts)->(DbGoTop())
If lContrario
	If (cQryHrsUts)->(EOF())
		(cQryHrsUts)->(dbGoTop())
	Endif
	While (cQryHrsUts)->(!EOF())
		aAdd(aDiasSem[nCont], { (cQryHrsUts)->(AEG_SEMANA) , (cQryHrsUts)->(HRSUTEIS) } )
		nCont--
		(cQryHrsUts)->(dbSkip())
	EndDo
Else
	nCont := 1
	If (cQryHrsUts)->(EOF())
		(cQryHrsUts)->(dbGoTop())
	Endif
	While (cQryHrsUts)->(!EOF())
		aAdd(aDiasSem[nCont], { (cQryHrsUts)->(AEG_SEMANA) , (cQryHrsUts)->(HRSUTEIS) } )
		nCont++
		(cQryHrsUts)->(dbSkip())
	EndDo
Endif

If !lOneDay

	cQuery := " SELECT SUM(AEG_HUTEIS) HRSUTEIS,AEG_DATAI, AEG_DATAF, MIN(R_E_C_N_O_) MINIMO, MAX(R_E_C_N_O_) MAXIMO "
	cQuery += " FROM "+cAliasAEG
	cQuery += " WHERE AEG_CODIGO = 'AFY' "
	cQuery += " AND AEG_TIPO = 'E'"

	cQuery += " AND ( AEG_PROJET = ' ' "
	If lTemProj
		cQuery += " OR AEG_PROJET = '"+cProjeto+"' ) "
	Else
		cQuery += ") "
	Endif

	cQuery += " AND ( AEG_RECURS = ' '
	If lTemRec
		cQuery += " OR AEG_RECURS = '"+cRecurso+"' ) "
	Else
		cQuery += ") "
	Endif

	cQuery += " AND ( "
	cQuery += "		( AEG_DATAI <= '"+Dtos(dDataIni)+"' AND AEG_DATAF >= '"+Dtos(dDataIni)+"'  ) "
	cQuery += " 	OR ( AEG_DATAI <= '"+Dtos(dDataFim)+"' AND AEG_DATAF >= '"+Dtos(dDataFim)+"'  ) "
	cQuery += " 	OR ( AEG_DATAI BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' ) "
	cQuery += " ) "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY AEG_DATAI, AEG_DATAF"
	cQuery += " ORDER BY AEG_DATAI DESC, MAXIMO "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasExc , .T. , .T. )

	While (cAliasExc)->(!EOF())

		If ( aScan( aDatas, (cAliasExc)->AEG_DATAI ) > 0 )
			(cAliasExc)->(dbSkip())
			Loop
		Endif

		lAchou := .T.
	    //************************************************************************************//
		nHrsExc	+= (cAliasExc)->(HRSUTEIS)
		nDow	:= DOW( StoD( (cAliasExc)->AEG_DATAI )  )
		nResto	+= aDiasSem[nDow][1][2]
		aadd(aDatas, (cAliasExc)->AEG_DATAI)

		If lFirst
			lFirst 		:= .F.
			nRecIni := (cAliasExc)->(MINIMO)
			nRecFim := (cAliasExc)->(MAXIMO)
		Endif
		If nRecIni > (cAliasExc)->(MINIMO)
			nRecIni := (cAliasExc)->(MINIMO)
		Endif
		If nRecFim < (cAliasExc)->(MAXIMO)
			nRecFim := (cAliasExc)->(MAXIMO)
		Endif
		If (cAliasExc)->AEG_DATAI <> (cAliasExc)->AEG_DATAF

			dDataI := StoD((cAliasExc)->AEG_DATAI)
			dDataF := StoD((cAliasExc)->AEG_DATAF)
			While ( dDataI <= dDataf )
				dDataI++
				If ( aScan( aDatas, dDataI) <= 0 )
					nHrsExc	+= (cAliasExc)->(HRSUTEIS)
					If nDow	!= DOW( dDataI )
						nDow	:= DOW( dDataI )
						nResto	+= aDiasSem[nDow][1][2]
					Endif
					aadd(aDatas, dDataI)
				Endif
			EndDo

		Endif

		(cAliasExc)->(dbSkip())
		Loop
	EndDo

Else // Se o intervalo for somente de 1 dia

	If (nProjet := aScan( aProjets , { |x| x == cProjeto } )) >  0  .and. ( !lFirstDay .and. !lLastDay)
		If !Empty(cRecurso)
			If ( nPos := aScan( aExcecoes, { |x| x[1] == dDataIni .and. x[2] == cProjeto .and. x[2] == cRecurso} ) ) > 0
				nHrsExc	+= aExcecoes[nPos][4]
				lAchou := .T.
			Elseif ( nPos := aScan( aExcecoes, { |x| x[1] == dDataIni .and. x[2] == cRecurso } ) ) > 0
				nHrsExc	+= aExcecoes[nPos][4]
				lAchou := .T.
			Elseif ( nPos := aScan( aExcecoes, { |x| x[1] == dDataIni } ) ) > 0
				nHrsExc	+= aExcecoes[nPos][4]
				lAchou := .T.
			Endif
		Else
			If ( nPos := aScan( aExcecoes, { |x| x[1] == dDataIni .and. x[2] == cProjeto } ) ) > 0
				nHrsExc	+= aExcecoes[nPos][4]
				lAchou := .T.
			Elseif ( nPos := aScan( aExcecoes, { |x| x[1] == dDataIni } ) ) > 0
				nHrsExc	+= aExcecoes[nPos][4]
				lAchou := .T.
			Endif
		Endif

		nDow	:= DOW( dDataIni  )
		nResto	+= aDiasSem[nDow][1][2]
		nHrsSem:= nResto

	ElseIf (lFirstDay .or. ( nProjet  == 0 ) )

		cQuery := " SELECT AEG_ITEM, AEG_RECURS,AEG_PROJET, AEG_DATAI, AEG_DATAF, AEG_HORAI, AEG_HORAF, AEG_HUTEIS, R_E_C_N_O_ RECNO_ "
		cQuery += " FROM "+cAliasAEG
		cQuery += " WHERE AEG_CODIGO = 'AFY' "
		cQuery += " AND AEG_TIPO = 'E'"

		cQuery += " AND ( AEG_PROJET = ' ' "
		If lTemProj
			cQuery += " OR AEG_PROJET = '"+cProjeto+"' ) "
		Else
			cQuery += ") "
		Endif

		cQuery += " AND ( AEG_RECURS = ' '
		If lTemRec
			cQuery += " OR AEG_RECURS = '"+cRecurso+"' ) "
		Else
			cQuery += ") "
		Endif

		cQuery += " AND ( "
		cQuery += "		( AEG_DATAI <= '"+Dtos(dDataIni)+"' AND AEG_DATAF >= '"+Dtos(dDataIni)+"'  ) "
		cQuery += " 	OR ( AEG_DATAI <= '"+Dtos(dDataFim)+"' AND AEG_DATAF >= '"+Dtos(dDataFim)+"'  ) "
		cQuery += " 	OR ( AEG_DATAI BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' ) "
		cQuery += " ) "
		cQuery += " AND D_E_L_E_T_ = ' ' "

		If !lVldFim
			cQuery += " ORDER BY AEG_DATAI DESC, AEG_ITEM DESC, AEG_RECURS DESC, AEG_PROJET DESC"
		Else
			cQuery += " ORDER BY AEG_DATAI , AEG_ITEM , AEG_RECURS , AEG_PROJET "
		Endif
		If Select(cAliasExc) > 0
			(cAliasExc)->(dbCloseArea())
		Endif
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasExc , .T. , .T. )

		While (cAliasExc)->(!EOF())

			//*** Protejo o laço para não considerar exceções de outros recursos e/ou projetos!	***//
			If lTemRec .and. ( !empty((cAliasExc)->(AEG_RECURS)) .and. (cAliasExc)->(AEG_RECURS)<>cRecurso )
				(cAliasExc)->(dbSkip())
				Loop
			Endif

			If lTemProj .and. ( !empty((cAliasExc)->(AEG_PROJET)) .and. (cAliasExc)->(AEG_PROJET)<>cProjeto )
				(cAliasExc)->(dbSkip())
				Loop
			Endif

			If !lVldFim
				If (cAliasExc)->AEG_HORAI == cHoraIni // SE FOR O MESMO INICIO

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+cHoraIni )

				ElseIf ( (cAliasExc)->AEG_HORAI <= cHoraIni ) .AND. ( (cAliasExc)->AEG_HORAF >= cHoraIni ) // SE ESTIVER ENTRE O RANGE

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+cHoraIni )

				Elseif ( cHoraFim > (cAliasExc)->AEG_HORAI ) .AND. ( cHoraFim < (cAliasExc)->AEG_HORAF ) // SE HORA FIM ANTERIOR AO FINAL UTIL DO PERIODO

					nHrsExc 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasExc)->AEG_HORAI )

				Elseif ( cHoraIni < (cAliasExc)->AEG_HORAI ) // SE HORA INICIAL ANTERIOR AO INICIO UTIL DO PERIODO

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+(cAliasExc)->AEG_HORAI )

				Endif

			Else

				If (cAliasExc)->AEG_HORAF == cHoraFim // SE FOR O MESMO FIM

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+(cAliasExc)->AEG_HORAI )

				ElseIf ( (cAliasExc)->AEG_HORAI <= cHoraFim ) .AND. ( (cAliasExc)->AEG_HORAF >= cHoraFim ) // SE ESTIVER ENTRE O RANGE

					nHrsExc 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasExc)->AEG_HORAI )

				Elseif ( cHoraFim >= (cAliasExc)->AEG_HORAF )

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+(cAliasExc)->AEG_HORAI )

				Endif
			Endif

			lAchou := .T.

			If lFirst
				nDow	:= DOW( StoD( (cAliasExc)->AEG_DATAI )  )
				nResto	+= aDiasSem[nDow][1][2]
				cHrExcFim	:= (cAliasExc)->AEG_HORAF
				lFirst 		:= .F.
			Endif
			cHrExcIni	:= (cAliasExc)->AEG_HORAI
			If nRecIni > (cAliasExc)->RECNO_
				nRecIni		:= (cAliasExc)->RECNO_
			Endif
			If nRecFim < (cAliasExc)->RECNO_
				nRecFim		:= (cAliasExc)->RECNO_
			Endif

			(cAliasExc)->(dbSkip())
			Loop
		EndDo

		If !lAchou
			nDow := DOW(dDataIni)
			nHrsSem	+= aDiasSem[nDow][1][2]
		Endif

	Elseif lLastDay

		cQuery := " SELECT AEG_ITEM, AEG_RECURS,AEG_PROJET, AEG_DATAI, AEG_DATAF, AEG_HORAI, AEG_HORAF, AEG_HUTEIS, R_E_C_N_O_ RECNO_ "
		cQuery += " FROM "+cAliasAEG
		cQuery += " WHERE AEG_CODIGO = 'AFY' "
		cQuery += " AND AEG_TIPO = 'E'"

		cQuery += " AND ( AEG_PROJET = ' ' "
		If lTemProj
			cQuery += " OR AEG_PROJET = '"+cProjeto+"' ) "
		Else
			cQuery += ") "
		Endif

		cQuery += " AND ( AEG_RECURS = ' '
		If lTemRec
			cQuery += " OR AEG_RECURS = '"+cRecurso+"' ) "
		Else
			cQuery += ") "
		Endif

		cQuery += " AND ( "
		cQuery += "		( AEG_DATAI <= '"+Dtos(dDataIni)+"' AND AEG_DATAF >= '"+Dtos(dDataIni)+"'  ) "
		cQuery += " 	OR ( AEG_DATAI <= '"+Dtos(dDataFim)+"' AND AEG_DATAF >= '"+Dtos(dDataFim)+"'  ) "
		cQuery += " 	OR ( AEG_DATAI BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' ) "
		cQuery += " ) "
		cQuery += " AND D_E_L_E_T_ = ' ' "

		If !lVldFim
			cQuery += " ORDER BY AEG_DATAI DESC, AEG_ITEM DESC, AEG_RECURS DESC, AEG_PROJET DESC"
		Else
			cQuery += " ORDER BY AEG_DATAI , AEG_ITEM , AEG_RECURS , AEG_PROJET "
		Endif

		If Select(cAliasExc) > 0
			(cAliasExc)->(dbCloseArea())
		Endif

		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasExc , .T. , .T. )

		While (cAliasExc)->(!EOF())

			If !lVldFim
				If (cAliasExc)->AEG_HORAI == cHoraIni // SE FOR O MESMO INICIO

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+cHoraIni )

				ElseIf ( (cAliasExc)->AEG_HORAI <= cHoraIni ) .AND. ( (cAliasExc)->AEG_HORAF >= cHoraIni ) // SE ESTIVER ENTRE O RANGE

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+cHoraIni )

				Elseif ( cHoraFim > (cAliasExc)->AEG_HORAI ) .AND. ( cHoraFim < (cAliasExc)->AEG_HORAF ) // SE HORA FIM ANTERIOR AO FINAL UTIL DO PERIODO

					nHrsExc 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasExc)->AEG_HORAI )

				Elseif ( cHoraIni < (cAliasExc)->AEG_HORAI ) // SE HORA INICIAL ANTERIOR AO INICIO UTIL DO PERIODO

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+(cAliasExc)->AEG_HORAI )

				Endif

			Else

				If (cAliasExc)->AEG_HORAF == cHoraFim // SE FOR O MESMO FIM

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+(cAliasExc)->AEG_HORAI )

				ElseIf ( (cAliasExc)->AEG_HORAI <= cHoraFim ) .AND. ( (cAliasExc)->AEG_HORAF >= cHoraFim ) // SE ESTIVER ENTRE O RANGE

					nHrsExc 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasExc)->AEG_HORAI )

				Elseif ( cHoraFim >= (cAliasExc)->AEG_HORAF )

					nHrsExc 	+= PMSTimeDiff(  "00"+(cAliasExc)->AEG_HORAF , "00"+(cAliasExc)->AEG_HORAI )

				Endif
			Endif

			lAchou := .T.

			If lFirst
				nDow	:= DOW( StoD( (cAliasExc)->AEG_DATAI )  )
				nResto	+= aDiasSem[nDow][1][2]
				cHrExcFim	:= (cAliasExc)->AEG_HORAF
				lFirst 		:= .F.
			Endif
			cHrExcIni	:= (cAliasExc)->AEG_HORAI
			If nRecIni > (cAliasExc)->RECNO_
				nRecIni		:= (cAliasExc)->RECNO_
			Endif
			If nRecFim < (cAliasExc)->RECNO_
				nRecFim		:= (cAliasExc)->RECNO_
			Endif

			(cAliasExc)->(dbSkip())
			Loop
		EndDo

		If !lAchou
			nDow := DOW(dDataIni)
			nHrsSem	+= aDiasSem[nDow][1][2]
		Endif

	Endif

Endif

If Select(cAliasExc) > 0
	(cAliasExc)->(dbCloseArea())
Endif

(cQryHrsUts)->( dbGoTop() )
While (cQryHrsUts)->( AEG_SEMANA ) <> nOldSemana
	(cQryHrsUts)->( dbSkip() )
	If (cQryHrsUts)->( EOF() )
		(cQryHrsUts)->( dbGoTop() )
	Endif
	Loop
EndDo

RestArea(aArea)
If lAchou
	nHrsSem:= nResto
Endif
nResto := (nResto-nHrsExc)

aadd(aPeriodo, { nHrsExc , cHrExcIni , cHrExcFim, nResto, nRecIni, nRecFim , lAchou, nHrsSem} )

Return aPeriodo


Function GetFirstDay(dDataItv, cHoraIni, cProjeto, cRecurso, cQryHrs,cAliasITVL,cHoraFim)
Local aDadosExc	:= {}
Local nDow		:= Dow(dDataItv)
Local nHrsUteis	:= 0

DEFAULT cHoraIni:= "00:00"
DEFAULT cHoraFim:= "24:00"


//posiciona no dia da semana correto (data inicio)
(cQryHrs)->( dbGoTop() )
While (cQryHrs)->( AEG_SEMANA ) <> nDow
	(cQryHrs)->( dbSkip() )
	If (cQryHrs)->( EOF() )
		(cQryHrs)->( dbGoTop() )
	Endif
	Loop
EndDo
//posiciona no dia da semana correto (data inicio)
(cAliasITVL)->( dbGoTop() )
While (cAliasITVL)->( AEG_SEMANA ) <> nDow
	(cAliasITVL)->( dbSkip() )
	If (cAliasITVL)->( EOF() )
		(cAliasITVL)->( dbGoTop() )
	Endif
	Loop
EndDo

aDadosExc	:= PmsAEGExc( {dDataItv,dDataItv} , cProjeto, cRecurso, cQryHrs, .T. , .T. , cHoraIni , cHoraFim , .T., .F.)

If !aDadosExc[1][7]
	While (cAliasITVL)->(!EOF()) .AND. (cAliasITVL)->AEG_SEMANA == nDow

		If cHoraIni >= (cAliasITVL)->AEG_HORAF // proximo item do calendario
			(cAliasITVL)->(dbSkip())
		    Loop

		Elseif (cAliasITVL)->AEG_HORAI == cHoraIni // SE FOR O MESMO INICIO
			If cHoraFim < (cAliasITVL)->AEG_HORAF
				nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+cHoraIni )
			Else
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+cHoraIni )
			Endif

		ElseIf ( (cAliasITVL)->AEG_HORAI <= cHoraIni ) .AND. ( (cAliasITVL)->AEG_HORAF >= cHoraIni ) // SE ESTIVER ENTRE O RANGE

	        If ( (cAliasITVL)->AEG_HORAI <= cHoraFim ) .AND. ( (cAliasITVL)->AEG_HORAF >= cHoraFim ) // SE ESTIVER ENTRE O RANGE
   				nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+cHoraIni )
	        Else
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+cHoraIni )
			Endif

		Elseif ( cHoraIni < (cAliasITVL)->AEG_HORAI )
			// SE HORA INICIAL ANTERIOR AO INICIO UTIL DO PERIODO
	        If ( cHoraFim >= (cAliasITVL)->AEG_HORAI ) .and. ( cHoraFim <= (cAliasITVL)->AEG_HORAF )
				nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasITVL)->AEG_HORAI )
			Elseif ( cHoraFim > (cAliasITVL)->AEG_HORAF )
				nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+(cAliasITVL)->AEG_HORAI )
			Endif
		Endif

		(cAliasITVL)->(dbSkip())
	EndDo

Else

	nHrsUteis 	+= aDadosExc[1][1]

Endif

Return nHrsUteis


Function GetLastDay(dDataItv, cHoraIni, cProjeto, cRecurso, cQryHrs,cAliasITVL,cHoraFim)
Local aDadosExc	:= {}
Local nDow		:= Dow(dDataItv)
Local nHrsUteis	:= 0
DEFAULT cHoraIni:= "00:00"
DEFAULT cHoraFim:= "24:00"

//posiciona no dia da semana correto (data inicio)
(cQryHrs)->( dbGoTop() )
While (cQryHrs)->( AEG_SEMANA ) <> nDow
	(cQryHrs)->( dbSkip() )
	If (cQryHrs)->( EOF() )
		(cQryHrs)->( dbGoTop() )
	Endif
	Loop
EndDo

//posiciona no dia da semana correto (data inicio)
(cAliasITVL)->( dbGoTop() )
While (cAliasITVL)->( AEG_SEMANA ) <> nDow
	(cAliasITVL)->( dbSkip() )
	If (cAliasITVL)->( EOF() )
		(cAliasITVL)->( dbGoTop() )
	Endif
	Loop
EndDo

aDadosExc	:= PmsAEGExc( {dDataItv,dDataItv} , cProjeto, cRecurso, cQryHrs, .F. , .T. , cHoraIni , cHoraFim ,, .T. /*lFirstDay*/)

If !aDadosExc[1][7]
	While (cAliasITVL)->(!EOF()) .AND. (cAliasITVL)->AEG_SEMANA == nDow

		If cHoraFim <= (cAliasITVL)->AEG_HORAI // proximo item do calendario
			(cAliasITVL)->(dbSkip())
		    Loop

		Elseif (cAliasITVL)->AEG_HORAF == cHoraFim // SE FOR O MESMO INICIO

			nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasITVL)->AEG_HORAI )

		ElseIf ( (cAliasITVL)->AEG_HORAI <= cHoraFim ) .AND. ( (cAliasITVL)->AEG_HORAF >= cHoraFim ) // SE ESTIVER ENTRE O RANGE

			nHrsUteis 	+= PMSTimeDiff(  "00"+cHoraFim , "00"+(cAliasITVL)->AEG_HORAI)

		Elseif ( cHoraFim > (cAliasITVL)->AEG_HORAF ) // SE HORA INICIAL ANTERIOR AO INICIO UTIL DO PERIODO

			nHrsUteis 	+= PMSTimeDiff(  "00"+(cAliasITVL)->AEG_HORAF , "00"+(cAliasITVL)->AEG_HORAI )

		Endif

		(cAliasITVL)->(dbSkip())
	EndDo

Else

	nHrsUteis 	+= aDadosExc[1][1]

Endif

Return nHrsUteis


Function PMSSE1Ass(cAliasSE1, aHeaderAFT, aRatAFT, nx, nProp , nEvento)
Local nTotCsAbt 	:= 0
Local nTotPisAbt	:= 0
Local nTotCofAbt	:= 0
Local nTotInsAbt	:= 0
Local nTotIrAbt		:= 0
Local nz			:= 0
Local nCount		:= 0
Local cFilAFT		:= PmsFilial("SE1","AFT")
Local cFilSE1		:= xFilial("SE1")
Local cQuery		:= ""
Local cAliasAFT		:= "AFT"+getNextAlias()
Local nPosProjet	:= aScan(aHeaderAFT,{|x|AllTrim(x[2])=="AFT_PROJET"})
Local nPosTask		:= aScan(aHeaderAFT,{|x|AllTrim(x[2])=="AFT_TAREFA"})
Local nPosRevisa	:= aScan(aHeaderAFT,{|x|AllTrim(x[2])=="AFT_REVISA"})
Local aRecAFT		:= {}
Local aRecnoSE1		:= {}
Local aAreaSE1		:= (cAliasSE1)->(GetArea())
Local lTitpaiSE1	:= (SE1->(ColumnPos("E1_TITPAI")) > 0)
Local cTITPAI 		:= ""
Local cKey	 		:= ""

SumAbatRec((cAliasSE1)->(E1_PREFIXO),(cAliasSE1)->(E1_NUM),(cAliasSE1)->(E1_PARCELA),(cAliasSE1)->(E1_MOEDA),"S",dDatabase,,@nTotIrAbt,@nTotCsAbt,@nTotPisAbt,@nTotCofAbt,@nTotInsAbt)

cQuery	:= "SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR,E1_VENCREA, E1_EMIS1, R_E_C_N_O_ RECNO_ "
cQuery	+= " FROM "+RetSqlName("SE1")
cQuery	+= " WHERE E1_FILIAL = '"+cFilSE1+"'"
cQuery 	+= " AND E1_PREFIXO = '"+(cAliasSE1)->(E1_PREFIXO)+"'"
cQuery 	+= " AND E1_NUM = '"+(cAliasSE1)->(E1_NUM)+"'"
If lTitpaiSE1
	cTITPAI := PADR( (cAliasSE1)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA), TAMSX3("E1_TITPAI")[1] )
	cQuery 	+= " AND E1_TITPAI = '"+cTITPAI+"'"
Endif
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY R_E_C_N_O_ "
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasAFT , .T., .T. )

dbSelectArea(cAliasAFT)
While (cAliasAFT)->( !Eof() )
	cKey := cFilAFT + (cAliasAFT)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
	If (cAliasAFT)->E1_TIPO $ MVCFABT+MVIRABT+MVINABT+MVCSABT+MVPIABT+MVISABT+MVI2ABT
		aRecAFT := {}
		// carrega no array os registros ja existentes
		dbSelectArea("AFT")
		dbSetOrder(2)
		MsSeek(cKey )

		While !Eof() .And. cKey==AFT_FILIAL+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENTE+AFT_LOJA
			If AFT->AFT_REVISA == PmsAF8Ver(AFT->AFT_PROJET)
				aAdd(aRecAFT, AFT->(RecNo()))
			EndIf
			dbSkip()
		EndDo

		For nz:=1 to Len(aRatAFT[nx][2])
			If !aRatAFT[nx][2][nz][Len(aRatAFT[nx][2][nz])]
				dbSelectArea('AFT')
				nCount:=0
				If nz <= Len(aRecAFT)
					AFT->(dbGoto(aRecAFT[nz]))
					RecLock('AFT', .F.)
				Else
					RecLock('AFT', .T.)
					AFT->AFT_FILIAL	 := cFilAFT
				EndIf
			Else
				If nz <= Len(aRecAFT)
					MsGoto(aRecAFT[nz])
					RecLock("AFT",.F.,.T.)
			        dbDelete()
			        msUnLock()
				EndIf
				Loop
			EndIf

			AFT->AFT_PROJETO := aRatAFT[nx][2][nz][nPosProjet]
			AFT->AFT_TAREFA  := aRatAFT[nx][2][nz][nPosTask]

			// alterado o calculo para levar em consideracao
			// o rateio do valor do imposto
			// (valor do titulo rateado/valor do titulo) * valor do imposto
			AFT->AFT_VALOR1  := (nProp) * (cAliasAFT)->E1_VALOR

			AFT->AFT_VALOR2  := 0
			AFT->AFT_VALOR3  := 0
			AFT->AFT_VALOR4  := 0
			AFT->AFT_VALOR5  := 0
			AFT->AFT_REVISA  := aRatAFT[nx][2][nz][nPosRevisa]
			AFT->AFT_DATA    := StoD( (cAliasAFT)->E1_EMIS1 )
			AFT->AFT_FILIAL  := cFilAFT
			AFT->AFT_PREFIX  := (cAliasAFT)->E1_PREFIXO
			AFT->AFT_NUM     := (cAliasAFT)->E1_NUM
			AFT->AFT_PARCEL  := (cAliasAFT)->E1_PARCELA
			AFT->AFT_TIPO    := (cAliasAFT)->E1_TIPO
			AFT->AFT_CLIENTE := (cAliasAFT)->E1_CLIENTE
			AFT->AFT_LOJA    := (cAliasAFT)->E1_LOJA
			AFT->AFT_VENREA  := StoD( (cAliasAFT)->E1_VENCREA )

			MsUnlock()
			aAdd( aRecnoSE1 , (cAliasAFT)->(RECNO_) )
			/////////////////////////////////////////////////////////////////
			//
			// Integração com TOP, gera a apropriacao para o projeto.
			//
			/////////////////////////////////////////////////////////////////
			SLMPMSCOST(0, "AFT", dDatabase, AFT->AFT_PROJET, AFT->AFT_TAREFA, "", 0, AFT->AFT_VALOR1)
			/////////////////////////////////////////////////////////////////

		Next nx
	EndIf
	(cAliasAFT)->(dbSkip())
EndDo

For nz:=1 to Len(aRecnoSE1)
	SE1->( dbGoTo( aRecnoSE1[nz] ) )
	Reclock("SE1", .F.)
		SE1->E1_PROJPMS := "1"
	MsUnlock()
Next nz

(cAliasAFT)->(dbCloseArea())
RestArea(aAreaSE1)

Return

Function PmsAvalCal(cProjeto)
DEFAULT cProjeto := AF8->AF8_PROJET
If aScan( aProjets , { |x| x == cProjeto } )  ==  0
	LoadAEGAFY(cProjeto)
	aadd( aProjets , cProjeto)
Endif

Return

Function LoadAEGAFY(cProjeto, cRecurso)
Local aArea		:= GetArea()
Local cQuery		:= ''
Local cAliasExc	:= "EXCE"+getNextAlias()
Local cAliasAEG	:= RetSqlName("AEG")

DEFAULT cProjeto:= ''
DEFAULT cRecurso:= ''

If SuperGetMv("MV_PMSCALE" , .T. , .F. ) .AND. __lTopConn
	cQuery := " SELECT AEG_ITEM, AEG_RECURS,AEG_PROJET, AEG_DATAI, AEG_DATAF, AEG_HORAI, AEG_HORAF, AEG_HUTEIS, R_E_C_N_O_ AEG_RECNO "
	cQuery += " FROM "+cAliasAEG
	cQuery += " WHERE AEG_CODIGO = 'AFY' "
	cQuery += " AND AEG_TIPO = 'E'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY AEG_DATAI , AEG_ITEM , AEG_RECURS , AEG_PROJET "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasExc , .T. , .T. )

	While (cAliasExc)->(!EOF())
		dDtIni	:= StoD((cAliasExc)->(AEG_DATAI))
		dDtFim	:= StoD((cAliasExc)->(AEG_DATAF))
		If dDtIni <> dDtFim
			While dDtIni <= dDtFim
				If (nPos := aScan( aExcecoes, { |x| x[1] == dDtIni .and. x[2] == AEG_PROJET .and. x[5] != AEG_RECNO } ) ) > 0
					aExcecoes[nPos][4] += AEG_HUTEIS
				Elseif (nPos := aScan( aExcecoes, { |x| x[1] == dDtIni .and. x[5] == AEG_RECNO } ) ) == 0
					aAdd( aExcecoes, { dDtIni,AEG_PROJET, AEG_RECURS, AEG_HUTEIS , AEG_RECNO } )
				Endif
				dDtIni++
			EndDo
		Else
			If (nPos := aScan( aExcecoes, { |x| x[1] == dDtIni .and. x[2] == AEG_PROJET  .and. x[5] != AEG_RECNO } ) ) > 0
				aExcecoes[nPos][4] += AEG_HUTEIS
			Elseif (nPos := aScan( aExcecoes, { |x| x[1] == dDtIni .and.  x[5] == AEG_RECNO } ) ) == 0
				aAdd( aExcecoes, { dDtIni,AEG_PROJET, AEG_RECURS, AEG_HUTEIS , AEG_RECNO} )
			Endif
		Endif

		(cAliasExc)->(dbSkip())

	EndDo
Endif

RestArea(aArea)

Return .T.


Function PmsItvTRB(cCalend,aTrbs)

Local cAliasAEG	:= RetSqlName("AEG")
Local cFilAEG		:= xFilial("AEG")
Local cAlias		:= "AlIt"+GetNextAlias()
Local cAliasIT2	:= "IT2" +GetNextAlias()
Local cAliasITVL	:= "ITVL"+GetNextAlias()
Local cQryHrsUts	:= "UTS" +GetNextAlias()
Local cTotHrs		:= "TOT" +GetNextAlias()
Local cQuery		:= ""
Local aAliasItv	:= { cCalend, cAlias,cAliasIT2,cAliasITVL,cQryHrsUts,cTotHrs }
Local nX			:= 0
Local nTamTrbs	:= 0

DEFAULT aTrbs	:= {}

nTamTrbs	:= Len(aTrbs)

If nTamTrbs > 0

	For nX:=1 to nTamTrbs
		(aTrbs[nX][2])->( dbCloseArea() )
		(aTrbs[nX][3])->( dbCloseArea() )
		(aTrbs[nX][4])->( dbCloseArea() )
		(aTrbs[nX][5])->( dbCloseArea() )
		(aTrbs[nX][6])->( dbCloseArea() )
	Next nX

Else

	// Horas Uteis do calendário escolhido
	cQuery	:= "SELECT SUM(AEG_HUTEIS) HRS_UTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

	// Horas do dia da semana da data Início
	cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_SEMANA, AEG_PRECIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY AEG_SEMANA , AEG_ITEM "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasITVL , .T. , .T. )

	// Horas do dia da semana da data Início
	cQuery	:= "SELECT AEG_HORAI,AEG_HORAF, AEG_SEMANA, AEG_PRECIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " ORDER BY AEG_SEMANA DESC, AEG_ITEM DESC "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasIT2 , .T. , .T. )

	// Horas uteis por dia da semana
	cQuery	:= "SELECT AEG_SEMANA, SUM(AEG_HUTEIS) HRSUTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	cQuery	+= " GROUP BY AEG_SEMANA "
	cQuery	+= " ORDER BY AEG_SEMANA "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryHrsUts , .T. , .T. )

	// Horas Uteis do calendário escolhido
	cQuery	:= "SELECT SUM(AEG_HUTEIS) HRS_UTEIS FROM "+cAliasAEG
	cQuery	+= " WHERE AEG_FILIAL = '"+cFilAEG+"' AND AEG_CODIGO = '"+cCalend+"' "
	cQuery 	+= " AND AEG_TIPO = 'C'"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTotHrs, .T., .T. )

Endif

Return aAliasItv

Function PmsUtsTRB(cCalend,aTrbs)

Local cQuery		:= ""
Local aAliasItv	:= { cCalend, "" }
Local nX			:= 0
Local nTamTrbs	:= 0

DEFAULT aTrbs	:= {}

If SuperGetMv("MV_PMSCALE" , .T. , .F. )
	
	nTamTrbs := Len(aTrbs)
	
	If nTamTrbs > 0
	
		For nX:=1 to nTamTrbs
			(aTrbs[nX][2])->( dbCloseArea() )
		Next nX
	
	Else
		aAliasItv[2] := "U"+GetNextAlias()
		
		// Horas uteis por dia da semana
		cQuery	:= "SELECT AEG_SEMANA, SUM(AEG_HUTEIS) HRSUTEIS FROM "+RetSqlName("AEG")
		cQuery	+= " WHERE AEG_FILIAL = '"+xFilial("AEG")+"' AND AEG_CODIGO = '"+cCalend+"' "
		cQuery	+= " AND AEG_TIPO = 'C' "
		cQuery	+= " AND D_E_L_E_T_ = ' ' "
		cQuery	+= " GROUP BY AEG_SEMANA "
		cQuery	+= " ORDER BY AEG_SEMANA"
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), aAliasItv[2] , .T. , .T. )
	
	Endif
EndIf
Return aAliasItv


Function PmsImpB(aDadosTsk,aResources,lPOC, nVersao, aRecAF9, nAF9,aRecAmarr)

Local nThread   := SuperGetMv("MV_PMSTHRD",.T.,4)
Local nZ		:= 0
Local nX		:= 1
Local lRet		:= .T.
Local lExit 	:= .F.
Local nKilled	:= 0
Local aNewArray	:= {}
Local nQtdpTrd	:= 1
Local nCont		:= 0
Local nResto	:= 0
Local nRc		:= 0
Local cProjeto	:= AF8->AF8_PROJET
Local cRevisa	:= AF8->AF8_REVISA
Local nTamTsk	:= Len(aDadosTsk)
Local aTeste	:= {}
Local aThreads	:= {}
Local aRecnew	:= {}
Local nProcessado := 0
Private oGrid


nQtdpTrd := NoRound( ( nAF9 / nThread ) ,0 ) //total de registro dividido pelas treads = qtd de cada tread
nResto	 := nAF9 - ( nQtdpTrd * nThread )

While ( nAF9 <> 0 )
	aadd( aNewArray , {})
	aadd( aRecnew , {})
	nCont++
	nProcessado := 0
	For nX:=nx to nTamTsk

		If aDadosTsk[nx,22] == "AF9"

			nRc++ // controle

			aadd( aRecnew[nCont] , aRecAF9[nRc] )
			aadd( aNewArray[nCont] , aDadosTsk[nX] )
			nProcessado++
			If Len(aRecnew[nCont]) == nQtdpTrd
				nx++
				Exit
			Endif
		Endif

	Next nX

	nAF9 -= nProcessado

	Loop

EndDo


If (nCont == 0) .and. ( nResto > 0)
	aadd( aRecnew , {})
	nCont++
Endif
If nAF9 > 0
	For nX:=nx To nTamTsk
		If aDadosTsk[nx,24] == "AF9"
			nRc++ // controle
			aadd( aRecnew[nCont] , aRecAF9[nRc] )
			aadd( aNewArray[nCont] , aDadosTsk[nX] )
		Endif
	Next nX
Endif
nThread := Len(aRecnew)


oGrid := FWIPCWait():New("PMSIMPORT",4000)
oGrid:SetThreads(nThread)
oGrid:SetEnvironment(cEmpAnt,cFilAnt)
oGrid:Start("PMSCALCAMAR")
//SetProc(nThread)
For nX := 1 To nThread
	IncProc(STR0157) // "Iniciando threads de Grava amarrações..."
	aTeste	:= {}
	aTeste := aClone(aNewArray[nX])
	lRet 	:= oGrid:Go(STR0153,{aTeste , aResources, lPOC, nVersao, cProjeto, nX, aRecnew[nX], aRecAmarr,cRevisa,aDadosTsk} ) //"Chamando reprocessamento de saldos"
	If !lRet
		Exit
	EndIf
	Sleep(1000)	//Aguarda 2 seg para abertura da thread
Next nX


//Sleep(4000*nThread)//Aguarda todas as threads abrirem para tentar fechar
cProjeto := alltrim(cProjeto)
//SetProc(nThread)

While !lExit
	nKilled := 0
	For nZ := 1 To nThread
		If LockByName("PMSIMPORT"+cProjeto+"_"+str(nz),.T.,.T.)
			aadd(aThreads, nZ)
			oGrid:RemoveThread(.T.)
			nKilled += 1
			UnLockByName("PMSIMPORT"+cProjeto+"_"+str(nz),.T.,.T.)
		Endif
		IncProc(STR0156) // Grava amarrações via multi-thread
	Next nZ

	If nKilled == nThread
		Exit
	EndIf
	Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram
EndDo
Sleep(15000)
oGrid:Stop()
FreeObj(oGrid)

Return

Function PmsDtsAtu(aRecAF9,MV_PMSTX30)

Local nThread   := SuperGetMv("MV_PMSTHRD",.T.,4)
Local nZ		:= 0
Local nX		:= 0
Local lRet		:= .T.
Local lExit 	:= .F.
Local nKilled	:= 0
Local nQtdpTrd	:= 1
Local nCont		:= 0
Local nResto	:= 0
Local aRecnew	:= {}
Local cQuery	:= ""
Local cAliasX	:= "PTHREAD"+getNextAlias()
Local cProjeto	:= ALLTRIM(AF8->AF8_PROJET)

Private oGrid


cQuery	:= "SELECT COUNT(R_E_C_N_O_) QTDRECNO FROM "+RetSqlName("AF9")
cQuery	+= " WHERE AF9_FILIAL = '"+xFilial("AF9")+"'"
cQuery 	+= " AND AF9_PROJET = '"+AF8->AF8_PROJET+"'"
cQuery 	+= " AND AF9_REVISA = '"+AF8->AF8_REVISA+"'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasX, .T., .T. )

nQtdpTrd	:= NoRound( (cAliasX)->(QTDRECNO) / nThread , 0 )
nResto		:= (cAliasX)->(QTDRECNO) - (nThread * nQtdpTrd)
(cAliasX)->( dbCloseArea() )

cAliasX	:= "PTHREAD"+getNextAlias()
cQuery	:= "SELECT R_E_C_N_O_ RECNO_ , AF9_TAREFA FROM "+RetSqlName("AF9")
cQuery	+= " WHERE AF9_FILIAL = '"+xFilial("AF9")+"'"
cQuery 	+= " AND AF9_PROJET = '"+AF8->AF8_PROJET+"'"
cQuery 	+= " AND AF9_REVISA = '"+AF8->AF8_REVISA+"'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY AF9_TAREFA "

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasX, .T., .T. )

While (cAliasX)->( !EOF() ) .and. (nThread >= nX)
	nCont++
	If nCont > nQtdpTrd
		nCont := 0
		Loop
	Else
		If nCont == 1 //primeiro do array
			aadd( aRecnew , {})
			nX++
		Endif
		aAdd( aRecnew[nX] , (cAliasX)->( RECNO_ ) )
	Endif

	(cAliasX)->( dbSkip() )
EndDo

If (nCont == 0) .and. (cAliasX)->( !EOF() )
	aadd( aRecnew , {})
	nCont++
Endif

While (cAliasX)->( !EOF() )
	aAdd( aRecnew[nCont] , (cAliasX)->( RECNO_ ) )
	(cAliasX)->( dbSkip() )
EndDo

(cAliasX)->( dbCloseArea() )
nThread := Len(aRecnew)

oGrid := FWIPCWait():New("PMSATUDTS_",10000)
oGrid:SetThreads(Len(aRecnew))
oGrid:SetEnvironment(cEmpAnt,cFilAnt)
oGrid:Start("PmsCalcDts")

For nX := 1 To nThread
	IncProc(STR0155) //"Iniciando threads de Datas Previstas..."
	lRet 	:= oGrid:Go(STR0153,{MV_PMSTX30, aRecAF9, aRecnew[nX],nX,cProjeto} ) //"Chamando reprocessamento de saldos"
	If !lRet
		Exit
	EndIf
	Sleep(4000)
Next nX

Sleep(4000*nThread)

While !lExit
	nKilled := 0
	For nZ := 1 To nThread
		If LockByName("PMSATUDTS_"+cProjeto+"_"+Alltrim(str(nz)),.T.,.T.)
			oGrid:RemoveThread(.T.)
			nKilled += 1
			UnLockByName("PMSATUDTS_"+cProjeto+"_"+Alltrim(str(nz)),.T.,.T.)
		Endif
	Next nZ

	If nKilled == nThread
		Exit
	EndIf
	IncProc(STR0154) // "Gravando datas previstas via multi-thread..."
	Sleep(3000)
EndDo
Sleep(4000*nThread)
oGrid:Stop()
FreeObj(oGrid)

Return


Function PmsThrDts(cFilAFC,cProjeto,cRevisa)

Local nThread   := SuperGetMv("MV_PMSTHRD",.T.,4)
Local nZ		:= 0
Local nX		:= 0
Local lRet		:= .T.
Local lExit 	:= .F.
Local nKilled	:= 0
Local nProcessado := 1
Local nQtdpTrd	:= 1
Local nCont		:= 0
Local nResto	:= 0
Local nRc		:= 0
Local nContador := 0
Local aEDTs		:= {}
Local aRecnew	:= {}
Local cQuery	:= ""
Local cAliasX	:= "PTHRREAL"+getNextAlias()

Private oGrid

DEFAULT cFilAFC := xFilial("AFC")
DEFAULT cProjeto:= AF8->AF8_PROJET
DEFAULT cRevisa	:= AF8->AF8_REVISA


cQuery	:= " SELECT AFC_EDT, AFC_NIVEL, AFC_CALEND FROM "+RetSqlName("AFC")
cQuery	+= " WHERE AFC_FILIAL = '"+cFilAFC+"'"
cQuery 	+= " AND AFC_PROJET = '"+cProjeto+"'"
cQuery 	+= " AND AFC_REVISA = '"+cRevisa+"'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY AFC_EDT DESC, AFC_NIVEL DESC "
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasX, .T., .T. )

While (cAliasX)->( !EOF() )

	aAdd( aEDTs , { (cAliasX)->( AFC_EDT ) , (cAliasX)->( AFC_CALEND ) } )
	nContador++
	(cAliasX)->( dbSkip() )
EndDo
nQtdpTrd:= NoRound( nContador / nThread , 0)
nLoop	:= nThread * nQtdpTrd
nResto	:= nContador - nLoop
nControl:= nLoop
(cAliasX)->( dbCloseArea() )

While ( nControl <> 0 )
	aadd( aRecnew , {})
	nCont++
	nProcessado	:= 0
	While (nProcessado <= nQtdpTrd) .and. ( nRc <= nLoop )

		nRc++
		nProcessado++
		aadd( aRecnew[nCont] , aEDTs[nRc] )

		If Len(aRecnew[nCont]) == nQtdpTrd
			Exit
		Endif

	EndDo

	nControl -= nProcessado

	Loop

EndDo

If (nCont == 0) .and. (nResto > 0)
	aadd( aRecnew , {})
	nCont++
Endif
For nX:=1 To nResto
	nRc++
	aadd( aRecnew[nCont] , aEDTs[nRc] )
Next nX

nThread := Len(aRecnew)
oGrid := FWIPCWait():New("PMSCALDTS_",10000)
oGrid:SetThreads(nThread)
oGrid:SetEnvironment(cEmpAnt,cFilAnt)
oGrid:Start("PmaCalcAtu")

For nX := 1 To Len(aRecnew)
	IncProc(STR0152) //"Iniciando threads de Datas Realizadas..."
	lRet 	:= oGrid:Go(STR0153,{cFilAFC, cProjeto, cRevisa,aRecnew[nX],nX} ) //"Chamando rotina padrão..."
	If !lRet
		Exit
	EndIf
	Sleep(4000)
Next nX

Sleep(4000*nThread)

While !lExit
	nKilled := 0
	For nZ := 1 To Len(aRecnew)
		If LockByName("PMSCALDTS_"+cProjeto+"_"+str(nz),.T.,.T.)
			oGrid:RemoveThread(.T.)
			nKilled += 1
			UnLockByName("PMSCALDTS_"+cProjeto+"_"+str(nz),.T.,.T.)
		Endif
	Next nZ
	IncProc(STR0151) // Grava amarrações via multi-thread
	If nKilled == nThread
		Exit
	EndIf
	Sleep(3000)
EndDo
Sleep(15000)
oGrid:Stop()
FreeObj(oGrid)

Return

/*/{Protheus.doc} AFXIniUsr
Funcao para inicialização do campo AFX_NOME
@return ${return}, ${return_description}

@author Pedro Pereira Lima
@since 27-08-2014
@version 1.0
/*/
Function AFXIniUsr()
Local cRet := ""

If Empty(M->AFX_USER)
	//Caso o campo em memória esteja vazio, verifico se a tabela está posicionada
	//daí obtenho o valor diretamente do campo AFX->AFX_USER
	If Type("AFX->AFX_USER") == "C" .And. !Empty(AFX->AFX_USER)
		cRet := UsrRetName(AFX->AFX_USER)
	Else
		//Caso a verificação do campo AFX_USER falhe, verifico o campo AFX_GRPUSR
		If !Empty(M->AFX_GRPUSR)
			cRet := GrpRetName(M->AFX_GRPUSR)
		ElseIf Type("AFX->AFX_GRPUSR") == "C" .And. !Empty(AFX->AFX_GRPUSR)
			cRet := GrpRetName(AFX->AFX_GRPUSR)
		EndIf
	EndIf
Else
 cRet := UsrRetName(M->AFX_USER)
EndIf                                                       

Return cRet

/*/{Protheus.doc} AFVIniUsr
Funcao para inicialização do campo AFV_NOME
@return ${return}, ${return_description}

@author Pedro Pereira Lima
@since 27-08-2014
@version 1.0
/*/
Function AFVIniUsr()
Local cRet := ""

If Empty(M->AFV_USER)
	//Caso o campo em memória esteja vazio, verifico se a tabela está posicionada
	//daí obtenho o valor diretamente do campo AFV->AFV_USER
	If Type("AFV->AFV_USER") == "C" .And. !Empty(AFV->AFV_USER)
		cRet := UsrRetName(AFV->AFV_USER)
	Else
		//Caso a verificação do campo AFV_USER falhe, verifico o campo AFV_GRPUSR
		If !Empty(M->AFV_GRPUSR)
			cRet := GrpRetName(M->AFV_GRPUSR)
		ElseIf Type("AFV->AFV_GRPUSR") == "C" .And. !Empty(AFV->AFV_GRPUSR)
			cRet := GrpRetName(AFV->AFV_GRPUSR)
		EndIf
	EndIf
Else
 cRet := UsrRetName(M->AFV_USER)
EndIf                                              

Return cRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PmsValidOp

Caso seja informada OP na execauto deve verificar se é a mesma da SCP, 
quando integrado com PMS.
@sample	PmsValidOp() 

@return lRet, Lógico  - Ordem de Produção OK para Execauto

@author	SQUAD CRM/Faturamento
@since	01/12/2017
@version 12.1.17
/*/ 
//------------------------------------------------------------------------------
Function PmsValidOp(aAutoSD3, cOrdemPrd )
	Local lRet		:= .T.
	Local nPosOp	:= 0
	 
	Default aAutoSD3	:= {}
	Default cOrdemPrd	:=  ''
	
	nPosOP := aScan(aAutoSD3,{|x| Alltrim(x[1]) == 'D3_OP' })
	If nPosOP <> 0
		If Alltrim( aAutoSD3[nPosOP,2] ) <> Alltrim( cOrdemPrd )
			Help('  ',1, 'PMSVALIDOP')	
			lRet := .F.
		EndIf
	EndIf
	
Return lRet	

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PmsGatSD3

Retono o conteudo do contra dominio do gatilho.
@sample	PmsGatSD3() 

@return cRet - conteudo do campo contra dominio do gatilho

@author	SQUAD CRM/Faturamento
@since	30/11/2017
@version 12.1.17
/*/ 
//------------------------------------------------------------------------------
Function PmsGatSD3(cCDomin)
	Local 	cRet		:= ''
	Local 	lAutomato	:= IIF(  (Type("l185Auto") == "L" .AND. l185Auto) .OR. (Type("l250Auto") == "L" .AND. l250Auto), .T., .F.)
	Default cCDomin 	:= ''
	
	Do Case
		Case cCDomin == 'D3_PROJPMS' //x7_regra IIF( FindFunction('PmsGatSD3'), PmsGatSD3('D3_PROJPMS'),SPACE(LEN(SD3->D3_PROJPMS)))                                                                          
			If lAutomato
				cRet:= M->D3_PROJPMS
			Else	
				cRet := SPACE( Len(SD3->D3_PROJPMS) )
			EndIf
		Case cCDomin == 'D3_TASKPMS' //IIF( FindFunction('PmsGatSD3'), PmsGatSD3('D3_TASKPMS'), SPACE(LEN(SD3->D3_TASKPMS)) )   
			If lAutomato
				cRet:= M->D3_TASKPMS
			Else
				cRet := SPACE( Len(SD3->D3_TASKPMS) )
			EndIf
		Case cCDomin == 'D3_OP' ////IIF( FindFunction('PmsGatSD3'), PmsGatSD3('D3_OP'), SPACE(LEN(SD3->D3_OP)) )
			If lAutomato
				If Empty(M->D3_OP)
					cRet:= SCP->CP_OP
				Else
					cRet:= M->D3_OP
				EndIf
			Else
				cRet := SPACE( Len(SD3->D3_OP) )
			EndIf		
		EndCase
Return cRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} VldMovPMS

Valida a Quantidade Movimentada no PMS

@param cCodPrj	,	Caracter,	Código do Projeto utilizado
@param cTarefa	,	Caracter,	Código da Tarefa do Projeto
@param cTM		,	Caracter,	Tipo de Movimentação Utilizada
@param cProduto	,	Caracter,	Código do Produto Utilizado
@param nQuant	,	Caracter,	Quantidade Requisitada/Devolvida
@param cFunc	,	Caracter,	Função utilizada

@sample	VldMovPMS(M->D3_PROJPMS, M->D3_TASKPMS, M->D3_TM, M->D3_COD, M->D3_QUANT, "MATA240")

@return lRet - Valida se a quantidade movimentada é valida

@author	SQUAD CRM/Faturamento
@since	23/10/2018
@version 12.1.17
/*/ 
//------------------------------------------------------------------------------

Function VldMovPMS(cCodPrj, cTarefa, cTM, cProduto, nQuant, cFunc)
	Local lRet		:= .T.
	Local aArea		:= {}

	Default cCodPrj	:= ""
	Default cTarefa	:= ""
	Default cTM		:= ""
	Default cProduto:= ""
	Default nQuant	:= 0
	Default cFunc	:= ""

	If cFunc == "MATA240" .Or. cFunc == "MATA241"
		aArea		:= GetArea()
		lRet := VldMovInt(cCodPrj, cTarefa, cTM, cProduto, nQuant, cFunc)
		RestArea(aArea)
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} VldMovInt

Valida Movimentação Interna

@param cCodPrj	,	Caracter,	Código do Projeto utilizado
@param cTarefa	,	Caracter,	Código da Tarefa do Projeto
@param cTM		,	Caracter,	Tipo de Movimentação Utilizada
@param cProduto	,	Caracter,	Código do Produto Utilizado
@param nQuant	,	Caracter,	Quantidade Requisitada/Devolvida
@param cFunc	,	Caracter,	Função utilizada

@sample	VldMovInt(cCodPrj, cTarefa, cTM, cProduto, nQuant, cFunc)

@return lRet - Valida a quantidade e produtos requisitados pela rotina MATA250 e MATA251

@author	SQUAD CRM/Faturamento
@since	23/10/2018
@version 12.1.17
/*/ 
//------------------------------------------------------------------------------

Static Function VldMovInt(cCodPrj, cTarefa, cTM, cProduto, nQuant, cFunc)
	Local aAreaAF8	:= {}
	Local lExitProd	:= .F.
	Local lRet		:= .T.
	Local lVldProd	:= SuperGetMV("MV_VLPRPMS",.F.,.F.)
	Local lVldQtd	:= SuperGetMV("MV_VLQTPMS",.F.,.F.)

	If lVldQtd .Or. lVldProd
		If !(IsInCallStack("A241GRAVA"))
			If !Empty(cCodPrj) .And. !Empty(cTarefa)
				If  !Empty(cTM) .And. !Empty(cProduto) .And. nQuant > 0
					aAreaAF8	:= AF8->(GetArea())
					
					AF8->(DbSetOrder(1))
					If AF8->(DbSeek(xFilial("AF8") + cCodPrj))
						If lVldProd
							lExitProd := VldProd(cCodPrj, cTarefa, cProduto)
						EndIf
						If (lExitProd .Or. !lVldProd) 
							If lVldQtd .And. cTM < '500'
								lRet := VldQtd(cCodPrj, cTarefa, cProduto, nQuant, cFunc)
							EndIf
						Else 
							Help(NIL, NIL, "VldMovPMS", NIL, STR0166 + STR0029 + AllTrim(cProduto), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0167}) //"O Produto não pertence ao Projeto.- "Informe uma produto válido"" 
							lRet	:= .F.
						EndIf
					EndIf

					RestArea(aAreaAF8)

				Else
					Help(NIL, NIL, "VldMovPMS", NIL, STR0168, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0169}) //"Produtos com integração com PMS precisam possuir os campos Projeto, Tarefa, TM, Produto e Quantidade preenchidos"
					lRet	:= .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} VldProd

Valida Movimentação Interna

@param cCodPrj	,	Caracter,	Código do Projeto utilizado
@param cTarefa	,	Caracter,	Código da Tarefa do Projeto
@param cProduto	,	Caracter,	Código do Produto Utilizado

@sample	VldProd(cCodPrj, cTarefa, cProduto)

@return lRet - Valida a o produto utilizado

@author	SQUAD CRM/Faturamento
@since	23/10/2018
@version 12.1.17
/*/ 
//------------------------------------------------------------------------------
Static Function VldProd(cCodPrj, cTarefa, cProduto)
	Local aAreaSFA	:= AFA->(GetArea())
	Local cFilSFA	:= xFilial("AFA")
	Local lRet	:= .F.

	AFA->(DbSetOrder(5))
	If AFA->(DbSeek(cFilSFA + cCodPrj + AF8->AF8_REVISA + cTarefa))
		While AFA->(AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA) == cFilSFA + cCodPrj + AF8->AF8_REVISA + cTarefa
			If AFA->AFA_PRODUT == cProduto
				lRet := .T.
				Exit
			EndIf
			AFA->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSFA)
Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} VldProd

Valida Movimentação Interna

@param cCodPrj	,	Caracter,	Código do Projeto utilizado
@param cTarefa	,	Caracter,	Código da Tarefa do Projeto
@param cTM		,	Caracter,	Tipo de Movimentação Utilizada
@param cProduto	,	Caracter,	Código do Produto Utilizado
@param nQuant	,	Caracter,	Quantidade Requisitada/Devolvida
@param cFunc	,	Caracter,	Função utilizada

@sample	VldQtd(cCodPrj, cTarefa, cProduto, nQuant, cFunc)

@return lRet - Valida a o produto utilizado

@author	SQUAD CRM/Faturamento
@since	23/10/2018
@version 12.1.17
/*/ 
//------------------------------------------------------------------------------
Static Function VldQtd(cCodPrj, cTarefa, cProduto, nQuant, cFunc)
	Local aAreaSD3	:= SD3->(GetArea())
	Local lRet		:= .T.
	Local nQtdD3	:= 0
	Local nPos		:= 0

	If cFunc == "MATA241"
		nQuant := 0
		While (nPos := aScan(aCols,{|x| x[nPosProj] == cCodPrj .And. x[nPosTarefa] == cTarefa .And. x[nPosCod] == cProduto}, nPos + 1)) > 0
			If !aCols[nPos,Len(aHeader)+1]
				nQuant += aCols[nPos,nPosQuant]
			EndIf
		EndDo
	EndIf
	SD3->(DbSetOrder(10))
	If SD3->(DbSeek(xFilial("SD3") + cCodPrj + cTarefa + cProduto))
		While SD3->(D3_FILIAL + D3_PROJPMS + D3_TASKPMS + D3_COD) == xFilial("SD3") + cCodPrj + cTarefa + cProduto
			If SD3->D3_TM < '500'
				nQtdD3 -= SD3->D3_QUANT
			Else
				nQtdD3 += SD3->D3_QUANT
			EndIf
			SD3->(DbSkip())
		EndDo
	EndIf
	If nQtdD3 - nQuant < 0
		Help(NIL, NIL, "VldMovPMS", NIL, STR0170 + AllTrim(cProduto) + STR0171 + cValToChar(nQtdD3) + STR0172 + cValToChar(nQuant), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0173}) //Quantidade devolvida para o Produto " é maior do que a quantidade requisitada. Quantidade Requisitada: "
		lRet := .F.
	EndIf

	RestArea(aAreaSD3)
Return lRet
