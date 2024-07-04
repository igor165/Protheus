#INCLUDE "LOJA460.CH"
#INCLUDE "PROTHEUS.CH"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Posicoes do array aSaldos                                              |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE _LIMCREDM 1,1
#DEFINE _LIMCRED  1,2
#DEFINE _SALDUPM  2,1
#DEFINE _SALDUP   2,2
#DEFINE _SALPEDLM 3,1
#DEFINE _SALPEDL  3,2
#DEFINE _MCOMPRAM 4,1
#DEFINE _MCOMPRA  4,2
#DEFINE _SALDOLCM 5,1
#DEFINE _SALDOLC  5,2
#DEFINE _MAIDUPLM 6,1
#DEFINE _MAIDUPL  6,2
#DEFINE _ITATUM   7,1
#DEFINE _ITATU    7,2
#DEFINE _PEDATUM  8,1
#DEFINE _PEDATU   8,2
#DEFINE _SALPEDM  9,1
#DEFINE _SALPED   9,2
#DEFINE _VALATRM  10,1
#DEFINE _VALATR   10,2
#DEFINE _LCFINM   11,1
#DEFINE _LCFIN    11,2
#DEFINE _SALFINM  12,1
#DEFINE _SALFIN   12,2

#DEFINE _STRASALDOS 12,2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA460   บAutor  ณJose Novaes Romeu   บ Data ณ  11/21/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Liberacao de credito do orcamento                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤย--ฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramad ณ Data  	ณ BOPS ณ  Motivo da Alteracao 					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤล--ฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณFernando  ณ12/12/06  ณ9.12  ณBops 115294 Alterado a array aRotina  paraณฑฑ
ฑฑณ          ณ          |      ณ cria็ใo do menu funcional            	  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA460()

Local cCondicao	:= "", aIndSL1	:= {}, aArea := GetArea()
Local aCposBrw := {}, aCposSL1 := {}, cArqTrab := ""
Local aCores		:=	{{"L1_BLCRED=='  ' .Or. L1_BLCRED=='20'",'ENABLE'},;	 //Item Liberado
						 { "L1_BLCRED<>'  ' .And. L1_BLCRED<>'10' .And. L1_BLCRED<>'20'",'BR_AZUL'}} //Item Bloqueado - Credito

Private cCadastro :=	OemToAnsi(STR0001) //"Liberacao de Credito"
Private aRotina   :=	MenuDef()
Private bFiltraBrw := {|| Nil}, lEnd := .F., cFilSL1 := xFilial("SL1"), cFilSA1 := xFilial("SA1")
Private lQuery  := .F.
Private cCposSL1:= ""
Private cIndSL1 := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Determina se esta sendo usado TopConnect.                              |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFDEF TOP
	If TcSrvType() <> "AS/400"
		lQuery := .T.
	EndIf
#ENDIF

If !Pergunte("MTA451")
	Return(.T.)
EndIf

//If !lQuery
cCondicao := "L1_FILIAL == '"+cFilSL1+"' "
cCondicao += " .And. L1_SERIE == '"+Space(TamSX3("L1_SERIE")[1])+"'"
cCondicao += " .And. L1_DOC	  == '"+Space(TamSX3("L1_DOC")[1])+"'"
If MV_PAR01 == 1  //Somente bloqueados
	cCondicao += " .And. L1_BLCRED <> '  '"
	cCondicao += " .And. L1_BLCRED <> '10'"
	cCondicao += " .And. L1_BLCRED <> '20'"
EndIf

If lQuery
	cIndSL1 := SqlOrder(SL1->(IndexKey()))
Else
	cIndSL1 := SL1->(IndexKey())
EndIf

dbSelectArea("SX3")
aAreaSX3 := GetArea()
If dbSeek("SL1")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Monta String com os campos que deverao ser exibidos no Browse.         |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	While !Eof() .And. X3_ARQUIVO == "SL1"
		If (X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. X3_BROWSE == "S") .Or.;
			(Trim(X3_CAMPO) $ cIndSL1+",L1_BLCRED,L1_CLIENTE,L1_LOJA,L1_COND" )
			
			cCposSL1 += Trim(X3_CAMPO)+", "
		EndIf
		dbSkip()
	End
	
	If lQuery
		cCposSL1 += "R_E_C_N_O_"
	EndIf
