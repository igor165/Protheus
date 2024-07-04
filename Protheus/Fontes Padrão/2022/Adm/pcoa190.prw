#INCLUDE "pcoa190.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

Static lPcoa190 := .F.
Static nQtdEntid

/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOA190  ณ AUTOR ณ Edson Maricate        ณ DATA ณ 14.02.2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa para manutencao dos cubos gerenciais                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOA190                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa para manutencao dos cubos estrat้gicos .            ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOA190(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                        zacao da rotina.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA190(nCallOpcx, nTpExib)

Private cCadastro	:= STR0001 //"Manuten็ใo de Cubos Gerenciais"
Private AUXCHAVE	:= ""
Private aRotina
Private aUsRotina 

AUXCHAVE	:= ""

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	aRotina := MenuDef()

	If nTpExib == NIL
		nTpExib := A190Exibe()
		If nTpExib == 0
			Return
		EndIf	
    EndIf
    
    If nTpExib == 1
		mBrowse(6,1,22,75,"AL1")
	Else
		A190Tree(aUsRotina)
	EndIf
		
EndIf

If ! lPcoa190 // para nao causar recursividade
	Pcoa190Check()
	lPcoa190 := .F.
EndIf

Return

Function Pcoa190Brw(cAlias,nReg,nOpcx,cR1,cR2,lRet)
Local aSize		:= MsAdvSize(,.F.,430)
Local cCube		:= AL1->AL1_CONFIG
Local l190Visual := .F.
Local l190Inclui := .F.
Local l190Deleta := .F.
Local l190Altera := .F.
Local aIndexAKW	:= {}
Local cFiltraAKW	:= " AKW->AKW_FILIAL=='"+xFilial("AKW")+"' .And. AKW->AKW_COD=='"+AL1->AL1_CONFIG+"' "

SaveInter()
				
PRIVATE bFiltraBrw	:= {|| Nil}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
Case aRotina[nOpcX][4] == 2
	l190Visual := .T.
Case aRotina[nOpcX][4] == 3 
	l190Inclui	:= .T.
Case aRotina[nOpcX][4] == 4
	l190Altera	:= .T.
Case aRotina[nOpcX][4] == 5
	l190Deleta	:= .T.
	l190Visual	:= .T.
EndCase

If l190Deleta 
	// Chama funcao PCOA190FK para apagar as linhas relacionadas ao cubo atualmente selecionado p/ exclusao
	// Executada antes de excluir o cubo da tabela AL1.
	If AxDeleta(cAlias,nReg,nOpcx,"PCOA190FK('"+cCube+"')") == 2
		lRet := .T.
	EndIf	
ElseIf l190Inclui
	Inclui := .T.
	Altera := .F.
	AxInclui(cAlias,nReg,nOpcx,,,,,,"Pcoa190Brw('AL1',AL1->(RecNo()),4)") 
EndIf
	
If l190Altera
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRedefine o aRotina                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aRotina 	:= {	{ STR0008, 	"AxVisual" , 0 , 2},;     //"&Visualizar"
						{ STR0009, 		"Pco190Inc" , 0 , 3},;	   //"&Incluir"
						{ STR0010, 		"Pco190Alt" , 0 , 4},;  //"&Alterar"
						{ STR0011, 		"Pco190Del" , 0 , 5}}  //"&Excluir"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRealiza a Filtragem                                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	bFiltraBrw := {|| FilBrowse("AKW",@aIndexAKW,@cFiltraAKW) }
	Eval(bFiltraBrw)
	dbGoTop()
	
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AKW",,aRotina,,,,.F.)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	EndFilBrw("AKW",aIndexAKW)		
EndIf

RestInter()

Return



Function Pco190Inc(cAlias,nReg,nOpc)
Local aButtons := { {"BMPCPO",{|| a190Suges() },STR0012,STR0013} } //"Campos Pre-selecionados"###"Pre-Selec."
Inclui := .T.
Altera := .F.
Return AxInclui(cAlias,nReg,nOpc,,,,"Pco190Vld(3)",,"Pco190Atu",aButtons)


Function Pco190Del(cAlias,nReg,nOpc)
Local lRet := .F.
Local cConfig	:=	AKW->AKW_COD
Local cNivel	:=	AKW->AKW_NIVEL
If AxDeleta(cAlias,nReg,nOpc) == 2
	lRet := .T.
	Pco190Atu(cConfig,cNivel)
EndIf

Return lRet




Function Pco190Alt(cAlias,nReg,nOpc)
Local aButtons := { {"BMPCPO",{|| a190Suges() },STR0012,STR0013} } //"Campos Pre-selecionados"###"Pre-Selec."
Inclui := .F.
Altera := .T.
Return AxAltera(cAlias,nReg,nOpc,,,,,"Pco190Vld(4)","Pco190Atu",,aButtons)


Function Pco190Atu(cConfig,cNivel)
Local aArea		:= GetArea()	
Local aAreaAL1	:= AL1->(GetArea())
Local aAreaAKW	:= AKW->(GetArea())

Local cChaveR	:= ""
Local cDescri	:= ""                               	

DEFAULT cNivel	:= M->AKW_NIVEL
DEFAULT cConfig:= M->AKW_COD

dbSelectArea("AKW")
dbSetOrder(1)
dbSeek(xFilial()+cConfig)
While !Eof() .And. xFilial()+cConfig== AKW->AKW_FILIAL+AKW->AKW_COD
	cChaveR += "+"+AllTrim(AKW->AKW_CHAVER)
	cDescri += "+"+AllTrim(AKW->AKW_DESCRI)

	If AKW->AKW_NIVEL == cNivel
		RecLock("AKW",.F.)
		AKW->AKW_CONCDE  	:= Substr(cDescri,2,Len(cDescri))
		AKW->AKW_CONCCH	:= Substr(cChaveR,2,Len(cChaveR))
		MsUnlock()
	EndIf
	AKW->(dbSkip())
End
cChaveR := Substr(cChaveR,2,Len(cChaveR))
cDescri := Substr(cDescri,2,Len(cDescri))

dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial()+cConfig)
RecLock("AL1",.F.)
AL1->AL1_CONCDE 	:= cDescri
AL1->AL1_CHAVER	:= cChaveR
MsUnlock()


RestArea(aAreaAKW)
RestArea(aAreaAL1)
RestArea(aArea)
Return


Function PcoChkAKW()
Local nX, nY, nZ, nReg
Local aCubos		:= {}
Local aIt_Cubos	:= {}
Local aConta 		:= {}
Local aClasse     := {}
Local aOperacao	:= {}
Local aTipoSaldo	:= {}
Local aPlanilha	:= {}
Local aCtCusto    := {}
Local aDimensao  := {}
Local aEstrCubo 	:= {"AL1_CONFIG", "AL1_DESCRI"}
Local aEstrItens  := {"AKW_COD", "AKW_NIVEL"}
Local cCubo, cNivel, nCpo, nPosCube
Local aCposNew := {}, lNewCpos := .T.

aAdd(aCposNew, "AKD_CODPLA")
aAdd(aCposNew, "AKD_VERSAO")
aAdd(aCposNew, "AKD_CC")
aAdd(aCposNew, "AKD_ITCTB")
aAdd(aCposNew, "AKD_CLVLR")

aAdd(aConta, {"AKW_DESCRI","CO"} )
aAdd(aConta, {"AKW_CHAVER","AKD->AKD_CO"} )
aAdd(aConta, {"AKW_TAMANH",Len(AKD->AKD_CO)} )
aAdd(aConta, {"AKW_CONCDE",""} )
aAdd(aConta, {"AKW_CONCCH",""} )
aAdd(aConta, {"AKW_ALIAS", "AK5"} )
aAdd(aConta, {"AKW_F3", "AK5"} )
aAdd(aConta, {"AKW_RELAC", "AK5->AK5_CODIGO"} )
aAdd(aConta, {"AKW_DESCRE", "AK5->AK5_DESCRI"} )
aAdd(aConta, {"AKW_ATUSIN", "Posicione('AK5',1,xFilial('AK5')+AUXCHAVE,'AK5_COSUP')"} )
aAdd(aConta, {"AKW_RECDES", ""} )
aAdd(aConta, {"AKW_OBRIGA", "1"} )
aAdd(aConta, {"AKW_CNDSIN", "AK5->AK5_TIPO=='1'"} )
aAdd(aConta, {"AKW_CODREL", "PcoRetCO(AK5->AK5_CODIGO,AK5->AK5_MASC)"} )

