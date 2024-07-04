#INCLUDE "VEIVM500.ch"
#Include "PROTHEUS.CH"
#DEFINE nMaxRight (oDlgAva:nClientWidth/2)
#DEFINE nMaxHeight (oDlgAva:nClientHeight/2)
#DEFINE nMetade (oDlgAva:nClientHeight/4)
#DEFINE nMaxRightF (oFolderAva:nClientWidth/2)-2 
#DEFINE nMaxHeightF1 (oFolderAva:nClientHeight/2)-12
#DEFINE nMaxHeightF2 (oFolderAva:nClientHeight/2)-32
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ VEIVM500 ณ Autor ณ  Ricardo Farinelli    ณ Data ณ 22/10/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Avaliacao de Veiculos                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Gestao de Concessionarias                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION VEIVM500

Private aRotina := MenuDef()
Private cCadastro := STR0006 //"Avaliacao de Veiculos"
dbSelectArea("VA7")
dbSetOrder(1)        
mBrowse( 6, 1,22,75,"VA7")
Return
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVM500I บAutor  ณRicardo Farinelli   บ Data ณ  10/22/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTrata a manutencao da avaliacao de veiculos usados          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VEIVM500I(cAlias1,nReg,nOpc)
Local cCadastro := STR0006 //"Avaliacao de Veiculos"
Local aButtons	 := {{"BUDGETY",{||VEIVR080()},OemToAnsi(STR0007)}} //"Ficha de Avaliacao"
Local oDlgAva,oBtnAva
Local nOpcG
Local nOpcE
Local nOpcao := 0
Local aCpoEnchoice := {}
Local cLinOk := "VM500LINOK()", cTudoOk := "VM500TUDOK()", cFieldOk := "VM500FILOK()"
Local nwnk   := 0
Private oEnchoAva 
Private nOpcX := nOpc
Private oGetDados1,oGetDados2,oGetDados3,oGetDados4
Private aHeader := {}, aCols := {}, aHeader1 := {},aCols1 := {}
Private aHeader2 := {},aCols2 := {},aHeader3 := {},aCols3 := {}
Private aHeader4 := {},aCols4 := {}
Private aTELA[0][0],aGETS[0] 
//Private bCampo   := { |nCPO| Field(nCPO) }	
Private oFolderAva
Private oPrcIni,nPrcIni,oPrcMax,nPrcMax,oPrcPag,nPrcPag,oPrcOpc,nPrcOpc,oPrcAva,nPrcAva
Private oPrcOco1,nPrcOco1,oPrcOco2,nPrcOco2,oPrcMin,nPrcMin
Private oBtnNew
Private cCodigo := ""	// esta variavel eh utilizada no filtro da consulta va0 para poder filtrar
 					 			// pelo codigo pai do item generico na folder de checklist da avaliacao
Private atelas := {} // Controle de angulos de visualizacao de figuras
Private cCodIte := "" // vide cCodigo
RegToMeMory("VA7",Inclui)
nOpcG := nOpcX
nOpcE := nOpcX

VM500ClrV() // Limpa variaveis totalizadoras  
VM500Ench(aCpoEnchoice) // Monta o Vetor com os campos para a Enchoice
VM500aHeader("VAC","aHeader1","VAC_CODAVA") // Monta aHeader/aCols para o VAC
VM500aCols("VAC",1,xFilial("VAC")+VA7->VA7_CODAVA,"aCols1","VAC_FILIAL+VAC_CODAVA") // Monta aCols para o VAC
VM500aHeader("VA9","aHeader2","VA9_CODAVA") // Monta aHeader/aCols para o VA9
VM500aCols("VA9",1,xFilial("VA9")+VA7->VA7_CODAVA,"aCols2","VA9_FILIAL+VA9_CODAVA") // Monta aCols para o VA9
VM500aHeader("VAD","aHeader3","VAD_CODAVA") // Monta aHeader/aCols para o VA9
VM500aCols("VAD",1,xFilial("VAD")+VA7->VA7_CODAVA,"aCols3","VAD_FILIAL+VAD_CODAVA") // Monta aCols para o VA9
VM500aHeader("VAA","aHeader4","VAA_CODAVA") // Monta aHeader/aCols para o VAA
VM500aCols("VAA",1,xFilial("VAA")+VA7->VA7_CODAVA,"aCols4","VAA_FILIAL+VAA_CODAVA") // Monta aCols para o VAA
aCols 	:= aClone(aCols4)
aHeader 	:= aClone(aHeader4)
// Carrega as descricoes da getdados da folder de checklist
If !Inclui
	For nwnk := 1 To Len(aCols)
		// Carrega a Descricao do Grupo para o campo do aCols
		aCols[nwnk,FG_POSVAR("VAA_DESGRU")] := VM500Desc("VA0",aCols[nwnk,FG_POSVAR("VAA_CODGRU")],1,FG_POSVAR("VAA_DESGRU"),"VA0_DESCRI")
		// Carrega a Descricao do Item do Grupo Generico para o campo do aCols
		aCols[nwnk,FG_POSVAR("VAA_DESITE")] := VM500Desc("VA0",aCols[nwnk,FG_POSVAR("VAA_ITEM")],1,FG_POSVAR("VAA_DESITE"),"VA0_DESCRI")
		// Carrega a Descricao do Item da Avaria para o campo do aCols
		aCols[nwnk,FG_POSVAR("VAA_DESAVA")] := VM500Desc("VA4",aCols[nwnk,FG_POSVAR("VAA_AVARIA")],1,FG_POSVAR("VAA_DESAVA"),"VA4_DESCRI")
	Next	
Endif
aCols4	:= aClone(aCols)
aHeader4	:= aClone(aHeader)

DEFINE MSDIALOG oDlgAva FROM 000,000 TO 337,600 TITLE OemToAnsi(cCadastro) OF oMainWnd PIXEL

DEFINE SBUTTON oBtnNew TYPE 01 FROM 5000,5000 OF oDlgAva ACTION .T.
oEnchoAva:= MsMGet():New("VA7" ,nReg,nOpcX,,,,aCpoEnchoice,{015,001,nMetade,nMaxRight},,,,,,oDlgAva,,.T.,.F.)
@ nMetade,001 FOLDER oFolderAva OF oDlgAva PROMPT OemToAnsi(STR0008),; //"Aparencia Geral"
							OemToAnsi(STR0009),; 	 //"Opcionais"
							OemToAnsi(STR0010),; //"Ocorrencias"
							OemToAnsi(STR0011),; //"Checklist"
							OemToAnsi(STR0012) PIXEL SIZE nMaxRight-2,nMetade //"Resumo"