EndIf
RestArea(aAreaSX3)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a Filtragem                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SL1")
dbSetOrder(2)
bFiltraBrw := {|| FilBrowse("SL1",@aIndSL1,@cCondicao) }
Eval(bFiltraBrw)

mBrowse( 7, 4,20,74,"SL1",,,,,,aCores)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
EndFilBrw("SL1",aIndSL1)


/*
Else
cIndSL1 := SqlOrder(SL1->(IndexKey()))
dbSelectArea("SX3")
aAreaSX3 := GetArea()
If dbSeek("SL1")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Monta String com os campos que deverao ser exibidos no Browse.         |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !Eof() .And. X3_ARQUIVO == "SL1"
If (X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. X3_BROWSE == "S") .Or.;
(Trim(X3_CAMPO) $ cIndSL1+",L1_BLCRED,L1_CLIENTE,L1_LOJA,L1_COND" )

AAdd(aCposSL1,{Trim(X3_CAMPO), X3_TIPO, X3_TAMANHO, X3_DECIMAL})

If X3_BROWSE == "S"
AAdd(aCposBrw,{X3TITULO(X3_CAMPO), &("{|| "+aCposSL1[Len(aCposSL1)][1]+"}"), X3_TIPO, X3_TAMANHO, X3_DECIMAL, RTrim(X3_PICTURE) })
EndIf
cCposSL1 += Trim(X3_CAMPO)+", "
EndIf
dbSkip()
End
cCposSL1 += "R_E_C_N_O_"
AAdd(aCposSL1,{"R_E_C_N_O_","N",14,0})
EndIf
RestArea(aAreaSX3)

cQuery := "SELECT "+cCposSL1+" "
cQuery += "FROM "+RetSqlName("SL1")+" "
cQuery += "WHERE L1_FILIAL = '"+cFilSL1+"' AND "
cQuery += "L1_DOC = ' ' AND "
If MV_PAR01 == 1
cQuery += "L1_BLCRED <> ' ' AND L1_BLCRED <> '10' AND "
EndIf
cQuery += "D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY "+cIndSL1

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SL1TMP", .T., .T.)

For nI := 1 to Len(aCposSL1)
If aCposSL1[nI][2] <> "C"
TCSetField("SL1TMP", aCposSL1[nI][1], aCposSL1[nI][2], aCposSL1[nI][3], aCposSL1[nI][4])
Endif
Next

cArqTrab := CriaTrab( aCposSL1 )
dbUseArea( .T.,, cArqTrab, "TRB", .T., .F. )
dbSelectArea("TRB")

dbSelectArea("SL1TMP")
dbGoTop()
While !Eof()
RecLock("TRB", .T.)
For nI := 1 To Len(aCposSL1)
TRB->( FieldPut( FieldPos(aCposSL1[nI][1]), SL1TMP->(FieldGet(FieldPos(aCposSL1[nI][1]))) ) )
Next
MsUnLock()
dbSkip()
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Cria o Browse utilizando o arquivo temporario.                         |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("TRB")
mBrowse( 7, 4,20,74,"TRB",aCposBrw,,,,,aCores)

dbSelectArea("SL1TMP")
dbCloseArea()

dbSelectArea("TRB")
dbCloseArea()
FErase( cArqTrab + GetDBExtension() )
EndIf
*/


RestArea(aArea)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |MenuDef	ณ Autor ณ Fernando Amorim       ณ Data ณ12/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de defini็ใo do aRotina                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRotina   retorna a array com lista de aRotina             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef() 

Local aRotina:= {		{ OemToAnsi(STR0002),"PesqBrw"    , 0 , 1 , , .F.},;  //"Pesquisar"
						{ OemToAnsi(STR0003),"lj460LibAut", 0 , 0 , , .T.},;  //"Automatica"
						{ OemToAnsi(STR0004),"lj460LibMan", 0 , 0 , , .T.},;  //"Manual"
						{ OemToAnsi(STR0005),"lj460Legend", 0 , 3 , , .T.} }  //"Legenda"

							
							