aAdd(aClasse, {"AKW_DESCRI",STR0021} )//"CLASSE"
aAdd(aClasse, {"AKW_CHAVER","AKD->AKD_CLASSE"} )
aAdd(aClasse, {"AKW_TAMANH",Len(AKD->AKD_CLASSE)} )
aAdd(aClasse, {"AKW_CONCDE",""} )
aAdd(aClasse, {"AKW_CONCCH",""} )
aAdd(aClasse, {"AKW_ALIAS", "AK6"} )
aAdd(aClasse, {"AKW_F3", "AK6"} )
aAdd(aClasse, {"AKW_RELAC", "AK6->AK6_CODIGO"} )
aAdd(aClasse, {"AKW_DESCRE", "AK6->AK6_DESCRI"} )
aAdd(aClasse, {"AKW_ATUSIN", ""} )
aAdd(aClasse, {"AKW_RECDES", ""} )
aAdd(aClasse, {"AKW_OBRIGA", "1"} )

aAdd(aOperacao, {"AKW_DESCRI",STR0022} )//"OPERACAO"
aAdd(aOperacao, {"AKW_CHAVER","AKD->AKD_OPER"} )
aAdd(aOperacao, {"AKW_TAMANH",Len(AKD->AKD_OPER)} )
aAdd(aOperacao, {"AKW_CONCDE",""} )
aAdd(aOperacao, {"AKW_CONCCH",""} )
aAdd(aOperacao, {"AKW_ALIAS", "AKF"} )
aAdd(aOperacao, {"AKW_F3", "AKF"} )
aAdd(aOperacao, {"AKW_RELAC", "AKF->AKF_CODIGO"} )
aAdd(aOperacao, {"AKW_DESCRE", "AKF->AKF_DESCRI"} )
aAdd(aOperacao, {"AKW_ATUSIN", ""} )
aAdd(aOperacao, {"AKW_RECDES", ""} )
aAdd(aOperacao, {"AKW_OBRIGA", "2"} )

aAdd(aTipoSaldo, {"AKW_DESCRI",STR0025} )//"TP.SALDO"
aAdd(aTipoSaldo, {"AKW_CHAVER","AKD->AKD_TPSALD"} )
aAdd(aTipoSaldo, {"AKW_TAMANH",Len(AKD->AKD_TPSALD)} )
aAdd(aTipoSaldo, {"AKW_CONCDE",""} )
aAdd(aTipoSaldo, {"AKW_CONCCH",""} )
aAdd(aTipoSaldo, {"AKW_ALIAS", "AL2"} )
aAdd(aTipoSaldo, {"AKW_F3", "AL2A"} )
aAdd(aTipoSaldo, {"AKW_RELAC", "AL2->AL2_TPSALD"} )
aAdd(aTipoSaldo, {"AKW_DESCRE", "AL2->AL2_DESCRI"} )
aAdd(aTipoSaldo, {"AKW_ATUSIN", ""} )
aAdd(aTipoSaldo, {"AKW_RECDES", ""} )
aAdd(aTipoSaldo, {"AKW_OBRIGA", "1"} )

aAdd(aPlanilha, {"AKW_DESCRI",UPPER(STR0018)} )//"PLANILHA"
aAdd(aPlanilha, {"AKW_CHAVER","AKD->AKD_CODPLA+AKD->AKD_VERSAO"} )
aAdd(aPlanilha, {"AKW_TAMANH",Len(AK1->AK1_CODIGO)+LEN(AKE->AKE_REVISA)} )
aAdd(aPlanilha, {"AKW_CONCDE",""} )
aAdd(aPlanilha, {"AKW_CONCCH",""} )
aAdd(aPlanilha, {"AKW_ALIAS", "AKE"} )
aAdd(aPlanilha, {"AKW_F3", "AKE2"} )
aAdd(aPlanilha, {"AKW_RELAC", "AKE->AKE_ORCAME+AKE->AKE_REVISA"} )
aAdd(aPlanilha, {"AKW_DESCRE", "AKE->AKE_ORCAME+AKE->AKE_REVISA"} )
aAdd(aPlanilha, {"AKW_ATUSIN", ""} )
aAdd(aPlanilha, {"AKW_RECDES", ""} )
aAdd(aPlanilha, {"AKW_OBRIGA", "2"} )

aAdd(aCtCusto, {"AKW_DESCRI", STR0019 } ) //"CENTRO CUSTO"
aAdd(aCtCusto, {"AKW_CHAVER","AKD->AKD_CC"} )
aAdd(aCtCusto, {"AKW_TAMANH",Len(CTT->CTT_CUSTO)} )
aAdd(aCtCusto, {"AKW_CONCDE",""} )
aAdd(aCtCusto, {"AKW_CONCCH",""} )
aAdd(aCtCusto, {"AKW_ALIAS", "CTT"} )
aAdd(aCtCusto, {"AKW_F3", "CTT"} )
aAdd(aCtCusto, {"AKW_RELAC", "CTT->CTT_CUSTO"} )
aAdd(aCtCusto, {"AKW_DESCRE", "CTT->CTT_CUSTO"} )
aAdd(aCtCusto, {"AKW_ATUSIN", ""} )
aAdd(aCtCusto, {"AKW_RECDES", ""} )
aAdd(aCtCusto, {"AKW_OBRIGA", "2"} )

aAdd(aDimensao, { aConta, aClasse,  aTipoSaldo })
aAdd(aDimensao, { aConta, aOperacao,aTipoSaldo })
aAdd(aDimensao, { aClasse, aConta, aTipoSaldo })


AKD->(aEval(aCposNew, ;
					{|cValue,nIndex| lNewCpos := lNewCpos .And. FieldPos(cValue) > 0 }))
If lNewCpos
	aAdd(aDimensao, { aConta, aClasse, aPlanilha, aTipoSaldo })
EndIf

For nX := 1 TO Len(aDimensao)
   cCubo := StrZero(nX, Len(AL1->AL1_CONFIG))
	aAdd(aCubos,	{cCubo, STR0026+cCubo, 0})//"CUBO GERENCIAL "
	
	For nY := 1 TO Len(aDimensao[nX])
		cNivel := StrZero(nY, Len(AKW->AKW_NIVEL))
		aAdd(aIt_Cubos, { cCubo, cNivel, aClone(aDimensao[nX][nY]) })
	Next
Next

//popula as tabelas de cubos
dbSelectArea("AL1")

Begin Transaction

For nX := 1 TO Len(aCubos)
	If ! dbSeek(xFilial("AL1")+aCubos[nX][1])
		RecLock("AL1", .T.)
		AL1->AL1_FILIAL := xFilial("AL1")
		For nY := 1 TO Len(aEstrCubo)
			nCpo := FieldPos(aEstrCubo[nY])
			If nCpo > 0
				FieldPut(nCpo, aCubos[nX][nY])
			EndIf
		Next		
		MsUnLock()
		FKCommit()
	Else 
		aCubos[nX][3] := 1
	EndIf
Next


dbSelectArea("AKW")

For nX := 1 TO Len(aIt_Cubos)
	cCubo := aIt_Cubos[nX][1]
	nPosCube := Ascan(aCubos, {|aVal| aVal[1] == cCubo})
	If aCubos[nPosCube][3] == 0  //se nao existe na base
		RecLock("AKW", .T.)
		AKW->AKW_FILIAL := xFilial("AKW")
		For nY := 1 TO Len(aEstrItens)
			nCpo := FieldPos(aEstrItens[nY])
			If nCpo > 0
				FieldPut(nCpo, aIt_Cubos[nX][nY])
			EndIf
		Next
		nReg := Len(aEstrItens)+1
		For nZ := 1 TO Len(aIt_Cubos[nX][nReg])
			nCpo := FieldPos(aIt_Cubos[nX][nReg][nZ][1])
			If nCpo > 0
				FieldPut(nCpo,aIt_Cubos[nX][nReg][nZ][2])
			EndIf
		Next
		MsUnLock()
	EndIf