oFolderAva:bChange := { || VM500changeF() }

aHeader := aClone(aHeader1) // Salva o aHeader Atual
aCols   := aClone(aCols1)	  // Salva o aCols   Atual

oGetDados1  := MSGetDados():New(000,000,nMaxHeightF1,nMaxRightF, nOpcX,cLinOk,cTudoOk,"",If(nOpcX > 2 .and. nOpcX < 5,.t.,.f.),,1,,,cFieldOk,,,,oFolderAva:aDialogs[1])
oGetDados1:oBrowse:bGotFocus        :={|| VM500ENTFOC("1")}
oGetDados1:oBrowse:bLostFocus       :={|| VM500SAIFOC("1")}
oGetDados1:oBrowse:Default()

aHeader := aClone(aHeader2) // Salva o aHeader Atual
aCols   := aClone(aCols2)	  // Salva o aCols   Atual

oGetDados2  := MSGetDados():New(000,000,nMaxHeightF1,nMaxRightF, nOpcX,cLinOk,cTudoOk,"",If(nOpcX > 2 .and. nOpcX < 5,.t.,.f.),,1,,,cFieldOk,,,,oFolderAva:aDialogs[2])
oGetDados2:oBrowse:bGotFocus        :={|| VM500ENTFOC("2")}
oGetDados2:oBrowse:bLostFocus       :={|| VM500SAIFOC("2")}
oGetDados2:oBrowse:Default()

aHeader := aClone(aHeader3) // Salva o aHeader Atual
aCols   := aClone(aCols3)	  // Salva o aCols   Atual

oGetDados3  := MSGetDados():New(000,000,nMaxHeightF1,nMaxRightF, nOpcX,cLinOk,cTudoOk,"",If(nOpcX > 2 .and. nOpcX < 5,.t.,.f.),,1,,,cFieldOk,,,,oFolderAva:aDialogs[3])
oGetDados3:oBrowse:bGotFocus        :={|| VM500ENTFOC("3")}
oGetDados3:oBrowse:bLostFocus       :={|| VM500SAIFOC("3")}
oGetDados3:oBrowse:Default()

aHeader := aClone(aHeader4) // Salva o aHeader Atual
aCols   := aClone(aCols4)	  // Salva o aCols   Atual

oGetDados4  := MSGetDados():New(000,000,nMaxHeightF2,nMaxRightF, nOpcX,cLinOk,cTudoOk,"",If(nOpcX > 2 .and. nOpcX < 5,.t.,.f.),,1,,,cFieldOk,,,,oFolderAva:aDialogs[4])
oGetDados4:oBrowse:bGotFocus        :={|| VM500ENTFOC("4")}
oGetDados4:oBrowse:bLostFocus       :={|| VM500SAIFOC("4")}
oGetDados4:oBrowse:Default()

aHeader := aClone(aHeader1) // Salva o aHeader Atual
aCols   := aClone(aCols1)	  // Salva o aCols   Atual

DEFINE SBUTTON oBtnAva	TYPE 15 FROM nMaxHeightF2+3,nMaxRightF-30 OF oFolderAva:aDialogs[4] ENABLE ONSTOP STR0013 ACTION 	VM500AVAVI() When (Inclui .or. Altera)  //"Avaliacao Visual"

@ 005,004 SAY OemToAnsi(STR0014) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Preco Inicial:"
@ 005,065 MSGET oPrcIni VAR nPrcIni Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 

@ 020,004 SAY OemToAnsi(STR0015) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Preco Minimo:"
@ 020,065 MSGET oPrcMin VAR nPrcMin Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 
         
@ 035,004 SAY OemToAnsi(STR0016) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Preco Maximo:"
@ 035,065 MSGET oPrcMax VAR nPrcMax Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 

@ 050,004 SAY OemToAnsi(STR0017) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Preco Sugerido:"
@ 050,065 MSGET oPrcPag VAR nPrcPag Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 

@ 005,170 SAY OemToAnsi(STR0018) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Preco Opcionais:"
@ 005,235 MSGET oPrcOpc VAR nPrcOpc Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 

@ 020,170 SAY OemToAnsi(STR0019) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Ocorrencias (+):"
@ 020,235 MSGET oPrcOco1 VAR nPrcOco1 Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 

@ 035,170 SAY OemToAnsi(STR0020) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Ocorrencias (-):"
@ 035,235 MSGET oPrcOco2 VAR nPrcOco2 Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 

@ 050,170 SAY OemToAnsi(STR0021) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL  //"Avarias:"
@ 050,235 MSGET oPrcAva VAR nPrcAva Picture PesqPict("VA7","VA7_PRETAB") When (.F.) SIZE 60,8 OF oFolderAva:aDialogs[5] PIXEL 

ACTIVATE MSDIALOG oDlgAva CENTER ON INIT Enchoicebar(oDlgAva,{||nOpcao := 1,If(!Obrigatorio(aGets,aTela),nOpcao := 0,If(!VM500TUDOK(),nOpcao:= 0,oDlgAva:End()))},{||nOpcao := 2,oDlgAva:End()},,aButtons)

If nOpcao<>1 .and. Inclui
	RollbackSx8()
Elseif nOpcao==1 .and. (Inclui .or. Altera)
	Fs_Grv500Vm(nOpc)
Elseif nOpcao == 1 
	Fs_Grv500Vm(nOpc)