Return(ARotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ460LibAutบAutor  ณJose Novaes Romeu   บ Data ณ  11/21/01   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para gerar liberacoes automaticas                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA460                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ460LibAut(cAlias)

Local aArea	:= GetArea()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ mv_par01 Orcamento de       ?                                 ณ
//ณ mv_par02 Orcamento ate      ?                                 ณ
//ณ mv_par03 Cliente de         ?                                 ณ
//ณ mv_par04 Cliente ate        ?                                 ณ
//ณ mv_par05 Data Liberacao de  ?                                 ณ
//ณ mv_par06 Data Liberacao ate ?                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Pergunte("LOJ460",.T.)
	If MsgYesNo(OemToAnsi(STR0006),OemToAnsi(STR0007))  //"Confirma Liberacao Automatica?"###"Atencao"
		Processa({|lEnd| Lj460Proces()})
	Endif
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ460ProcesบAutor  ณJose Novaes Romeu   บ Data ณ  11/22/01   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA460                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿Ü฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ460Proces()

Local cQuery	:= ""
Local cArqTrab	:= ""
Local aStru		:= {}
Local nLoop		:= 0
Local cAliasSL1 := "LJ460"
Local nTotRegs  := 0
Local lLj460Aut := ExistBlock("LJ460AUT")

If lQuery
	aStru := SL1->(dbStruct())
	
	cQuery := "SELECT "+cCposSL1
	cQuery += " FROM "+RetSqlName("SL1")
	cQuery += " WHERE L1_FILIAL = '"+cFilSL1+"' AND "
	cQuery += "L1_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	cQuery += "L1_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
	cQuery += "L1_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' AND "
	cQuery += "L1_DOC = ' ' AND L1_SERIE = ' ' AND "
	cQuery += "L1_BLCRED <> ' ' AND L1_BLCRED <> '10' AND L1_BLCRED <> '20' AND "
	cQuery += "D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY "+cIndSL1
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSL1, .T., .T.)
	
	For nLoop := 1 To Len(aStru)
		If aStru[nLoop,2] <> "C"
			TCSetField(cAliasSL1, aStru[nLoop,1], aStru[nLoop,2],aStru[nLoop,3], aStru[nLoop,4])
		Endif
	Next
	
	dbSelectArea(cAliasSL1)
	dbGoTop()
	nTotRegs := 10
Else
	cQuery := " L1_FILIAL              == '"+cFilSL1+ "' "
	cQuery += " .AND. L1_NUM           >= '"+MV_PAR01+"' "
	cQuery += " .AND. L1_NUM           <= '"+MV_PAR02+"' "
	cQuery += " .AND. L1_CLIENTE       >= '"+MV_PAR03+"' "
	cQuery += " .AND. L1_CLIENTE       <= '"+MV_PAR04+"' "
	cQuery += " .AND. DTOS(L1_EMISSAO) >= '"+DTOS(MV_PAR05)+"' "
	cQuery += " .AND. DTOS(L1_EMISSAO) <= '"+DTOS(MV_PAR06)+"' "
	cQuery += " .AND. L1_BLCRED        <> ' '  "
	cQuery += "	.AND. L1_BLCRED        <> '10' "
	cQuery += "	.AND. L1_BLCRED        <> '20' "
	cQuery += " .AND. L1_DOC           == '"+Space(TamSx3("F2_DOC")[1])+"' "
	cQuery += " .AND. L1_SERIE         == '"+Space(TamSx3("F2_SERIE")[1])+"'"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Abre com outro alias pois o SL1 pode estar filtrado                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ChkFile("SL1",.F.,cAliasSL1)
	dbSelectArea(cAliasSL1)
	cArqTrab := CriaTrab(nil,.F.)
	IndRegua(cAliasSL1,cArqTrab,IndexKey(),,cQuery)
	dbGotop()
	nTotRegs := (cAliasSL1)->(RecCount())
EndIf