Next

dbSelectArea("AL1")
For nX := 1 TO Len(aCubos)

	If aCubos[nX][3] == 0  .And. ; //se nao existia na base
		dbSeek(xFilial("AL1")+aCubos[nX][1])
		
		dbSelectArea("AKW")
	
		If dbSeek(xFilial("AKW")+aCubos[nX][1])
		
		   While AKW->(!Eof() .And. AKW_FILIAL+AKW_COD == xFilial("AKW")+aCubos[nX][1])
		
				RegToMemory("AKW",.F.)
				Pco190Atu()
				dbSelectArea("AKW")
				dbSkip()
		
			End
		
		EndIf

		dbSeek(xFilial("AL1")+aCubos[nX][1])		
		RecLock("AL1",.F.)
		AL1->AL1_DESCRI := AL1->AL1_CONCDE
		MsUnLock()
			
	EndIf

Next

End Transaction

Return

Function A190Suges(oGetAKW)
Local aParametros	:= {{3,STR0014,1,{STR0015,STR0016,STR0017,STR0018,STR0019,RetTitle("CTD_ITEM"),RetTitle("CTH_CLVL"),STR0020},95,,.F.}} //"Selecione o Campo"###"Conta Or็amentaria"###"Classe Or็amentแria"###"Opera็ใo"###"Planilha"###"Centro de Custo"###"Tipo de Saldo"
Local aRet			:= {}
Local cChaveR		:= ""
Local cDescri		:= ""
Local nRecAKW		:= 0
Local aConfUsr		:= Nil
Local nPadroes		:= Len(aParametros[1][4])
Local nPosConf		:= 0
Local nX			:= 0
Local nEntAdSel		:= 0	//Armazena a entidade adicional selecionda
Local cIdEntAd		:= ""	//Armazena o ID da entidade adicional

//---------------------------------
// Adiciona a Unidade Orcamentaria
//---------------------------------
If AKD->(FieldPos("AKD_UNIORC")) > 0
	Aadd(aParametros[1][4], STR0058) //"Unidade Or็amentแria"
	nPadroes := Len(aParametros[1][4])
EndIf

//----------------------------------
// Adiciona as Entidades Adicionais
//----------------------------------
If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf
If nQtdEntid > 4
	DbSelectArea("CT0")
	DbSetOrder(1) //CT0_FILIAL+CT0_ID
	For nX := 5 To nQtdEntid
		If DbSeek(XFilial("CT0")+StrZero(nX,TamSX3("CT0_ID")[1]))
			Aadd(aParametros[1][4], AllTrim(CT0->CT0_DESC))
		EndIf
	Next nX
	nPadroes := Len(aParametros[1][4])
EndIf

If ExistBlock('PCO190SG')
	aConfUsr	:=	ExecBLock('PCO190SG')
	If ValType(aConfUsr) == "A"
		For nX :=1 To Len(aConfUsr)
			aAdd(aParametros[1][4],aConfUsr[nX][1])
		Next
	Endif
Endif