Endif	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500aHeader      ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o aHeader conforme o Alias informado                  บฑฑ
ฑฑบParametrosณcAlias     = alias do arquivo a ser montado                 บฑฑ
ฑฑบ          ณcAheader   = nome da variavel array a ser criado            บฑฑ
ฑฑบ          ณcNaoCpo    = campos para excluir da getdados                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VM500aHeader(cAlias,cheader,cNaoCpo)
	Local aAlias := sGetaRea()
	sGetArea(aAlias,Alias())
 	
	dbSelectArea("SX3")
	dbSetOrder(1)
	Dbseek(cAlias)
	While !Eof() .And. (SX3->X3_ARQUIVO == cAlias)
		IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .and. Iif(cNaoCpo<>Nil,!SX3->X3_CAMPO$cNaoCpo,.T.)
			AADD(&(cHeader),{ TRIM(x3titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT,;
				SX3->X3_RELACAO,;
				SX3->X3_RESERV })
		EndIf
		dbSelectArea("SX3")		
		dbSkip()
	EndDo
   sRestArea(aAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500aCols        ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o aHeader conforme o Alias informado                  บฑฑ
ฑฑบParametrosณcAlias     = alias do arquivo a ser montado                 บฑฑ
ฑฑบ          ณnOrdem     = Ordem do arquivo em caso de alteracao/exc/vis. บฑฑ
ฑฑบ          ณcChave     = Chave de pesquisa em caso de alt/exc/vis.      บฑฑ
ฑฑบ          ณcAcols     = variavel que ira receber o conteudo            บฑฑ
ฑฑบ          ณcCond      = variavel de escopo da tabela para alt/exc/vis. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VM500aCols(cAlias,nOrdem,cChave,caCols,cCond)
	Local nY
	Local aAlias := sGetArea()
	sGetArea(aAlias,Alias())
	sGetArea(aAlias,cAlias)
	
	If Inclui
		aadd(&(cACols),Array(Len(&("aHeader"+Right(cAcols,1)))+1))
		For nY := 1 To Len(&("aHeader"+Right(cAcols,1)))
			&(cACols)[1][nY] := CriaVar(&("aHeader"+Right(cAcols,1))[nY][2])
			&(cACols)[1][Len(&(cACols)[1])] := .F.
		Next nY
	Else
		&(cAlias)->(DbsetOrder(nOrdem))
		If &(cAlias)->(Dbseek(cChave))
			DbselectArea(cAlias)
			Do While &(cAlias)->(&cCond) == cChave .and. !(&(cAlias)->(Eof()))
				aadd(&(cACols),Array(Len(&("aHeader"+Right(cAcols,1)))+1))
		      For ny:=1 to Len(&("aHeader"+Right(cAcols,1)))
		          &(cACols)[Len(&(cACols)),ny]:=If(&("aHeader"+Right(cAcols,1))[ny,10] # "V",FieldGet(FieldPos(&("aHeader"+Right(cAcols,1))[ny,2])),CriaVar(&("aHeader"+Right(cAcols,1))[ny,2],Inclui))
		      Next
            &(cACols)[Len(&(cACols)),Len(&(cACols)[Len(&(cACols))])] := .f.
				&(cAlias)->(Dbskip())
			Enddo			
		Else
			aadd(&(cACols),Array(Len(&("aHeader"+Right(cAcols,1)))+1))
			For nY := 1 To Len(&("aHeader"+Right(cAcols,1)))
				&(cACols)[1][nY] := CriaVar(&("aHeader"+Right(cAcols,1))[nY][2])
			Next nY
			&(cACols)[1][Len(&(cACols)[1])] := .F.
		Endif
	Endif
	sRestArea(aAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500ENCH บAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a Enchoice do VA7                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias							              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VM500Ench(aCpoEnchoice)
Local aAlias := SGetArea()
SGetArea(aAlias,Alias())

DbSelectArea("SX3")
DbGotop()
DbSeek("VA7")

While x3_arquivo == "VA7" .and. !eof()
   If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !x3_campo$"VA7_PRETAB/VA7_PREPAG/VA7_PREINI/VA7_PREMIN/VA7_PREOPC/VA7_PREOC1/VA7_PREOC2/VA7_PREAVA"
      AADD(aCpoEnchoice,x3_campo)
   Endif
   dbSkip()
EndDo
SRestArea(aAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500ACLONE       ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTrata a Mudanca de Folders                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VM500ChangeF()
oBtnNew:SetFocus() // Apenas para executar a perda de foco da getdados que estiver ativa
VM500Calc() // Atualiza os precos da folder de Resumo da Operacao
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500ENTFOC       ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClona o aheader e acols                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VM500ENTFOC(cGet)
aHeader := AClone(&("aHeader"+cGet))
aCols	  := AClone(&("aCols"+cGet))
n 		  := Len(aCols)
&("oGetDados"+cGet):ForceRefresh()
&("oGetDados"+cGet):oBrowse:Default()
return           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500SAIFOC       ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClona o aheader e acols                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VM500SAIFOC(cGet)

&("aHeader"+cGet):= aClone(aHeader)
&("aCols"+cGet)	:= aClone(aCols)
n						:= len(aCols)  
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500LINOKบAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Linha Digitada nas GetDados                        บฑฑ
ฑฑบParametrosณnx - opcional, numero da linha a validar                    บฑฑ
ฑฑบ          ณlTudook - opcional, ind.a chamada da rotina pela tudook     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500LINOK(nX,lTudook)
Local nwnk := 0,nwnk2 := 0,cChave,cChave2,cChave3
Local nPos := 0,nPos2:= 0,nPos3:= 0
Default lTudook := .F.

cChave := 	Iif(oFolderAva:nOption==1,"VAC_TIPAVA",;	
				Iif(oFolderAva:nOption==2,"VA9_CODOPC",;
				Iif(oFolderAva:nOption==3,"VAD_CODIGO","VAA_CODGRU")))
cChave2:=  	Iif(oFolderAva:nOption==4,"VAA_ITEM","")
cChave3:=  	Iif(oFolderAva:nOption==4,"VAA_AVARIA","")

If nX<>Nil
	n := nX
Endif	

nPos := Iif(nPos<>0,nPos,FG_POSVAR(cChave,"aHeader"+Str(oFolderAva:nOption,1,0)))
nPos2:= Iif(nPos2<>0,nPos2,FG_POSVAR(cChave2,"aHeader"+Str(oFolderAva:nOption,1,0)))
nPos3:= Iif(nPos3<>0,nPos3,FG_POSVAR(cChave3,"aHeader"+Str(oFolderAva:nOption,1,0)))
// Testa para saber se existem itens validos na linha do acols
lValid := .F.
For nwnk2 := 1 To Len(aCols)
	If !aCols[nwnk2,Len(aCols[nwnk2])] 
		For nwnk := 1 To Len(aCols[nwnk2])-1
			If !Empty(aCols[nwnk2,nwnk])
				lValid := .T.
				Exit
			Endif
		Next
	Endif
Next
If !lValid .and. !lTudook
	lValid := .T.
Endif	
If Len(aCols) > 1
	lValid := .T.
Endif	
	
If lValid
	For nwnk := 1 to Len(aCols)
		If !aCols[nwnk,Len(aCols[nwnk])] .and. nwnk <> n .and.;
			aCols[nwnk,nPos] == aCols[n,nPos] .and. !aCols[n,Len(aCols[n])]
	   	If nPos2>0 .and. nPos3>0
	   		If aCols[nwnk,nPos]+aCols[nwnk,nPos2]+aCols[nwnk,nPos3] == aCols[n,nPos]+aCols[n,nPos2]+aCols[n,nPos3]
	   			Help(" ",1,"EXISTCHAV")
	   			Return (.F.)
	   		Endif
			Else
	  			Help(" ",1,"EXISTCHAV")
	  			Return (.F.)
	  		Endif	
		Endif
		If !aCols[nwnk,Len(aCols[nwnk])] .and. Empty(aCols[nwnk,nPos])
			If nPos2>0
				If Empty(aCols[nwnk,nPos2])
					Help(" ",1,"OBRIGAT")
					Return (.F.)
				Endif
			Endif
			Help(" ",1,"OBRIGAT")
			Return (.F.)					
		Endif
	Next
	If !FG_OBRIGAT()
		Return .F.
	Endif
Endif	
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500TUDOKบAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Tela Toda digitada                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500TUDOK()
Local nwnk := 0, nwnk2
If !Inclui .and. !Altera
	Return .T.
Endif
For nwnk := 1 To 4
	oFolderAva:nOption := nwnk
	For nwnk2 := 1 To Len(aCols)
		If !VM500LINOK(nwnk2,.T.)
			Return (.F.)
		Endif
	Next	
Next

Return (.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500FILOKบAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a validacao de campos                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500FILOK()

If ReadVar()=="M->VAA_CODGRU"
	// Carrega a Descricao do Grupo para o campo do aCols
	aCols[n,FG_POSVAR("VAA_DESGRU")] := VM500Desc("VA0",M->VAA_CODGRU,1,FG_POSVAR("VAA_DESGRU"),"VA0_DESCRI")
	// Atualiza a variavel de memoria para o filtro do campo item
	cCodigo := M->VAA_CODGRU
Elseif ReadVar()=="M->VAA_ITEM"
	// Carrega a Descricao do Item do Grupo Generico para o campo do aCols
	aCols[n,FG_POSVAR("VAA_DESITE")] := VM500Desc("VA0",M->VAA_ITEM,1,FG_POSVAR("VAA_DESITE"),"VA0_DESCRI")
	cCodIte := M->VAA_ITEM
Elseif ReadVar()=="M->VAA_AVARIA"
	// Carrega a Descricao do Item da Avaria para o campo do aCols
	aCols[n,FG_POSVAR("VAA_DESAVA")] := VM500Desc("VA4",M->VAA_AVARIA,1,FG_POSVAR("VAA_DESAVA"),"VA4_DESCRI")
Endif

Return (.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVVM500PR  บAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o preco de inicial do veiculo e traz o preco de tabeบฑฑ
ฑฑบ          ณla                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VVM500PR()
	Local aAlias := sGetArea()
	sGetArea(aAlias,Alias())
	sGetArea(aAlias,"VA1")
	DbselectArea("VA1")
	VA1->(DbsetOrder(1))
	Dbseek(xFilial("VA1")+M->VA7_MARCA+M->VA7_MODVEI+M->VA7_ANOMOD+M->VA7_COMBUS)
	If Inclui
		nPrcIni := VA1->VA1_PRCINI
		nPrcMax := VA1->VA1_PRCMAX
		nPrcMin := VA1->VA1_PRCMIN
		If !Empty(VA1->VA1_FORMUL)
			//nPrcIni := VM500Formul(VA1->VA1_FORMUL)
		 	If nPrcIni == 0
		 		nPrcIni := VA1->VA1_PRCINI
		 	Endif
	 	Endif			
	Else
		nPrcIni := VA7->VA7_PREINI
		nPrcMax := VA7->VA7_PRETAB
		nPrcMin := VA7->VA7_PREMIN
	Endif	

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500ClrV บAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa variaveis de memoria                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500ClrV()
	nPrcIni := 0
	nPrcMax := 0
	nPrcPag := 0
	nPrcOpc := 0
	nPrcOco1:= 0
	nPrcOco2:= 0
	nPrcMin := 0
	nPrcAva := 0
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500CALC บAutor  ณRicardo Farinelli   บ Data ณ  10/23/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o Calculo da Folder de Resumo da Avaliacao           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500Calc()
Local nwnk, nPosIte,nPosPre,nPosTip

VM500CLRV() // Limpa as Variaveis de Memoria
VVM500PR() // Calcula os precos iniciais
// Opcionais do Veiculo
nPosIte := FG_POSVAR("VA9_ITESER","AHEADER2")
nPosPre := FG_POSVAR("VA9_PRECO","AHEADER2")
For nwnk := 1 To Len(aCols2)
	If nPosIte > 0 .and. nPosPre > 0
		If !aCols2[nwnk,Len(aCols2[nwnk])]
			If aCols2[nwnk,nPosIte]=="0" // item de serie - somar o valor
				nPrcOpc += aCols2[nwnk,nPosPre]
			Endif
		Endif
	Endif	
Next		
// Pendencias do Veiculo
nPosPre := FG_POSVAR("VAD_VLRPEN","AHEADER3")
nPosTip := FG_POSVAR("VAD_TIPPEN","AHEADER3")
For nwnk := 1 To Len(aCols3)
	If nPosTip > 0 .and. nPosPre > 0
		If !aCols3[nwnk,Len(aCols3[nwnk])]
			If aCols3[nwnk,nPosIte]<>"2" // somar/subtrai do valor
				If aCols3[nwnk,nPosIte]=="0" // Somar
					nPrcOco1 += aCols3[nwnk,nPosPre]
				Elseif aCols3[nwnk,nPosIte]=="1" // Subtrair
					nPrcOco2 += aCols3[nwnk,nPosPre]
				Endif
			Endif
		Endif
	Endif	
Next		

// Avarias no Veiculo
nPosPre := FG_POSVAR("VAA_VALOR","AHEADER4")

For nwnk := 1 To Len(aCols4)
	If nPosPre > 0
		If !aCols4[nwnk,Len(aCols4[nwnk])]
			nPrcAva += aCols4[nwnk,nPosPre]
		Endif
	Endif	
Next		

nPrcPag := (nPrcIni+nPrcOpc+nPrcOco1)-(nPrcOco2+nPrcAva)

oPrcPag:Refresh()
oPrcIni:Refresh()
oPrcMax:Refresh()
oPrcMin:Refresh()
oPrcOpc:Refresh()
oPrcOco1:Refresh()
oPrcOco2:Refresh()
oPrcAva:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500Desc บAutor  ณRicardo Farinelli   บ Data ณ  10/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a descricao do grupo generico                      บฑฑ
ฑฑบParametrosณcAlias    = alias do arquivo a atualizar                    บฑฑ
ฑฑบ          ณcCodigo   = Codigo a ser pesquisado na tabela informada     บฑฑ
ฑฑบ          ณnOrdem    = ordem do arquivo para a pesquisa (opcional)     บฑฑ
ฑฑบ          ณnPosCpo   = posicao do campo a ser atualizado no acols      บฑฑ
ฑฑบ          ณnCpoTab   = Nome do Campo que contem a descricao            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500Desc(cAlias,cCodigo,nOrdem,nPosCpo,cCpoTab)
Local cDescr := "",nTamCpo := aHeader[nPosCpo,4],aAlias := SGetArea()
Default nOrdem := 1
sGetArea(aAlias,Alias())
sGetArea(aAlias,cAlias)
DbselectArea(cAlias)
DbSetOrder(nOrdem)
cDescr := Space(nTamCpo)
If Dbseek(xFilial(cAlias)+cCodigo)
	cDescr := &(cCpoTab)
Endif
sRestArea(aAlias)
Return cDescr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRV500VM       ณRicardo Farinelli   บ Data ณ  10/29/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a gravacao dos dados nos respectivos arquivos        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GRV500VM(nOpc)
Local lTrans := .F., lFound := .F.,nwnk
lTrans := .F.

If nOpc <> 5
	Begin Transaction
		DbselectArea("VA7") // Cabecalho Avaliacao
		DbsetOrder(1)
		lFound := !(Dbseek(xFilial("VA7")+M->VA7_CODAVA))
		RecLock("VA7",lFound)
		FG_GRAVAR("VA7")
		VA7_PREINI := nPrcIni
		VA7_PREMIN := nPrcMin
		VA7_PRETAB := nPrcMax
		VA7_PREPAG := nPrcPag
		VA7_PREOPC := nPrcOpc
		VA7_PREAVA := nPrcAva
		VA7_PREOC1 := nPrcOco1
		VA7_PREOC2 := nPrcOco2
		MsUnlock()
		DbselectArea("VAC") // Estado Geral do Veiculo
		DbsetOrder(1)
		// Coloca os deletados primeiro
		Asort(aCols1,,,{|x,y| x[len(x)] > y[Len(y)] })
		For nwnk := 1 To Len(aCols1)
			lFound := !(Dbseek(xFilial("VAC")+M->VA7_CODAVA+aCols1[nwnk,FG_POSVAR("VAC_TIPAVA","aHeader1")]))
			RecLock("VAC",lFound)
			If aCols1[nwnk,Len(aCols1[nwnk])] .and. !lFound
				Dbdelete()
			Else	
				FG_GRAVAR("VAC",aCols1,aHeader1,nwnk)
				VAC_CODAVA := M->VA7_CODAVA     
			Endif	
			MsUnlock()
		Next
		DbselectArea("VA9") // Opcionais do Veiculo
		DbsetOrder(1)
		// Coloca os deletados primeiro
		Asort(aCols2,,,{|x,y| x[len(x)] > y[Len(y)] })
		For nwnk := 1 To Len(aCols2)	
			lFound := !(Dbseek(xFilial("VA9")+M->VA7_CODAVA+aCols2[nwnk,FG_POSVAR("VA9_CODOPC","aHeader2")]))
			RecLock("VA9",lFound)
			If aCols2[nwnk,Len(aCols2[nwnk])] .and. !lFound
				Dbdelete()
			Else	
				FG_GRAVAR("VA9",aCols2,aHeader2,nwnk)
				VA9_CODAVA := M->VA7_CODAVA
				MsUnlock()
			Endif
		Next
		DbselectArea("VAD") // Ocorrencias com o Veiculo
		DbsetOrder(1)
		// Coloca os deletados primeiro
		Asort(aCols3,,,{|x,y| x[len(x)] > y[Len(y)] })
		For nwnk := 1 To Len(aCols3)	
			lFound := !(Dbseek(xFilial("VAD")+M->VA7_CODAVA+aCols3[nwnk,FG_POSVAR("VAD_CODIGO","aHeader3")]))
			RecLock("VAD",lFound)
			If aCols3[nwnk,Len(aCols3[nwnk])] .and. !lFound
				Dbdelete()
			Else	
				FG_GRAVAR("VAD",aCols3,aHeader3,nwnk)
				VAD_CODAVA := M->VA7_CODAVA
				MsUnlock()
			Endif
		Next
		DbselectArea("VAA") // Checklist da Avaliacao do Veiculo
		DbsetOrder(1)
		// Coloca os deletados primeiro
		Asort(aCols4,,,{|x,y| x[len(x)] > y[Len(y)] })
		For nwnk := 1 To Len(aCols4)	
			lFound := !(Dbseek(xFilial("VAA")+M->VA7_CODAVA+aCols4[nwnk,FG_POSVAR("VAA_CODGRU","aHeader4")]+aCols4[nwnk,FG_POSVAR("VAA_ITEM","aHeader4")]+aCols4[nwnk,FG_POSVAR("VAA_AVARIA","aHeader4")]))
			RecLock("VAA",lFound)
			If aCols4[nwnk,Len(aCols4[nwnk])] .and. !lFound
				Dbdelete()
			Else	
				FG_GRAVAR("VAA",aCols4,aHeader4,nwnk)
				VAA_CODAVA := M->VA7_CODAVA
				MsUnlock()
			Endif
		Next
		lTrans := .T.
	End Transaction
	If lTrans
		ConfirmSx8()	
	Endif	
Elseif nOpc == 5
	Begin Transaction
		DbselectArea("VAC") // Estado Geral do Veiculo
		DbsetOrder(1)
		VAC->(Dbseek(xFilial("VAC")+M->VA7_CODAVA))
		Do While VAC->(VAC_FILIAL+VAC_CODAVA) == xFilial("VA7")+VA7->VA7_CODAVA .and. !VAC->(Eof())
			RecLock("VAC",.F.)
			Dbdelete()
			MsUnLock()
			Dbskip()
		Enddo

		DbselectArea("VA9") // Opcionais do Veiculo
		DbsetOrder(1)
		VA9->(Dbseek(xFilial("VA9")+M->VA7_CODAVA))
		RecLock("VA9",.F.)
		Do While VA9->(VA9_FILIAL+VA9_CODAVA) == xFilial("VA7")+VA7->VA7_CODAVA .and. !VA9->(Eof())
			RecLock("VA9",.F.)
			Dbdelete()
			MsUnLock()
			Dbskip()
		Enddo

		DbselectArea("VAD") // Ocorrencias com o Veiculo
		DbsetOrder(1)
		VAD->(Dbseek(xFilial("VAD")+M->VA7_CODAVA))
		RecLock("VAD",.F.)
		Do While VAD->(VAD_FILIAL+VAD_CODAVA) == xFilial("VA7")+VA7->VA7_CODAVA .and. !VAD->(Eof())
			RecLock("VAD",.F.)
			Dbdelete()
			MsUnLock()
			Dbskip()
		Enddo

		DbselectArea("VAA") // Checklist da Avaliacao do Veiculo
		DbsetOrder(1)
		// Coloca os deletados primeiro
		VAA->(Dbseek(xFilial("VAA")+M->VA7_CODAVA))
		RecLock("VAA",.F.)
		Do While VAA->(VAA_FILIAL+VAA_CODAVA) == xFilial("VA7")+VA7->VA7_CODAVA .and. !VAA->(Eof())
			RecLock("VAA",.F.)
			Dbdelete()
			MsUnLock()
			Dbskip()
		Enddo

		DbselectArea("VA7") // Cabecalho Avaliacao
		DbsetOrder(1)
		RecLock("VA7",.F.)
		dbDelete()
		MsUnLock()
   End Transaction
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funao	    ณVM500ViewImgณ Autor ณ Eduardo Motta/Ricardo F.     ณ Data ณ 06/07/2000 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descriao   ณ Vizualizador do lay-out de imagens                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Parametros  ณ cCod   : Codigo do lay-out                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso  	    ณ Gestao de concessionarias                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Observacoes ณ Nao tem															     					 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function VM500ViewImg(cCod,lLado)
Local oBut2
Local cCodigo := ""
Local aPartes
Local cNome
Local cArquivo
Local oDlg
Local nI


Local nOpcao := 0
Local nPos
Local lProx := .F.
Default lLado := .F.

If cCod<> nil
	cCodigo := cCod
	If (nPos := Ascan(aTelas,{|x| x[4]=="X"}) ) == 0 
		nPos  := 1
		nPos2 := Ascan(aTelas,{|x| x[2]==cCodigo})
		If nPos2 > 0
	      aTelas[nPos2,4]:= "X"
	      If !Empty(aTelas[nPos2,3])
	      	lProx := .T.
	      Endif	
  	   Endif 
	Endif
Else
	If lLado
		nPos := Ascan(aTelas,{|x| x[4]=="X"})
		If nPos > 0
			If !Empty(aTelas[nPos,3])
				nPos2 := Ascan(aTelas,{|x| x[1]==aTelas[nPos,3]})
				aTelas[nPos,4] := " "
				aTelas[nPos2,4] := "X"
				cCodigo := aTelas[nPos2,2]
		      If !Empty(aTelas[nPos2,3])
		      	lProx := .T.
	   	   Endif	
			Endif
		Endif
	Endif
Endif	

aPartes := Vm500LoadFig(cCodigo)
If Len(aPartes)==0
	MsgStop(OemToAnsi(STR0022)) //"Nao existem figuras parametrizadas para visualizacao"
	Return
Endif
DEFINE MSDIALOG oDlg FROM 0,0 TO 500,500 TITLE OemToAnsi(STR0023) PIXEL //"Visualizacao das Partes do Veiculo"

For nI := 1 to Len(aPartes)
   cNome := aPartes[nI,1]
   cArquivo := Trim(aPartes[nI,9])
   &cNome := TBtnAutFmt():New(10,20 , "", oDlg,,,,,,Trim(aPartes[nI,4]),,,,cArquivo)
   &cNome:nTop := aPartes[nI,2]
   &cNome:nLeft:= aPartes[nI,3]
   &cNome:CREADVAR  := cNome
   &cNome:BLCLICKED := {|x| VM500ViewFil(x,aPartes)  }
Next

If lProx 
	DEFINE SBUTTON oBut2 TYPE 21 FROM (oDlg:nClientHeight/2)-25,(oDlg:nClientWidth/2)-30 OF oDlg ENABLE ONSTOP OemToAnsi(STR0024)  ACTION VM500PRX()  //"Proximo Angulo"
Else
	// so para ganhar foco e funcionar o OK da enchoicebar
	DEFINE SBUTTON oBut99 TYPE 21 FROM 5000,5000 OF oDlg ENABLE ONSTOP "" ACTION .T.
Endif                                       

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpcao:=1 ,oDlg:End()},{||nOpcao:=2,oDlg:End()})
nPos := Ascan(aTelas,{|x| x[2]==cCodigo})
If nPos > 0
	nPos2 := Ascan(aTelas,{|x| x[3]==aTelas[nPos,1]})
	If nPos2 > 0
		aTelas[nPos,4] := " "
		aTelas[nPos2,4] := "X"
		cCodigo := aTelas[nPos2,2]
	Else
		aTelas[nPos,4] := "X"		
		cCodigo := aTelas[nPos,2]
	Endif
Endif


Return nOpcao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณVm500ViewFil ณ Autor ณEduardo Motta/Ricardo Data ณ 03/07/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica a existencia de um filho na figura, se tiver      ณฑฑ
ฑฑณ          ณ vizualiza o Filho                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ oBmp   : Objeto BMP                                        ณฑฑ
ฑฑณ          ณ aPartes: Array com os dados das partes do veiculo          ณฑฑ
ฑฑณ          ณ cTitViz: Titulo do Programa                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Gestao de Concessionarias                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VM500ViewFil(oBmp,aPartes)
Local nLoc := AScan(aPartes,{|x| Trim(x[1]) == Trim(oBmp:cReadVar)})
Local oDlgGru,oGetGru,oGetIte,oGetAva,nValGru,nOpcao
Local cGGvm500,cDes1bm500,cGIvm500,cDes2vm500,cGAvm500,cDes3vm500
Local aAlias := sGetArea()
sGetArea(aAlias,"VA0")
sGetArea(aAlias,"VA4")
sGetArea(aAlias,"VA5")
sGetArea(aAlias,"VA2")

cGGvm500 := CriaVar("VAA_CODGRU")
cDes1bm500  := CriaVar("VAA_DESGRU")
cGIvm500 := CriaVar("VAA_ITEM")
cDes2vm500  := CriaVar("VAA_DESGRU")
cGAvm500 := CriaVar("VAA_AVARIA")
cDes3vm500  := CriaVar("VAA_DESAVA")
VA0->(DbsetOrder(2))
VA4->(DbSetOrder(1))
VA2->(DbsetOrder(1))
VA5->(DbsetOrder(1))

If nLoc > 0
   If !Empty(aPartes[nLoc,7])
      VM500ViewImg(aPartes[nLoc,7])
	Else
		If !Empty(aPartes[nLoc,11])
			cGGvm500 := aPartes[nLoc,11]
			DEFINE MSDIALOG oDlgGru FROM 000,000 TO 150,350 TITLE  OemToAnsi(STR0025) OF oMainWnd PIXEL //"Avaria detectada"

				@ 018,03 SAY OemToAnsi(STR0026) OF oDlgGru Size 20,8 Pixel  //"Grupo"
				@ 018,30 MSGET oGetGru VAR cGGvm500 PICT "@!" F3 "VR6" OF ODlgGru Size 20,8 Pixel When ((VA0->(DbSetOrder(2)),.T.) .and. VA0->(Dbseek(xFilial("VA0")+Space(Len(cGGvm500))+cGGvm500)) .and. (cDes1bm500 := VA0->VA0_DESCRI,cCodigo := VA0->VA0_CODIGO,.F.)) 
				@ 018,70 MSGET oGesDes1 VAR cDes1bm500 When (.F.) Size 100,8 Pixel
				@ 031,03 SAY OemToAnsi(STR0027) OF oDlgGru Size 20,8 Pixel  //"Item"
				@ 031,30 MSGET oGetIte VAR cGIvm500 PICT "@!" F3 "VR7" OF ODlgGru Size 20,8 Pixel VALID ((VA0->(DbSetOrder(2)),.T.) .and. VA0->(Dbseek(xFilial("VA0")+cGGvm500+cGIvm500)) .and.  (cDes2vm500 := VA0->VA0_DESCRI,cCodIte := VA0->VA0_CODIGO,.T.))
				@ 031,70 MSGET oGesDes2 VAR cDes2vm500 When (.F.) Size 100,8 Pixel 
				@ 046,03 SAY OemToAnsi(STR0028) OF oDlgGru Size 20,8 Pixel  //"Avaria"
				@ 046,30 MSGET oGetAva VAR cGAvm500 PICT "@!" F3 "VA5" OF ODlgGru Size 20,8 Pixel VALID (VA4->(Dbseek(xFilial("VA4")+cGAvm500)) .and. (cDes3vm500 := VA4->VA4_DESCRI,cCodIte := VA0->VA0_CODIGO,.T.))
				@ 046,70 MSGET oGesDes3 VAR cDes3vm500 When .F. Size 100,8 Pixel 
				
			ACTIVATE MSDIALOG oDlgGru CENTER ON INIT Enchoicebar(oDlgGru,{||nOpcao := 1,oDlgGru:End()},{||nOpcao := 2,oDlgGru:End()})			
			If nOpcao == 1
				If VA5->(Dbseek(xFilial("VA5")+M->VA7_MARCA+M->VA7_MODVEI+cGIvm500+cGAvm500))
					If VA2->(dbseek(xFilial("VA2")+M->VA7_MARCA+M->VA7_MODVEI+M->VA7_ANOMOD+cGGvm500))
						nValGru := VA2->VA2_VLRGRU
						If !Empty(VA5->VA5_VALOR)
							nValor := VA5->VA5_VALOR
						Elseif !Empty(VA5->VA5_PORC)
							nValor := Round((nValGru/100)*VA5->VA5_PORC,2)
						Endif												
						VM500AAdd(cGGvm500,cGIvm500,cGAvm500,nValor)
					Endif
				Endif
			Endif
		Endif
   EndIf
EndIf

sRestArea(aAlias)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500LoadFig      ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a carga das partes que formam a figura               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VM500LoadFig(cCodigo)
Local aPartes := {}
VVU->(DbSetOrder(1))
VVU->(DbSeek(xFilial("VVU")+cCodigo))
cDescricao := VVU->VVU_DESC

/*
aPartes[x,01] := Nome do Objeto
aPartes[x,02] := NTOP
aPartes[x,03] := NLEFT
aPartes[x,04] := Descricao (Hint)
aPartes[x,05] := (cod block LCLICK)
aPartes[x,06] := (cod block RCLICK)
aPartes[x,07] := Filho
aPartes[x,08] := Descricao do Filho
aPartes[x,09] := Caminho da Figura 1
aPartes[x,10] := Caminho da Figura 2
aPartes[x,11] := Grupo Generico
aPartes[x,12] := Deletato (.T. / .F.)

*/

VVV->(DbSetOrder(1))
VVV->(DbSeek(xFilial("VVV")+cCodigo))
While VVV->VVV_FILIAL == xFilial("VVV") .and. VVV->VVV_CODIGO == cCodigo .and. ! (VVV->(Eof()))
   AADD(aPartes,{"OFIG"+VVV->VVV_ORDEM,VVV->VVV_NTOP,VVV->VVV_NLEFT,VVV->VVV_DESC,"","",VVV->VVV_FILHO,VVV->VVV_DESFIL,VVV->VVV_FIG1,VVV->VVV_FIG2,VVV->VVV_CODGRU,.F.})
   VVV->(DbSkip())
EndDo

Return aPartes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500Form บAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a execucao da formula para calculo do preco inicial  บฑฑ
ฑฑบ          ณdo veiculo                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500Form(cFormula)

Local nRetVal
Local cForm    := " "
Local aAlias := SGetArea()
Local bBlock:=ErrorBlock()
Local bErro := ErrorBlock( { |e| ChekBug(e) } )

Private lRet      := .t.

DbSelectArea("VEG")
if DbSeek(xfilial("VEG")+cFormula)
   cForm := AllTrim(VEG_FORMUL)
   BEGIN SEQUENCE
      nRetVal := &cForm
   END SEQUENCE

   If lRet == .f.
      nRetVal := 0
   Endif   
Else            
   nRetVal := 0
Endif

ErrorBlock(bBlock)

SRestArea(aAlias)

Return(nRetVal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCHEKBUG   บAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de desvio de erro                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Chekbug(e)
If e:gencode > 0
    lRet:=.F.
Endif
Break
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500AVAVIบAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta a Avaliacao visual do veiculo                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500AVAVI()
Local nVezes := 0, cFigPri := VA1->VA1_DESENH, aAlias := SGetArea()
aTelas := {}
sGetArea(aAlias,"VA6")
VA6->(DbsetOrder(1))
If VA6->(Dbseek(xFilial("VA6")+cFigPri))
	cFigPri := VA6->VA6_CODLAY
Endif	
Do While .T.
	AAdd(aTelas,{VA6->VA6_CODIGO,VA6->VA6_CODLAY,VA6->VA6_PAI," "})
	nVezes++
	If Empty(VA6->VA6_PAI)
		Exit
	Else
		VA6->(dbseek(xFilial("VA6")+VA6->VA6_PAI))
	Endif	
Enddo

VM500ViewImg(cFigPri)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500PRX  บAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada da funcao com parametros para mudanca de angulo da  บฑฑ
ฑฑบ          ณfigura                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VM500PRX()
	VM500ViewImg(,.T.)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVM500AADD บAutor  ณRicardo Farinelli   บ Data ณ  10/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere avarias no acols da getdados do checklist            บฑฑ
ฑฑบParametrosณcGru    = Grupo generico                                    บฑฑ
ฑฑบ          ณcIte    = Item  generico                                    บฑฑ
ฑฑบ          ณcAva    = Avaria cadastrada no VA5                          บฑฑ
ฑฑบ          ณnVal    = Valor a ser lancado                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VM500AADD(cGru,cIte,cAva,nVal)
Local nwnk := 0,lNew := .F.
Local nPos1 := FG_POSVAR("VAA_CODGRU")
Local nPos2 := FG_POSVAR("VAA_ITEM")
Local nPos3 := FG_POSVAR("VAA_AVARIA")
Local nPos4 := FG_POSVAR("VAA_VALOR")

aCols4 	:= aClone(aCols)
aHeader4 := aClone(aHeader)

lNew := .T.
For nwnk := 1 To Len(aCols)
	If !aCols[nwnk,Len(aCols[nwnk])]
		If Len(aCols)==1 .and. Empty(aCols[1,nPos1]+aCols[1,nPos2]+aCols[1,nPos3])
			aCols[1,nPos1] := cGru
			aCols[1,nPos2] := cIte
			aCols[1,nPos3] := cAva
			aCols[1,nPos4] := nVal	
			aCols[1,FG_POSVAR("VAA_DESGRU")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VAA_CODGRU")],1,FG_POSVAR("VAA_DESGRU"),"VA0_DESCRI")
			aCols[1,FG_POSVAR("VAA_DESITE")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VAA_ITEM")],1,FG_POSVAR("VAA_DESITE"),"VA0_DESCRI")
			aCols[1,FG_POSVAR("VAA_DESAVA")] := VM500Desc("VA4",aCols[Len(aCols),FG_POSVAR("VAA_AVARIA")],1,FG_POSVAR("VAA_DESAVA"),"VA4_DESCRI")
			lNew := .F.
		Else
			If aCols[nwnk,nPos1]+aCols[nwnk,nPos2]+aCols[nwnk,nPos3]==cGru+cIte+cAva
				aCols[nwnk,nPos4] := nVal
				lNew := .F.
			Endif	
		Endif		
	Endif
Next
If lNew
	AAdd(aCols,Array(Len(aHeader4)+1))
   For nwnk:=1 to Len(aHeader4)
      aCols[Len(aCols),nwnk]:=CriaVar(aHeader4[nwnk,2],Inclui)
   Next
	aCols[Len(aCols),nPos1] := cGru
	aCols[Len(aCols),nPos2] := cIte
	aCols[Len(aCols),nPos3] := cAva
	aCols[Len(aCols),nPos4] := nVal	
   aCols[Len(aCols),Len(aCols[Len(aCols)])] := .f.
	aCols[Len(aCols),FG_POSVAR("VAA_DESGRU")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VAA_CODGRU")],1,FG_POSVAR("VAA_DESGRU"),"VA0_DESCRI")
	aCols[Len(aCols),FG_POSVAR("VAA_DESITE")] := VM500Desc("VA0",aCols[Len(aCols),FG_POSVAR("VAA_ITEM")],1,FG_POSVAR("VAA_DESITE"),"VA0_DESCRI")
	aCols[Len(aCols),FG_POSVAR("VAA_DESAVA")] := VM500Desc("VA4",aCols[Len(aCols),FG_POSVAR("VAA_AVARIA")],1,FG_POSVAR("VAA_DESAVA"),"VA4_DESCRI")
Endif
aCols4 	:= aClone(aCols)
aHeader4 := aClone(aHeader)
aCols  	:= aClone(aCols4)
aHeader	:= aClone(aHeader4)

oGetDados4:oBrowse:Default()
oGetDados4:oBrowse:Refresh()
oGetDados4:ForceRefresh()

Return

Static Function MenuDef()
Local aRotina := { {STR0001 	,"AxPesqui"	, 0 , 1},;  //"Pequisar"
                  {STR0002	,"VEIVM500I"	, 0 , 2},;  //"Visualizar"
	               {STR0003	,"VEIVM500I"	, 0 , 3},;  //"Incluir"
   	            {STR0004	,"VEIVM500I"	, 0 , 4},;  //"Alterar"
                  {STR0005	,"VEIVM500I"	, 0 , 5}}   //"Excluir"
Return aRotina