nLoop := 0
ProcRegua(nTotRegs)
While !Eof()
	nLoop++
	If nLoop > nTotRegs
		nLoop := 1
		ProcRegua(nTotRegs)
	EndIF
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Movimenta a Regua de processamento de registros      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IncProc()
	
	dbSelectArea("SL1")
	If lQuery
		dbGoTo( (cAliasSL1)->R_E_C_N_O_  )
		RecLock("SL1",.F.)
	Else
		DbSetOrder(1)
		MsSeek(xFilial("SL1")+(cAliasSL1)->L1_NUM)
		Reclock("SL1",.F.)
	EndIf
	SL1->L1_BLCRED := "20"		//Codigo para orcamento liberado
	MsUnLock()
	
	If lLj460Aut
		ExecBlock("LJ460AUT",.F.,.F.)
	Endif
	
	dbSelectArea(cAliasSL1)
	dbSkip()
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFecha a area temporaria           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAliasSL1)
dbCloseArea()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ460LibManบAutor  ณ Jose Novaes Romeu  บ Data ณ  12/05/01  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gerar liberacoes manuais                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA460                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ460LibMan()

Local lContinua	 := .T.
Local aRecnoSL1  := {}
Local nRecNo     := RecNo()
Local nI         := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o registro posicionado eh valido                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SL1->L1_BLCRED == "10"
	MsgAlert(STR0008) //"Ja faturado"
	lContinua := .F.
ElseIf Empty(SL1->L1_BLCRED) .Or. SL1->L1_BLCRED == "20"
	MsgAlert(STR0009) //"Ja liberado"
	lContinua := .F.
Else
	nOpcA := Lj460Tela( @lContinua , .T. , .F., @aRecnoSL1)
	
	dbSelectArea("SL1")
	If ( nOpcA == 1 )
		dbGoTo(nRecNo)
		Lj460Grava(1, .T.,nRecNo)
		
	ElseIf nOpcA == 3
		dbGoTo(nRecNo)
		Lj460Grava(2, .T.,nRecNo)
	ElseIf nOpcA == 4
		For nI := 1 To Len(aRecnoSL1)
			Lj460Grava(1, .T., aRecnoSL1[nI])
		Next nI
	Endif
EndIf

Return( lContinua )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ460Grava บAutor  ณJose Novaes Romeu  บ Data ณ  12/14/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o SL1 e os acumulados referentes a atualizacao    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA460                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ460Grava(nOpc,lAtuCred,nRecSL1)

Local lCredito := Empty(SL1->L1_BLCRED)
Local nMCusto  := Val(GetMv("MV_MCUSTO"))
Local lContinua:= .T.
Local lLj460Man := ExistBlock("LJ460MAN")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona Registros                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(cFilSA1+SL1->L1_CLIENTE+SL1->L1_LOJA)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMoeda Forte do Cliente                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nMCusto:= IIf(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, nMCusto)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLiberacao do SL1                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == 1
	Begin Transaction
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAvaliacao de Credito                                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SL1->(dbGoTo(nRecSL1))
		If ( lAtuCred .And. !Empty(SL1->L1_BLCRED) )
			MaAvalSL1(4)
			lContinua := RecLock("SL1",.F.)
			If lContinua
				dbGoTo(nRecSL1)
				SL1->L1_BLCRED := "20"
				MsUnLock()
			EndIf
			MaAvalSL1(3)
			lCredito := .T.
		EndIf
	End Transaction
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRejeicao do SL1                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Begin Transaction
		MaAvalSL1(4)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEfetua o Bloqueio de Credito por Rejeicao                               ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lContinua := RecLock("SL1",.F.)
		If lContinua
			dbGoTo(nRecSL1)
			SL1->L1_BLCRED := "09"
			MsUnLock()
		EndIf
	End Transaction
EndIf

If lLj460Man
	ExecBlock("LJ460MAN",.F.,.F.,{nOpc})
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณLJ460Tela ณ Autor ณ Jose Novaes           ณ Data ณ 06.02.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Exibe a Tela de Liberacao Manual de Credito - Cred/Estoque ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Opcao Selecionada                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJ460Tela(lContinua , lAvCred , lAvEst, aRecnoSL1)