If ParamBox(aParametros,STR0012,aRet) //"Campos pre-selecionados"
	M->AKW_DESCRI	:= ""
	M->AKW_CHAVER 	:= ""
	M->AKW_TAMANH	:= 0
	M->AKW_ALIAS	:= ""
	M->AKW_F3		:= ""
	M->AKW_RELAC	:= ""
	M->AKW_DESCRE	:= ""
	M->AKW_ATUSIN	:= ""
	M->AKW_OBRIGA	:= ""
	M->AKW_CNDSIN	:= ""
	M->AKW_CODREL	:= ""

	Do Case
		Case aRet[1] == 1
			M->AKW_DESCRI	:= "CO"
			M->AKW_CHAVER 	:= "AKD->AKD_CO"
			M->AKW_TAMANH	:= LEN(AKD->AKD_CO)
			M->AKW_ALIAS	:= "AK5"
			M->AKW_F3		:= "AK5"
			M->AKW_RELAC	:= "AK5->AK5_CODIGO"
			M->AKW_DESCRE	:= "AK5->AK5_DESCRI"
			M->AKW_ATUSIN	:= "Posicione('AK5',1,xFilial('AK5')+AUXCHAVE,'AK5_COSUP')"
			M->AKW_OBRIGA	:= "1"
			M->AKW_CNDSIN	:= "AK5->AK5_TIPO=='1'"
			M->AKW_CODREL	:= "PcoRetCO(AK5->AK5_CODIGO,AK5->AK5_MASC)"
		Case aRet[1] == 2
			M->AKW_DESCRI	:= STR0021 //"CLASSE"
			M->AKW_CHAVER	:= "AKD->AKD_CLASSE"
			M->AKW_TAMANH	:= LEN(AKD->AKD_CLASSE)
			M->AKW_ALIAS	:= "AK6"
			M->AKW_F3		:= "AK6"
			M->AKW_RELAC	:= "AK6->AK6_CODIGO"
			M->AKW_DESCRE	:= "AK6->AK6_DESCRI"
			M->AKW_OBRIGA	:= "1"
		Case aRet[1] == 3
			M->AKW_DESCRI	:= STR0022 //"OPERAวยO"
			M->AKW_CHAVER	:= "AKD->AKD_OPER"
			M->AKW_TAMANH	:= LEN(AKD->AKD_OPER)
			M->AKW_ALIAS	:= "AKF"
			M->AKW_F3		:= "AKF"
			M->AKW_RELAC	:= "AKF->AKF_CODIGO"
			M->AKW_DESCRE	:= "AKF->AKF_DESCRI"
			M->AKW_OBRIGA	:= "2"
		Case aRet[1] == 4
			M->AKW_DESCRI	:= UPPER(STR0018) //"PLANILHA"
			M->AKW_CHAVER	:= "AKD->AKD_CODPLA+AKD->AKD_VERSAO"
			M->AKW_TAMANH	:= LEN(AKD->AKD_CODPLA)+LEN(AKD->AKD_VERSAO)
			M->AKW_ALIAS	:= "AKE"
			M->AKW_F3		:= "AKE2"
			M->AKW_RELAC	:= "AKE->AKE_ORCAME+AKE->AKE_REVISA"
			M->AKW_DESCRE	:= "'"+STR0023+"'+AllTrim(AKE->AKE_ORCAME)+'"+STR0024+"'+AllTrim(AKE->AKE_REVISA)" //'PLANILHA : '###' VERSAO : '
			M->AKW_OBRIGA	:= "2"
		Case aRet[1] == 5
			M->AKW_DESCRI	:= STR0019 //"CENTRO DE CUSTO"
			M->AKW_CHAVER	:= "AKD->AKD_CC"
			M->AKW_TAMANH	:= LEN(AKD->AKD_CC)
			M->AKW_ALIAS	:= "CTT"
			M->AKW_F3		:= "CTT"
			M->AKW_RELAC	:= "CTT->CTT_CUSTO"
			M->AKW_DESCRE	:= "CTT->CTT_DESC01"
			M->AKW_ATUSIN	:= "Posicione('CTT',1,xFilial('CTT')+AUXCHAVE,'CTT_CCSUP')"
			M->AKW_CNDSIN	:= "CTT->CTT_CLASSE=='1'"
			M->AKW_OBRIGA	:= "2" 
		Case aRet[1] == 6
			M->AKW_DESCRI	:= RetTitle("CTD_ITEM")	// "Item"
			M->AKW_CHAVER	:= "AKD->AKD_ITCTB"
			M->AKW_TAMANH	:= LEN(AKD->AKD_ITCTB)
			M->AKW_ALIAS	:= "CTD"
			M->AKW_F3		:= "CTD"
			M->AKW_RELAC	:= "CTD->CTD_ITEM"
			M->AKW_DESCRE	:= "CTD->CTD_DESC01"
			M->AKW_ATUSIN	:= "Posicione('CTD',1,xFilial('CTD')+AUXCHAVE,'CTD_ITSUP')"
			M->AKW_CNDSIN	:= "CTD->CTD_CLASSE=='1'"			
			M->AKW_OBRIGA	:= "2" 
		Case aRet[1] == 7
			M->AKW_DESCRI	:= RetTitle("CTH_CLVL")	// "Classe Valor"
			M->AKW_CHAVER	:= "AKD->AKD_CLVLR"
			M->AKW_TAMANH	:= LEN(AKD->AKD_CLVLR)
			M->AKW_ALIAS	:= "CTH"
			M->AKW_F3		:= "CTH"
			M->AKW_RELAC	:= "CTH->CTH_CLVL"
			M->AKW_DESCRE	:= "CTH->CTH_DESC01"
			M->AKW_ATUSIN	:= "Posicione('CTH',1,xFilial('CTH')+AUXCHAVE,'CTH_CLSUP')"
			M->AKW_CNDSIN	:= "CTH->CTH_CLASSE=='1'"			
			M->AKW_OBRIGA	:= "2" 
		Case aRet[1] == 8
			M->AKW_DESCRI	:= STR0025 //"TP.SALDO"
			M->AKW_CHAVER	:= "AKD->AKD_TPSALD"
			M->AKW_TAMANH	:= LEN(AKD->AKD_TPSALD)
			M->AKW_ALIAS	:= "AL2"
			M->AKW_F3		:= "AL2A"
			M->AKW_RELAC	:= "AL2->AL2_TPSALD"
			M->AKW_DESCRE	:= "AL2->AL2_DESCRI"
			M->AKW_OBRIGA	:= "1"           
		Case (aRet[1] == 9 .And. aRet[1] <= nPadroes) .And. AKD->(FieldPos("AKD_UNIORC")) > 0
		   	M->AKW_DESCRI   := STR0058 //"Unidade Or็amentแria"
		   	M->AKW_CHAVER   := "AKD->AKD_UNIORC"
			M->AKW_TAMANH	:= TamSX3("AKD_UNIORC")[1]
			M->AKW_ALIAS	:= "AMF"
			M->AKW_F3		:= "AMF"
			M->AKW_RELAC	:= "AMF->AMF_CODIGO"
			M->AKW_DESCRE	:= "AMF->AMF_DESCRI"
			M->AKW_OBRIGA	:= "2"

		Case (aRet[1] > 8 .And. aRet[1] <= nPadroes) .And. nQtdEntid > 4

			nEntAdSel	:= nQtdEntid - (nPadroes - aRet[1])
			cIdEntAd	:= StrZero(nEntAdSel,TamSX3("CT0_ID")[1])

			DbSelectArea("CT0")
			DbSetOrder(1)
			If DbSeek(XFilial("CT0") + cIdEntAd)

				M->AKW_DESCRI	:= CT0->CT0_DESC
			   	M->AKW_CHAVER	:= "AKD->AKD_ENT" + CT0->CT0_ID
				M->AKW_TAMANH	:= TamSX3("AKD_ENT"+cIdEntAd)[1]
				M->AKW_ALIAS	:= CT0->CT0_ALIAS
				
                If CT0->CT0_ALIAS == "CV0" .And. M->AKW_F3 <> AllTrim(CT0->CT0_F3ENTI) + SubStr(CT0->CT0_ID,2)
					M->AKW_F3		:= AllTrim(CT0->CT0_F3ENTI) + SubStr(CT0->CT0_ID,2)
				Else
					M->AKW_F3		:= CT0->CT0_F3ENTI
				EndIf
				
				M->AKW_RELAC	:= CT0->CT0_ALIAS + "->" + CT0->CT0_CPOCHV
				M->AKW_DESCRE	:= CT0->CT0_ALIAS + "->" + CT0->CT0_CPODSC
				M->AKW_CNDSIN	:= ""
				M->AKW_OBRIGA	:= "2"

			EndIf

		OtherWise
			nPosConf := aRet[1]-nPadroes
			For nX := 1 To Len(aConfUsr[nPosConf,2])
				&("M->"+aConfUsr[nPosConf,2,nX,1]) := aConfUsr[nPosConf,2,nX,2]
			Next nX
	EndCase

	M->AKW_DESCRI	:= Padr(M->AKW_DESCRI,LEN(AKW->AKW_DESCRI))
	M->AKW_CHAVER 	:= Padr(M->AKW_CHAVER,LEN(AKW->AKW_CHAVER))
	M->AKW_ALIAS	:= Padr(M->AKW_ALIAS ,LEN(AKW->AKW_ALIAS ))
	M->AKW_F3		:= Padr(M->AKW_F3    ,LEN(AKW->AKW_F3    ))
	M->AKW_RELAC	:= Padr(M->AKW_RELAC ,LEN(AKW->AKW_RELAC ))
	M->AKW_DESCRE	:= Padr(M->AKW_DESCRE,LEN(AKW->AKW_DESCRE))
	M->AKW_ATUSIN	:= Padr(M->AKW_ATUSIN,LEN(AKW->AKW_ATUSIN))
	M->AKW_OBRIGA	:= Padr(M->AKW_OBRIGA,LEN(AKW->AKW_OBRIGA))
	M->AKW_CNDSIN	:= Padr(M->AKW_CNDSIN,LEN(AKW->AKW_CNDSIN))
	M->AKW_CODREL	:= Padr(M->AKW_CODREL,LEN(AKW->AKW_CODREL))

	If oGetAKW == NIL .Or. ValType(oGetAKW) != 'O'

		dbSelectArea("AKW")
		nRecAKW	:=	Recno()
		dbSetOrder(1)
		dbSeek(xFilial()+M->AKW_COD)
		While !Eof() .And. xFilial()+M->AKW_COD == AKW->AKW_FILIAL+AKW->AKW_COD .And. AKW_NIVEL < M->AKW_NIVEL
			cChaveR += AllTrim(AKW->AKW_CHAVER)+"+"
			cDescri += AllTrim(AKW->AKW_DESCRI)+"+"
			AKW->(dbSkip())
		End
		M->AKW_CONCDE := cDescri + M->AKW_DESCRI
		M->AKW_CONCCH := cChaveR + M->AKW_CHAVER
		MsGoTo(nRecAKW)

	Else

		nPosDescri := Ascan(oGetAKW:aHeader, {|x| Upper(AllTrim(x[2])) == "AKW_DESCRI" })
		nPosChaver := Ascan(oGetAKW:aHeader, {|x| Upper(AllTrim(x[2])) == "AKW_CHAVER" })
		For nX := 1 TO Len(oGetAKW:aCols)
			If nX < oGetAKW:nAT
				cChaveR += AllTrim(oGetAKW:aCols[nX, nPosChaver])+"+"
				cDescri += AllTrim(oGetAKW:aCols[nX, nPosDescri])+"+"
			Else
				Exit
			EndIf
		Next
		M->AKW_CONCDE := cDescri + M->AKW_DESCRI//oGetAKW:aCols[oGetAKW:nAT, nPosDescri]
		M->AKW_CONCCH := cChaveR + M->AKW_CHAVER//oGetAKW:aCols[oGetAKW:nAT, nPosChaver]
		//carrega acols da getdados
		For nX := 1 TO Len(oGetAKW:aHeader)

			If ! ( AllTrim(oGetAKW:aHeader[nX,2]) $ "AKW_COD|AKW_NIVEL" ) .And. ;
				Type("M->"+AllTrim(oGetAKW:aHeader[nX,2])) != "U" //quando variavel M-> nao foi inicializada
				oGetAKW:aCols[oGetAKW:nAT, nX] := &("M->"+AllTrim(oGetAKW:aHeader[nX,2]))
			EndIf

		Next

		oGetAKW:lNewLine := .F.

	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Tree  บAutor  ณPaulo Carnelossi    บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณNova interface com arvore a esquerda e painel html na parte บฑฑ
ฑฑบ          ณinferior                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Tree(aMenu)
Local oBar
Local oDlg
Local oPanel
Local oPan02
Local oFolder
Local oPan03
Local oTree
Local oBtnIncl, oBtnEsc, oBtnExibe, oBtnAlter, oBtnDeleta
Local nx, nY, nZ
Local aCubos
Local nOpca := 0

Local nTop := oMainWnd:nTop
Local nLeft := oMainWnd:nLeft
Local nBottom := oMainWnd:nBottom
Local nRight := oMainWnd:nRight
Local oMenu
Local oBtn

Private oGetAL1, oGetAKW
Private oPanExp, oPanInc, oPanInc1

Private lVazio := .F.

DEFAULT aMenu := {}

MENU oMenu POPUP
	MenuAddItem("--- Estrutura ---" ,,,.F.,{|| },"","", oMenu,)		 
	MenuAddItem(STR0004,,,.T.,{|| },"","BMPINCLUIR", oMenu,{||If(A190Struct(1, oTree, aCubos, lVazio), (nOpca:=2,oDlg:End()),NIL)},,,,,, ) //"Incluir"
	MenuAddItem(STR0005,,,.T.,{|| },"","NOTE"      , oMenu,{||If(A190Struct(2, oTree, aCubos, lVazio), (nOpca:=2,oDlg:End()),NIL)},,,,,, ) //"Alterar"
	MenuAddItem(STR0007,,,.T.,{|| },"","EXCLUIR"   , oMenu,{||If(A190Struct(3, oTree, aCubos, lVazio), (nOpca:=2,oDlg:End()),NIL)},,,,,, ) //"Excluir"
ENDMENU
oMenu:nClrPane := RGB(230,240,240)

DEFINE MSDIALOG oDlg TITLE STR0001 OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom+20,nRight  //"Manuten็ใo de Cubos Gerenciais"
oDlg:lMaximized := .T.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

For nx := 1 to Len(aMenu)
	oBtn := TBtnBmp():NewBar( aMenu[nx][3],aMenu[nx][3],,,aMenu[nx][1], aMenu[nx][2],.T.,oBar,,,aMenu[nx][1])
	oBtn:cTitle := aMenu[nx][4]
Next

oBtnIncl:= TBtnBmp():NewBar( "PCOCUBE","PCOCUBE",,,STR0004, {||oTree:TreeSeek("#"+StrZero(1,5)),If(A190Click(oTree), (nOpca:= 2, oDlg:End()), NIL)},.T.,oBar,,,STR0027) //"Incluir"###"Incluir Novo Cubo"
oBtnIncl:cTitle := STR0004 //"Incluir"

oBtnAlter:= TBtnBmp():NewBar( "EDIT","EDIT",,,STR0005, {||If(A190Altera(), (nOpca:= 2, oDlg:End()), NIL)},.T.,oBar,,,STR0028) //"Alterar"###"Alterar Cubo"
oBtnAlter:cTitle := STR0005 //"Alterar"

oBtnDeleta:= TBtnBmp():NewBar( "EXCLUIR","EXCLUIR",,,STR0007, {||If(A190Deleta(),(nOpca:= 2, oDlg:End()), NIL)},.T.,oBar,,,STR0029) //"Excluir"###"Excluir Cubo"
oBtnDeleta:cTitle := STR0007 //"Excluir"

oBtnExibe:= TBtnBmp():NewBar( "PROJETPMS","PROJETPMS",,,STR0031, {||nOpca:=3,oDlg:End()},.T.,oBar,,,STR0030) //"Exibicao"###"Modo de Exibicao"
oBtnExibe:cTitle := STR0031 //"Exibicao"

oBtnEsc := TBtnBmp():NewBar( "CANCEL","CANCEL",,,STR0032, {|| oDlg:End()},.T.,oBar,,,STR0032) //"Fechar"
oBtnEsc:cTitle := STR0032 //"Fechar"

oPanel := TPanel():New(14,182,'',oDlg, oDlg:oFont, .T., .T.,,RGB(240,240,240),600,125,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

oPan02 := TPanel():New(0,180,'',oPanel, oDlg:oFont, .T., .T.,,,203,10,.T.,.T. )
oPan02:Align := CONTROL_ALIGN_ALLCLIENT//RIGHT

oFolder:= TFolder():New(15,10,{STR0036,STR0006},{},oPan02,,,, .T., .T.,390,110) //"Cubos"###"Estrutura"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

oPanExp := TPanel():New(0,0,'',oFolder:aDialogs[2], oFolder:aDialogs[2]:oFont, .T., .T.,,,600,125,.T.,.T. )
oPanExp:Align := CONTROL_ALIGN_ALLCLIENT
	
@ 1,1 SAY oSay VAR '<B><font color="#0000aa"></font</B><B><font color="#0000aa">'+STR0033+'</font</B><B><font color="#0000aa"></font</B>' ;
		 OF oPanExp FONT oPanExp:oFont PIXEL SIZE 1000,2300 HTML //"Expandir e clicar no nivel abaixo para visualizar a estrutura do cubo"

oPan03 := TPanel():New(30,00,'',oDlg, oDlg:oFont, .T., .T.,,,140,140,.T.,.T. )
oPan03:Align := CONTROL_ALIGN_ALLCLIENT

oPanInc := TPanel():New(0,0,'',oFolder:aDialogs[1], oFolder:aDialogs[1]:oFont, .T., .T.,,,600,125,.T.,.T. )
oPanInc:Align := CONTROL_ALIGN_ALLCLIENT

@ 1,1 SAY oSay VAR '<B><font color="#0000aa"></font</B><B><font color="#0000aa">'+STR0034+'</font</B><B><font color="#0000aa"></font</B>' ;
		 OF oPanInc FONT oPanInc:oFont PIXEL SIZE 1000,2300 HTML //"Duplo clique para incluir novo cubo"

oPanInc1 := TPanel():New(0,0,'',oPan03, oFolder:aDialogs[2]:oFont, .T., .T.,,,600,125,.T.,.T. )
oPanInc1:Align := CONTROL_ALIGN_ALLCLIENT

@ 1,1 SAY oSay VAR '<B><font color="#0000aa"></font</B><B><font color="#0000aa">'+STR0034+'</font</B><B><font color="#0000aa"></font</B>' ;
  		 OF oPanInc1 FONT oPanInc1:oFont PIXEL SIZE 1000,2300 HTML //Duplo clique para incluir novo cubo

dbSelectArea("AL1")
RegToMemory("AL1",.F.)
oGetAL1:= MsMGet():New("AL1",AL1->(RecNo()),2,,,,,{0,0,290,252},,3,,,,oFolder:aDialogs[1],,,.T.)
oGetAL1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oGetAL1:Hide()

dbSelectArea("AKW")
RegToMemory("AKW",.F.)
oGetAKW:= MsMGet():New("AKW",AKW->(RecNo()),2,,,,,{0,0,290,252},,3,,,,oFolder:aDialogs[2],,,.T.)
oGetAKW:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oGetAKW:Hide()

dbSelectArea("AL1")

aCubos := A190Cubos()

DEFINE DBTREE oTree FROM 0,00 TO 300,190 OF oPanel CARGO ON RIGHT CLICK {|x,y,z|A190Right(oMenu, oTree, oDlg,x,y,z, aCubos, @nOpca)}
oTree:bLDblClick := {||If(A190Click(oTree), (nOpca:= 2, oDlg:End()), NIL)}
oTree:bChange := {||A190Change(aCubos, oTree, oPan02, oPan03, oFolder)}

DBADDTREE oTree PROMPT PadR(STR0037,60) RESOURCE "PCOCUBE" CARGO "#"+StrZero(1, 5) //" [+] Incluir Novo Cubo Gerencial"

DBENDTREE oTree

For nY := 1 TO Len(aCubos)

	DBADDTREE oTree PROMPT aCubos[nY][1] RESOURCE "PCOCUBE" CARGO aCubos[nY][4]
    
	For nZ := 1 TO Len(aCubos[nY][3])
		DBADDITEM oTree PROMPT aCubos[nY][3][nZ][1] RESOURCE "MDIVISIO" CARGO aCubos[nY][3][nZ][3]
    Next

    DBENDTREE oTree

End    	

oTree:TreeSeek("#"+StrZero(1,5))
oTree:Align := CONTROL_ALIGN_LEFT
oTree:nClrText := CLR_BLUE

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 2
	A190Tree(aMenu)
ElseIf nOpca == 3
	PCOA190(,A190Exibe(.T.))
EndIf
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Cubos บAutor  ณPaulo Carnelossi    บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna um array com os cubos existentes                    บฑฑ
ฑฑบ          ณEstrutura do array:                                         บฑฑ
ฑฑบ          ณ1-Codigo e descricao                                        บฑฑ
ฑฑบ          ณ2-Recno da Tabela AL1 (CUBOS)                               บฑฑ
ฑฑบ          ณ3-Array com as Dimensoes do cubo  (abaixo estrutura)        บฑฑ
ฑฑบ          ณ4-Id do cubo na arvore                                      บฑฑ
ฑฑบ          ณ-----Estrutura do array posicao 3---------------------------บฑฑ
ฑฑบ          ณ1-Nivel e Descricao                                         บฑฑ
ฑฑบ          ณ2-Recno da Tabela AKW (DIMENSOES DO CUBO)                   บฑฑ
ฑฑบ          ณ3-Id da Estrutura (dimensao) do cubo na arvore              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A190Cubos()
Local nX := 1
Local aCubos := {}
dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial("AL1"))