Local dLimLib		:= dDataBase
Local nSaldoLC		:= 0
Local nValItem		:= 0
Local nValPed		:= 0
Local nLimCred		:= 0
Local nMoeda		:= 0
Local nQtdVen		:= 0
Local nSalPedL		:= 0
Local nSalPed		:= 0
Local nSalDup		:= 0
Local nSalDupM		:= 0
Local nValAtraso	:= 0
Local nOpca			:= 0
Local nSalvEmp		:= 0
Local nCntFor		:= 0
Local cDescBloq	:= ""
Local cDescri		:= ""
Local oBtn
Local oDlg
Local nMCusto		:= 0
Local nMCustoCli	:= 0
Local nDecs			:= 0
Local aSaldos
Local lLiberado	:= .F.
Local nSalFin		:= 0
Local nSalFinM		:= 0
Local nLcFin		:= 0
Local nLcFinM		:= 0
Local aCols			:= {}
Local aHeader		:= {}
Local cMoeda		:= ""
Local nRecSL1
Local aAreaSL1      := {}
Local aAreaSA1      := SA1->(GetArea())
Local aAreaAtu      := GetArea()
Local cCredCli      := GetMv("MV_CREDCLI")
Local cCliente      := SL1->L1_CLIENTE
Local cLoja         := SL1->L1_LOJA

Private cCadastro := OemToAnsi(STR0010)      //"Consulta Posicao Cliente"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona Cliente                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(cFilSA1+cCliente+cLoja)

nMCusto	:= IIf(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, VAL(GetMV("MV_MCUSTO")))
cMoeda	:= " "+Pad(Getmv("MV_SIMB"+AllTrim(STR(nMCusto))),4)
nDecs	:= MsDecimais(nMcusto)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o tipo de analise a ser efetuado ( Filial ou Matriz )    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cCredCli == "L"
	nLimCred := SA1->A1_LC
	nSalPed  := SA1->A1_SALPED + SA1->A1_SALPEDB
	nSalPedL := SA1->A1_SALPEDL
	nSalDup  := SA1->A1_SALDUP
	nSalDupM := SA1->A1_SALDUPM
	nSalFin  := SA1->A1_SALFIN
	nLcFin   := SA1->A1_LCFIN
	nLcFinM  := SA1->A1_SALFINM
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSoma-se Todos os Limites de Credito do Cliente          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(cFilSA1+cCliente)
	While !Eof() .And. cFilSA1 == SA1->A1_FILIAL .And. cCliente == SA1->A1_COD
		
		nMCustoCli	:= IIf(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(GetMV("MV_MCUSTO")))
		nLimCred	+= xMoeda(SA1->A1_LC,nMCustoCli,nMCusto,dDataBase)
		nSalPed		+= xMoeda(SA1->A1_SALPED+SA1->A1_SALPEDB,nMCustoCli,nMCusto,dDataBase)
		nSalPedL	+= xMoeda(SA1->A1_SALPEDL,nMCustoCli,nMCusto,dDataBase)
		nSalDup		+= SA1->A1_SALDUP
		nSalDupM	+= xMoeda(SA1->A1_SALDUPM,nMCustoCli,nMCusto,dDataBase)
		nSalFin		+= SA1->A1_SALFIN
		nLcFin		+= xMoeda(SA1->A1_LCFIN,nMCustoCli,nMCusto,dDataBase)
		nSalFinM	+= xMoeda(SA1->A1_SALFINM,nMCustoCli,nMCusto,dDataBase)
		dbSkip()
	EndDo
EndIf

dbSelectArea("SL1")
aAreaSL1 := GetArea()
dbSetOrder(6)
dbSeek(cFilSL1+cCliente)
While !Eof() .And. lContinua
	If (cCredCli == "L") .And. (SL1->L1_LOJA <> cLoja)
		dbSkip()
		Loop
	EndIf
	
	If SL1->L1_BLCRED <> "10" .And. SL1->L1_BLCRED <> "20" .And. IIf(lAvCred,!Empty(SL1->L1_BLCRED),.F.)
		lLiberado := .T.
		If ( lContinua )
			dbSelectArea("SM2")           // Posiciona moeda da data base
			dbSetOrder(1)
			dbSeek(dDataBase,.T.)
			dbSelectArea("SL1")
			nMoeda   := IIf(SL1->L1_MOEDA < 2,1,SL1->L1_MOEDA)
			nValItem := xMoeda(SL1->L1_VLRTOT,nMoeda,nMcusto,dDataBase)
			nValPed  += nValItem
			nSalPed  -= nValItem
			nSalPed  := IIf( nSalped < 0 , 0 , nSalPed )
			
			AAdd(aRecnoSL1, RecNo())
		EndIf
	EndIf
	dbSkip()
EndDo
RestArea(aAreaSL1)