While AL1->(!Eof() .And. AL1_FILIAL==xFilial("AL1"))

	aAdd(aCubos, {PadR(Alltrim(AL1->AL1_CONFIG+"-"+AL1->AL1_DESCRI),60), AL1->(Recno()),{}, "#"+StrZero(++nX, 5)})

   	dbSelectArea("AKW")
    dbSetOrder(1)
   	dbSeek(xFilial("AKW")+AL1->AL1_CONFIG)
    While AKW->(!Eof() .And. AKW_FILIAL+AKW_COD==xFilial("AKW")+AL1->AL1_CONFIG)
		aAdd(aCubos[Len(aCubos)][3], {Alltrim(AKW->(AKW_NIVEL+"-"+AKW_CONCDE)),AKW->(Recno()), "#"+StrZero(++nX, 5)})
	    AKW->(dbSkip())
	End()

	dbSelectArea("AL1")
    AL1->(dbSkip())

End    	

Return aCubos


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Right บAutor  ณPaulo Carnelossi    บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณmonta menu para manutencao da estrutura do cubo             บฑฑ
ฑฑบ          ณtabela AKW                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A190Right(oMenu, oTree, oDlg, o, x, y, aCubos, nOpca)
Local aArea := GetArea()
Local aAreaTree := (oTree:cArqTree)->(GetArea())
Local nPos

dbSelectArea(oTree:cArqTree)
dbSetOrder(3)
dbSeek(oTree:CurrentNodeId)

If (oTree:cArqTree)->T_CARGO != "#"+StrZero(1,5)
	If (oTree:cArqTree)->T_ISTREE != "S"
		lVazio := .F.
		oMenu:aItems[3]:Enable()
		oMenu:aItems[4]:Enable()
		oMenu:Activate(Min(y,220),Min(x,100),oDlg)
		oMenu:FreeChildren()
	Else
		nPos := Ascan(aCubos, {|aVal|aVal[4] == (oTree:cArqTree)->T_CARGO})
		lVazio := .T.
		If ((oTree:cArqTree)->T_ISTREE == "S" .And. ;
			Empty(aCubos[nPos][3]))
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
			oMenu:Activate(Min(y,220),Min(x,100),oDlg)
			oMenu:FreeChildren()
		EndIf	
	EndIf	
EndIf

RestArea(aAreaTree)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Click บAutor  ณPaulo Carnelossi    บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao de cubo na tabela AL1 quando clicado no primeiro   บฑฑ
ฑฑบ          ณno da arvore ou qdo pressionado botao incluir               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Click(oTree)
Local aAreaTree := (oTree:cArqTree)->(GetArea())
Local lRet := .F.
dbSelectArea(oTree:cArqTree)
dbSetOrder(3)
dbSeek(oTree:CurrentNodeId)

If (oTree:cArqTree)->T_CARGO == "#"+StrZero(1,5)
	dbSelectArea("AL1")
	Inclui := .T.
	Altera := .F.
	If AxInclui("AL1",0,3,,,,,,) == 1
		lRet := .T.
	EndIf	
EndIf

RestArea(aAreaTree)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Altera บAutor  ณPaulo Carnelossi   บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlteracao do cubo (AL1)                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Altera()
Local lRet := .F.

dbSelectArea("AL1")
Inclui := .F.
Altera := .T.
If AxAltera("AL1",AL1->(RECNO()),4,,,,,,)==1
	lRet := .T.
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Deleta บAutor  ณPaulo Carnelossi   บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclusao do cubo (AL1)                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Deleta()
Local lRet := .F.

dbSelectArea("AL1")

Inclui := .F.
Altera := .F.

Pcoa190Brw("AL1",AL1->(RECNO()),6,,,@lRet) //sexta opcao do arotina == excluir

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190ChangeบAutor  ณPaulo Carnelossi    บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao dos paineis da enchoice e HTML na navegacao pelaบฑฑ
ฑฑบ          ณarvore                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Change(aCubos, oTree, oPanelDir, oPanelHtml, oFolder)
Local aAreaTree := (oTree:cArqTree)->(GetArea())

dbSelectArea(oTree:cArqTree)
dbSetOrder(3)
dbSeek(oTree:CurrentNodeId)

If (oTree:cArqTree)->T_ISTREE == "S"

	If (oTree:cArqTree)->T_CARGO == "#"+StrZero(1,5)
	
       oGetAL1:Hide()
       oGetAKW:Hide()
       oPanInc:Show()
       oPanInc1:Show()
	   oPanelHtml:Hide()

	Else

	    oPanInc:Hide()
        oPanInc1:Hide()
	    oGetAL1:Show()
		oFolder:aDialogs[2]:Hide()
        oGetAKW:Hide()
	    
		oPanelDir:Show()
		oPanelHtml:Show()
        A190Enchoice(aCubos, oFolder, (oTree:cArqTree)->T_CARGO)
		A190HTML(aCubos, oPanelHtml, (oTree:cArqTree)->T_CARGO)
	EndIf

Else

    oPanInc:Hide()
    oPanInc1:Hide()

	oPanelDir:Show()
	oFolder:aDialogs[2]:Show()
    oGetAKW:Show()
	oPanelHtml:Show()
    A190Enchoice(aCubos, oFolder, (oTree:cArqTree)->T_CARGO)
	A190HTML(aCubos, oPanelHtml, (oTree:cArqTree)->T_CARGO)
		
EndIf

RestArea(aAreaTree)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190HTML  บAutor  ณPaulo Carnelossi    บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem do Painel HTML com a estrutura do cubo (dimensao) บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190HTML(aCubos, oPanelHtml, cId)
Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local aInfo := {{STR0039, STR0040, STR0041, STR0042, STR0043}} //"Cubo"###"Nivel"###"Descricao"###"Descricao Composta"###"Expressao"
Local nPos, nY, nZ, nQ
Local cSay, oSay
Local oPanel
//primeiro procura nos pais
nPos := Ascan(aCubos, {|aVal|aVal[4] == cId})
//se nao achar, procura nos filhos
If nPos == 0
	For nY := 1 TO Len(aCubos)
		For nZ := 1 TO Len(aCubos[nY][3])
			If aCubos[nY][3][nZ][3] == cId
				nPos := nY
				Exit
			EndIf
		Next
		If nPos > 0 
			Exit
		EndIf
	Next		
EndIf

If nPos > 0 .And. Len(aCubos[nPos][3]) > 0
    For nY := 1 TO Len(aCubos[nPos][3])
    	dbSelectArea("AKW")
    	dbGoto(aCubos[nPos][3][nY][2])
    	aAdd(aInfo, {AKW->AKW_COD, AKW->AKW_NIVEL, AKW->AKW_DESCRI, AKW->AKW_CONCDE, AKW_CONCCH})
    Next	

	oPanel := TScrollBox():New( oPanelHTML, 0,0,230,338)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	cSay:='<B><font color="#0000aa"></font</B>'+CRLF
	cSay+='<B><font color="#0000aa">'+STR0035+'</font</B>'+CRLF //Estrutura do Cubo (Dimensoes)
	cSay+='<B><font color="#0000aa"></font</B>'+CRLF
	cSay+='<table cellpadding="2" cellspacing="2" border="0">'+CRLF 
	cSay+='<tr bgcolor="#0000aa">'
	
	For nZ := 1 TO Len(aInfo[1])
		cSay+='<th valign="top"><font color="#FFFFFF">'
		cSay+=aInfo[1][nZ]
		cSay+='</font>'
	Next
	cSay += CRLF
	For nZ := 2 TO Len(aInfo)	
	cSay+='<tr bgcolor="#F0F0F0">'
		For nQ := 1 TO Len(aInfo[nZ])
			cSay+='<td valign="center">'
			cSay+=aInfo[nZ][nQ]
		Next
		cSay += CRLF
	Next 
	cSay+='</table>'
	cSay += CRLF
	
	@ 1,1 SAY oSay VAR cSay OF oPanel FONT oPanel:oFont PIXEL SIZE 1000,2300 HTML 
	oSay:FreeChildren()

Else

	oPanel := TScrollBox():New( oPanelHTML, 0,0,230,338)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 1,1 SAY oSay VAR '<B><font color="#0000aa"></font</B><B><font color="#0000aa">'+STR0038+'</font</B><B><font color="#0000aa"></font</B>' OF oPanel FONT oPanel:oFont PIXEL SIZE 1000,2300 HTML //clique com botao direito para incluir nova estrutura
	oSay:FreeChildren()

EndIf

RestArea(aAreaAKW)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Enchoice บAutor  ณPaulo Carnelossi บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontagem das enchoices AL1 e AKW na navegacao pela arvore   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Enchoice(aCubos, oFolder, cId)
Local nPos, nY, nZ
Local oPanel, oSay

//primeiro procura nos pais
nPos := Ascan(aCubos, {|aVal|aVal[4] == cId})

//se nao achar, procura nos filhos
If nPos > 0

	dbSelectArea("AL1")
	dbGoto(aCubos[nPos][2])
	RegToMemory("AL1",.F.)
	oGetAL1:EnchRefreshAll()
	oGetAL1:Show()
	
	oPanExp:Show()


ElseIf nPos == 0

	oPanExp:Hide()
	
	For nY := 1 TO Len(aCubos)
		For nZ := 1 TO Len(aCubos[nY][3])
			If aCubos[nY][3][nZ][3] == cId
			    dbSelectArea("AKW")
			    dbGoto(aCubos[nY][3][nZ][2])
				RegToMemory("AKW",.F.)
				oGetAKW:EnchRefreshAll()
				oGetAKW:Show()
				nPos := nY
				dbSelectArea("AL1")
				dbGoto(aCubos[nPos][2])
				RegToMemory("AL1",.F.)
				oGetAL1:EnchRefreshAll()
				oGetAL1:Show()
				Exit
			EndIf
		Next
		If nPos > 0 
			Exit
		EndIf
	Next

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Struct บAutor  ณPaulo Carnelossi   บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManutencao da estrutura (dimensao) do cubo via menu         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Struct(nOpc, oTree, aCubos, lVazio)
Local lRet := .F.
Local nY, nZ
Local l190Inclui := .F.
Local l190Altera := .F.
Local l190Deleta := .F.

If nOpc == 1
	l190Inclui := .T.
	l190Altera := .F.
	l190Deleta := .F.
	Inclui := .T.
	Altera := .F.

ElseIf nOpc == 2
	l190Inclui := .F.
	l190Altera := .T.
	l190Deleta := .F.
	Inclui := .F.
	Altera := .T.

ElseIf nOpc == 3
	l190Inclui := .F.
	l190Altera := .F.
	l190Deleta := .T.
	Inclui := .F.
	Altera := .F.

EndIf

dbSelectArea(oTree:cArqTree)
dbSetOrder(3)
dbSeek(oTree:CurrentNodeId)

If !lVazio
	For nY := 1 TO Len(aCubos)
		For nZ := 1 TO Len(aCubos[nY][3])
			If aCubos[nY][3][nZ][3] == (oTree:cArqTree)->T_CARGO
				dbSelectArea("AL1")
				dbGoto(aCubos[nY][2])
				dbSelectArea("AKW")
				dbGoto(aCubos[nY][3][nZ][2])
				Exit
			EndIf
		Next
	Next	
Else
	nPos := Ascan(aCubos, {|aVal|aVal[4] == (oTree:cArqTree)->T_CARGO})
	dbSelectArea("AL1")
	dbGoto(aCubos[nPos][2])
EndIf

M->AL1_CONFIG := AL1->AL1_CONFIG

dbSelectArea("AKW")

If nOpc == 1
	lRet := (Pco190Inc("AKW",0,3)==1)
ElseIf nOpc == 2
	lRet := (Pco190Alt("AKW",AKW->(Recno()),4)==1)
ElseIf nOpc == 3
	lRet := Pco190Del("AKW",AKW->(Recno()),5)
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA190Exibe บAutor  ณPaulo Carnelossi    บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna tipo de exibicao - 1 = Classica                     บฑฑ
ฑฑบ          ณ                           2 = Arvore                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A190Exibe(lPerg)
Local aConfig := {1}
Local nTpExibe := Val(SuperGetMV("MV_PCOCUBO",.F.,"0"))

DEFAULT lPerg := .F.

If nTpExibe == 0 .Or. lPerg
	If !ParamBox( { {3,STR0030,nTpExibe,{STR0044,STR0045},40,,.F.}	},STR0031,aConfig)//"Modo Exibicao"###"Classica"###"Arvore"###"Exibicao"
		nTpExibe := 0
	Else
		nTpExibe := aConfig[1]
	EndIf
EndIf

Return(nTpExibe)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA190FK บAutor  ณ Gustavo Henrique   บ Data ณ  28/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Exclui as linhas das tabelas filhas relacionadas ao cubo   บฑฑ
ฑฑบ			 ณ selecionado para exclusao da tabela de cubos gerenciais.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cadastro de Cubos Gerenciais                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA190FK(cCube)

dbSelectArea("AKW")
dbSetOrder(1)
dbSeek(xFilial()+cCube)
While !Eof() .And. xFilial('AKW')+cCube == AKW_FILIAL+AKW_COD
	RecLock("AKW",.F.,.T.)
	dbDelete()
	MsUnlock()
	AKW->(dbSkip())
End
dbSelectArea("AKT")
dbSetOrder(1)
dbSeek(xFilial()+cCube)
While !Eof() .And. AKT->AKT_FILIAL==xFilial("AKT") .And. AKT->AKT_CONFIG==cCube
	Reclock("AKT",.F.,.T.)
	dbDelete()
	MsUnlock()
	AKT->(dbSkip())
End
dbSelectArea("AL3")
dbSetOrder(3)
dbSeek(xFilial()+cCube)
While !Eof() .And. AL3->AL3_FILIAL==xFilial("AL3") .And. AL3->AL3_CONFIG==cCube
	Reclock("AL3",.F.,.T.)            
	dbDelete()
	MsUnlock()
	AL3->(dbSkip())