If ( !lLiberado )
	Help(" ",1,"A450JALIB")
Endif

If ( lContinua .And. lLiberado )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Reposiciona o SA1                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(cFilSA1+SL1->L1_CLIENTE+SL1->L1_LOJA)
	If SL1->L1_BLCRED == "01"
		cDescBloq := OemToAnsi(STR0011)  //"Crdito"
	ElseIf SL1->L1_BLCRED == "04"
		cDescBloq := OemToAnsi(STR0012)  //"Limite de Crdito Vencido"
	ElseIf SL1->L1_BLCRED == "09"
		cDescBloq := OemToAnsi(STR0013)  //"Rejeitado"
	EndIf
	cDescri := Substr(SA1->A1_NOME,1,35)
	
	aSaldos	        	:= Array(_STRASALDOS)
	aSaldos[_LIMCREDM] 	:= nLimCred
	aSaldos[_LIMCRED ] 	:= xMoeda(nLimCred,nMCusto,1)
	aSaldos[_SALDUPM ] 	:= nSalDupM
	aSaldos[_SALDUP  ] 	:= nSalDup
	aSaldos[_SALPEDLM] 	:= nSalPedL
	aSaldos[_SALPEDL ] 	:= xMoeda(nSalPedL,nMCusto,1)
	aSaldos[_MCOMPRAM] 	:= SA1->A1_MCOMPRA
	aSaldos[_MCOMPRA ] 	:= xMoeda(SA1->A1_MCOMPRA,nMCusto,1)
	aSaldos[_SALDOLCM] 	:= nLimCred-nSaldupM-nSalPedL
	aSaldos[_SALDOLC ] 	:= xMoeda(nLimCred-nSaldupM-nSalPedL,nMCusto,1)
	aSaldos[_MAIDUPLM] 	:= SA1->A1_MAIDUPL
	aSaldos[_MAIDUPL ] 	:= xMoeda(SA1->A1_MAIDUPL,nMCusto,1)
	aSaldos[_ITATUM  ] 	:= xMoeda(SL1->L1_VLRTOT,nMoeda,nMcusto)
	aSaldos[_ITATU   ] 	:= xMoeda(SL1->L1_VLRTOT,nMoeda,1)
	aSaldos[_PEDATUM ] 	:= nValPed
	aSaldos[_PEDATU  ]	:= xMoeda(nValPed ,nMCusto,1)
	aSaldos[_SALPEDM ]	:= nSalPed
	aSaldos[_SALPED  ]	:= xMoeda(nSalPed ,nMCusto,1)
	aSaldos[_VALATRM ] 	:= xMoeda(nValAtraso,1,nMCusto)
	aSaldos[_VALATR  ] 	:= nValAtraso
	aSaldos[_LCFINM  ] 	:= nLcFin
	aSaldos[_LCFIN   ] 	:= xMoeda(nLCFin,nMcusto,1)
	aSaldos[_SALFINM ] 	:= nSalFinM
	aSaldos[_SALFIN  ] 	:= nSalFin
	
	aHeader  := {OemToAnsi(STR0015),OemToAnsi(STR0016),OemToAnsi(STR0017)+AllTrim(cMoeda)," ",OemToAnsi(STR0015),;
	OemToAnsi(STR0021)}
	
	Aadd(aCols,{OemToAnsi(STR0018),TRansform(aSaldos[_LIMCRED],PesqPict("SA1","A1_LC",14,1)),;
	TRansform(aSaldos[_LIMCREDM],PesqPict("SA1","A1_LC",14,nMcusto))," ",;
	OemToAnsi(STR0019),Space(02)+STR(SA1->A1_TITPROT,3)+Space(05)+;
	OemToAnsi(STR0020)+Space(03)+DtoC(SA1->A1_DTULTIT)}) //Limite de Credito/Tit.Protestados/DT.ULT TIT
	
	Aadd(aCols,{OemToAnsi(STR0022),TRansform(aSaldos[_SALDUP],PesqPict("SA1","A1_SALDUP",14,1)),;
	TRansform(aSaldos[_SALDUPM],PesqPict("SA1","A1_SALDUPM",14,nMcusto))," ",;
	OemToAnsi(STR0023),Space(02)+STR(SA1->A1_CHQDEVO,3)+Space(05)+;
	OemToAnsi(STR0024)+Space(03)+DtoC(SA1->A1_DTULCHQ)}) // Saldo Titulos / Cheques Devolvidos/DT.ULT.CHQ
	
	Aadd(aCols,{OemToAnsi(STR0025),TRansform(aSaldos[_SALPEDL],PesqPict("SA1","A1_SALPEDL",14,1)),;
	TRansform(aSaldos[_SALPEDLM],PesqPict("SA1","A1_SALPEDL",14,nMcusto))," ",OemToAnsi(STR0026),;
	Transform(aSaldos[_MCOMPRAM],PesqPict("SA1","A1_MCOMPRA",17,nMCusto))}) // Orcamentos Aprovados/Maior Compra
	
	Aadd(aCols,{OemToAnsi(STR0027),TRansform(aSaldos[_SALDOLC],PesqPict("SA1","A1_SALDUP",14,1)),;
	TRansform(aSaldos[_SALDOLCM],PesqPict("SA1","A1_SALDUPM",14,nMcusto))," ",;
	OemToAnsi(STR0028),Transform(aSaldos[_MAIDUPLM],PesqPict("SA1","A1_MAIDUPL",17,nMCusto))}) // Saldo Lim Credito/Maior Duplicata
	
	Aadd(aCols,{OemToAnsi(STR0029),TRansform(aSaldos[_ITATU],PesqPict("SA1","A1_SALDUP",14,1)),;
	TRansform(aSaldos[_ITATUM],PesqPict("SA1","A1_SALDUP",14,nMcusto))," ",;
	OemToAnsi(STR0030),Space(14)+Transform(SA1->A1_METR,PesqPict("SA1","A1_METR",7))+Space(04)+;
	OemToAnsi(STR0031)}) // Item do Orcamento/dia(s)/Media de Atraso
	
	Aadd(aCols,{OemToAnsi(STR0034),TRansform(aSaldos[_SALPED],PesqPict("SA1","A1_SALPED",14,1)),;
	TRansform(aSaldos[_SALPEDM],PesqPict("SA1","A1_SALPED",14,nMcusto))," ",;
	OemToAnsi(STR0035),Space(10)+DtoC(dLimLib)}) // Saldo de Orcamentos / Data Limite para Liberacao
	
	Aadd(aCols,{OemToAnsi(STR0036),TRansform(aSaldos[_LCFIN],PesqPict("SA1","A1_LC",14,1)),;
	TRansform(aSaldos[_LCFINM],PesqPict("SA1","A1_LC",14,nMcusto))," ",;
	OemToAnsi(STR0037),TRansform(aSaldos[_VALATR],PesqPict("SA1","A1_SALDUP",17,1))}) //Lim. de Cred. em Cheque/Atraso Atual
	
	Aadd(aCols,{OemToAnsi(STR0038),TRansform(aSaldos[_SALFIN],PesqPict("SA1","A1_SALDUP",14,1)),;
	TRansform(aSaldos[_SALFINM],PesqPict("SA1","A1_SALDUP",14,nMcusto))," ",,,}) // Saldo em Cheques
	DEFINE MSDIALOG oDlg FROM  125,3 TO 430,608 TITLE OemToAnsi(STR0001) PIXEL    //"Liberacao de Credito"
	
	@ 003, 004  TO 033, 295 LABEL "" OF oDlg  PIXEL
	@ 130, 004  TO 150, 155 LABEL "" OF oDlg  PIXEL
	@ 130, 160  TO 150, 240 LABEL "" OF oDlg  PIXEL
	
	DEFINE SBUTTON FROM 134, 242 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 134, 272 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
	@ 135, 010 BUTTON OemToAnsi(STR0040)   SIZE 34,11 FONT oDlg:oFont ACTION (cCadastro:=OemToAnsi(STR0037),AxVisual("SA1",SA1->(RecNo()),1),cCadastro:= OemToAnsi(STR0005) ) OF oDlg PIXEL   	//"Cliente"
	@ 135, 165 BUTTON OemToAnsi(STR0043)   SIZE 34,11 FONT oDlg:oFont ACTION (nOpca := 4,oDlg:End() ) OF oDlg PIXEL     				//"Lib.Todos"
	@ 135, 200 BUTTON OemToAnsi(STR0044)   SIZE 34,11 FONT oDlg:oFont ACTION (nOpca := 3,oDlg:End() ) OF oDlg PIXEL     				//"Rejeita"
	
	@ 010, 011 SAY OemToAnsi(STR0045)      SIZE 31, 7 OF oDlg PIXEL   //"Orcamento :"
	@ 010, 040 SAY SL1->L1_NUM    SIZE 26, 7 OF oDlg PIXEL
	@ 010, 090 SAY OemToAnsi(STR0046)      SIZE 35, 7 OF oDlg PIXEL   //"Cond.Pagto. :"
	@ 010, 128 SAY SL1->L1_COND    SIZE 09, 7 OF oDlg PIXEL
	@ 010, 170 SAY OemToAnsi(STR0047)      SIZE 27, 7 OF oDlg PIXEL   //"Bloqueio :"
	@ 010, 201 SAY cDescBloq               SIZE 83, 7 OF oDlg PIXEL
	
	@ 021, 011 SAY OemToAnsi(STR0048)      SIZE 24, 7 OF oDlg PIXEL   //"Cliente :"
	@ 021, 040 SAY cDescri                 SIZE 96, 7 OF oDlg PIXEL
	@ 021, 170 SAY OemToAnsi(STR0049)      SIZE 22, 7 OF oDlg PIXEL   //"Risco :"
	@ 021, 201 SAY SA1->A1_RISCO           SIZE 11, 7 OF oDlg PIXEL
	@ 021, 240 SAY OemToAnsi(STR0017+GetMv("MV_SIMB"+Alltrim(STR(nMCusto))))  SIZE 50, 7 OF oDlg PIXEL //"Valores em "
	
	oLbx := RDListBox(2.48, .5, 291, 95, aCols, aHeader,{55,50,50,12,55,69})
	
	ACTIVATE MSDIALOG oDlg
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Retorna as areas originais.     |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea(aAreaSA1)
RestArea(aAreaAtu)

Return(nOpcA)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ460LegendบAutor  ณJose Novaes Romeu  บ Data ณ  11/22/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Demonstra a legenda das cores da mbrowse                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA010E                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ460Legend()
BrwLegenda(cCadastro,OemToAnsi(STR0005),; //"Legenda"
{	{"ENABLE" ,OemToAnsi(STR0050)},; //"Item Liberado"
{"BR_AZUL",OemToAnsi(STR0052)} })  //"Item Bloqueado"
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMaAvalSL1 บAutor  ณJose Novaes Romeu   บ Data ณ  12/14/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA010E                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MaAvalSL1(nEvento)

Local lContinua := .T.
Local lBlqCred  := !Empty(SL1->L1_BLCRED) .And. SL1->L1_BLCRED != "20"
Local lFaturado := SL1->L1_BLCRED == "10"
Local nMCusto   := 0

If nEvento == 3
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(cFilSA1+SL1->L1_CLIENTE+SL1->L1_LOJA)
	lContinua := RecLock("SA1",.F.)
	
	If lContinua
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza a Liberacao de Credito                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nMCusto := IIf(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC, nMCusto)
		nSldLib := xMoeda(SL1->L1_VLRTOT,SL1->L1_MOEDA,nMCusto,dDataBase)
		If !lBlqCred
			SA1->A1_SALPEDL += nSldLib
		Else
			SA1->A1_SALPEDB += nSldLib
		EndIf
		MsUnLock()
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEstorno da Liberacao de Credito de um item liberado do Orcamento        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nEvento == 4
	If !lFaturado .And. (SL1->L1_BLCRED <> "09")
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(cFilSA1+SL1->L1_CLIENTE+SL1->L1_LOJA)
		lContinua := RecLock("SA1",.F.)
		
		If lContinua
			nMCusto := IIf(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC, nMCusto)
			nSldLib := xMoeda(SL1->L1_VLRTOT,SL1->L1_MOEDA,nMCusto,dDataBase)
			If !lBlqCred
				SA1->A1_SALPEDL -= nSldLib
			Else
				SA1->A1_SALPEDB -= nSldLib
			EndIf
			MsUnLock()
		EndIf
	EndIf
EndIf

Return(.T.)