End
dbSelectArea("AL4")
dbSetOrder(2)
dbSeek(xFilial()+cCube)
While !Eof() .And. AL4->AL4_FILIAL==xFilial("AL4") .And. AL4->AL4_CONFIG==cCube
	Reclock("AL4",.F.,.T.)
	dbDelete()
	MsUnlock()
	AL4->(dbSkip())
End

Return( .T. )

Function Pco190Vld(nOpcx,cConfig,cNivel)
Local aArea		:= GetArea()	
Local aAreaAL1	:= AL1->(GetArea())
Local aAreaAKW	:= AKW->(GetArea())

Local lRet := .T.

Local cChaveR	:= ""
Local cDescri	:= ""                               	

DEFAULT cNivel	:= M->AKW_NIVEL
DEFAULT cConfig:=  M->AKW_COD


dbSelectArea("AKW")
dbSetOrder(1)
dbSeek(xFilial()+cConfig)
While !Eof() .And. xFilial()+cConfig== AKW->AKW_FILIAL+AKW->AKW_COD
	If nOpcx == 3      //Inclusao
		cChaveR += "+"+AllTrim(AKW->AKW_CHAVER)
		cDescri += "+"+AllTrim(AKW->AKW_DESCRI)
    ElseIf nOpcx == 4  //alteracao
		If cNivel == AKW->AKW_NIVEL
			cChaveR += "+"+AllTrim(M->AKW_CHAVER)
			cDescri += "+"+AllTrim(M->AKW_DESCRI)
		Else
			cChaveR += "+"+AllTrim(AKW->AKW_CHAVER)
			cDescri += "+"+AllTrim(AKW->AKW_DESCRI)
		EndIf
	EndIf	
	AKW->(dbSkip())
End
cChaveR := Substr(cChaveR,2,Len(cChaveR))
cDescri := Substr(cDescri,2,Len(cDescri))

If nOpcx == 3      //Inclusao
	If (Len(cChaveR)+1+Len(Alltrim(M->AKW_CHAVER))) > Len(AL1->AL1_CHAVER) 
		Aviso(STR0046, STR0047, {"Ok"})//"Atencao"###"Cubo ja excedeu numero de niveis permitido. Verifique as dimensoes do cubo!"
		lRet := .F.
	EndIf	
ElseIf nOpcx == 4  //Alteracao
	If Len(cChaveR) > Len(AL1->AL1_CHAVER) 
		Aviso(STR0046, STR0048, {"Ok"})//"Atencao"###"Cubo excede o numero de niveis permitido. Verifique as dimensoes do cubo!"
		lRet := .F.
	EndIf	
EndIf

RestArea(aAreaAKW)
RestArea(aAreaAL1)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoa190Check บAutor  ณPaulo Carnelossi บ Data ณ  10/02/06   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o cubo esta com a dimensao tipo de saldo no     บฑฑ
ฑฑบ          ณultimo nivel ou de acordo com o parametro.                  บฑฑ
ฑฑบ          ณse necessario vai solicitar inclusao.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pcoa190Check()
Local aArea := GetArea()
Local aAreaAL1 := AL1->(GetArea())
Local aAreaAKW := AKW->(GetArea())
Local aStructCubo := {}
Local nX, nY
Local aAuxStruct, lTpSald
//ler parametro se considerar tipo de saldo como ultimo nivel do cubo gerencial
Local cUltNivel := SuperGetMV("MV_PCONVCB",.F.,"1")
//GETMV MV_PCONVCB  0 = nao verifica
//                  1 = Verifica se Tp Saldo esta no ultimo nivel
//                  2 = Verifica se esta na estrutura (pode ser em qq nivel)

If cUltNivel <> "0"

	lPcoa190 := .T.

	//todos os cubos
	dbSelectArea("AL1")
	dbSetOrder(1)
	dbSeek(xFilial("AL1"))
	While AL1->(! Eof() .And. AL1_FILIAL == xFilial("AL1"))
		aAdd(aStructCubo,{ AL1->AL1_CONFIG, {}, AL1->(Recno())} )
		AL1->(dbSkip())
	End

	dbSelectArea("AKW")
	dbSetOrder(1)
	//todas as dimensoes do cubo
	For nX := 1 TO Len(aStructCubo)
		If dbSeek(xFilial("AKW")+aStructCubo[nX, 1])
	       While AKW->(!Eof() .AND. AKW_FILIAL+AKW_COD == xFilial("AKW")+aStructCubo[nX, 1])
	       		aAdd(aStructCubo[nX, 2], { AKW->AKW_CHAVER, AKW->(Recno()) })
				AKW->(dbSkip())
	       End
		EndIf
	Next //nX
	
	If Len(aStructCubo) > 0
		//verificar se existe dimensao tipo de saldo no ultimo nivel 
		// GetMV MV_PCONVCB --->	1 = Verifica se Tp Saldo esta no ultimo nivel
		If cUltNivel == "1"
			//caso nao exista perguntar se usuario quer cadastra-lo 
			//qdo parametro igual tp saldo no ultimo nivel
			For nX := 1 TO Len(aStructCubo)
				aAuxStruct := aStructCubo[nX, 2]
			    If Len(aAuxStruct) == 0 .OR. Alltrim(aAuxStruct[Len(aAuxStruct),1]) != "AKD->AKD_TPSALD"
			    	If Aviso(STR0049+aStructCubo[nX, 1], STR0050+aStructCubo[nX, 1]+; //"Atencao - Cubo "###"O ultimo nivel do cubo gerencial "
							    	STR0051, {STR0004, STR0056}) == 1  //" deve ser Tipo de Saldo. Deseja inclui-lo ? "###"Incluir"###"Ignorar"
						PCOA190()
						Aviso(STR0046, STR0057, {"Ok"})  //"Atencao"###"Apos manutencao das estruturas dos cubos, estes devem ser reprocessados."
					EndIf	
			    EndIf
			Next //nX
		ElseIf cUltNivel == "2"
			//verificar se existe dimensao tipo de saldo em algum nivel 
			// GetMV MV_PCONVCB ---> 2 = Verifica se esta na estrutura (pode ser em qq nivel)
			For nX := 1 TO Len(aStructCubo)
				aAuxStruct := aStructCubo[nX, 2]
				lTpSald := .F.
				For nY := 1 TO Len(aAuxStruct)
				    If Alltrim(aAuxStruct[nY, 1]) == "AKD->AKD_TPSALD"
				    	lTpSald := .T.
				    	Exit
				    EndIf
				Next //nY
				
				If ! lTpSald
					If Aviso(STR0049+aStructCubo[nX, 1], STR0053+aStructCubo[nX, 1]+;  //"Atencao - Cubo "###"O cubo gerencial "
							    	STR0054, {STR0055,STR0056})==2  //" nao tem a dimensao Tipo de Saldo. "###"Continua" ###"Abandona"
						Exit
					EndIf		    	
			    EndIf
			Next //nX
		EndIf
    EndIf
EndIf

RestArea(aAreaAL1)
RestArea(aAreaAKW)
RestArea(aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ12/12/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;     //"Pesquisar"
							{ STR0003, 	"AxVisual" , 0 , 2},;     //"Visualizar"
							{ STR0004, 		"Pcoa190Brw" , 0 , 3},;	   //"Incluir"
							{ STR0005, 		"AxAltera" , 0 , 4},;  //"Alterar"
							{ STR0006,		"Pcoa190Brw" , 0 , 4},;  //"Estrutura"
							{ STR0007, 		"Pcoa190Brw" , 0 , 5}}  //"Excluir"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona botoes do usuario no Browse                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock( "PCOA1901" )
	//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
	//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
	//P_Eณ Parametros : Nenhum                                                    ณ
	//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
	//P_Eณ               Ex. :  User Function PCOA1901                            ณ
	//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
	//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aUsRotina := ExecBlock( "PCOA1901", .F., .F. )
Else
	aUsRotina := Nil
EndIf

If ValType(aUsRotina) == "A"
	AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
EndIf

Return(aRotina)
