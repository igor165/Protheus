#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA193.CH"
#INCLUDE "fwschedule.ch"

Static __lCTB193 		:= Nil
Static __lCusto		:= .F.
Static __lItem		:= .F.
Static __lCLVL		:= .F.
Static __cCTB193		:= ""
Static __nQtdEntid	:= Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA193
Processamento de saldo em Fila


@author  Alvaro Camillo Neto
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Function CTBA193() 

Local cThread		:= cValToChar(ThreadID())

Local aArea		:= GetArea()
Local aResult 	:= {}
Local cLock		:= ""

dbSelectArea("CT2")
dbSelectArea("CQA")
 
If __lCTB193 == Nil
	__cCTB193		:= GetSPName("CTB193","23")
	__lCTB193		:= ExistProc(__cCTB193,VerIDProc())
	__lCusto		:= CtbMovSaldo("CTT")
	__lItem		:= CtbMovSaldo("CTD")
	__lCLVL		:= CtbMovSaldo("CTH")
EndIf


cLock := 'CTBFILA'+xFilial("CT2")
If LockByName(cLock,.F.,.F.)  
	Conout("--- "+STR0002+" "+ dToc(Date())+" " + Time() + " ThreadID [" + cThread +"] ---")//"Inicio Processamento Saldo em Fila"
	If __lCTB193
		//Procedure
		aResult := TCSPEXEC( xProcedures(__cCTB193), cFilAnt ,	Iif(__lCusto,'1','0'),Iif(__lItem,'1','0'),Iif(__lCLVL,'1','0') ) 
	
		If Empty(aResult) .or. aResult[1] = "0"
			Conout("------ " + STR0001 +"--------")//"Erro na chamada da procedure - Saldos Contábeis em Fila" 
		EndIf
	Else
		//Processamento ADVPL
		CT93ADV()
	EndIf
	UnLockByName(cLock,.F.,.F.)
	Conout("--- "+STR0003 +" "+ dToc(Date())+" " + Time() + " ThreadID [" + cThread +"] ---")//"Final Processamento Saldo em Fila"

EndIf

RestArea(aArea)

//Limpeza de Array
aSize(aArea,0)
aSize(aResult,0)

aArea 		:= Nil
aResult	:= Nil

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} CT93ADV
Processamento de saldo em Fila via ADVPL - Sem Procedure


@author  Alvaro Camillo Neto
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------

Static Function CT93ADV()
Local cQuery		:= ""
Local cTabTmp		:= GetNextAlias()
Local nRecCt2		:= 0
Local nRecCQA		:= 0
Local cContaDeb	:= ""
Local cContaCrd	:= ""
Local cCustoDeb	:= ""
Local cCustoCrd	:= ""
Local cItemDeb	:= ""
Local cItemCrd	:= ""
Local cClassDeb	:= ""
Local cClassCrd	:= ""
Local cTipo		:= ""
Local dData		:= CTOD("")
Local cMoeda		:= ""
Local nValor		:= 0
Local cTpSald		:= 0
Local dDataLP		:= CTOD("")		
Local cFilMov		:= ""
Local lCtbIsCube  := CtbIsCube()
Local aEntid		:= {}
Local nEntid		:= 0

dbSelectArea("CT2")
dbSelectArea("CQA")

If __nQtdEntid == NIL
	__nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf	

cQuery += " SELECT R_E_C_N_O_ RECCQA, CQA_FILCT2,CQA_DATA,CQA_LOTE,CQA_SBLOTE,CQA_DOC,CQA_LINHA,CQA_EMPORI,CQA_FILORI,CQA_MOEDLC,CQA_TPSALD " +CRLF 
cQuery += " FROM  " +CRLF 
cQuery += " 	"+RetSQLName("CQA")+" CQA " +CRLF 
cQuery += " WHERE " +CRLF 
cQuery += " 	CQA_FILIAL = '"+xFilial("CQA")+"' AND " +CRLF 
cQuery += " 	CQA_FILCT2 = '"+xFilial("CT2")+"' AND " +CRLF 
cQuery += " 	D_E_L_E_T_ = '' " +CRLF 
cQuery += " 	ORDER BY  CQA_DATA,CQA_LOTE,CQA_SBLOTE,CQA_DOC,CQA_LINHA " +CRLF 

cQuery := ChangeQuery(cQuery)

If ( Select ( cTabTmp) <> 0 )
	dbSelectArea ( cTabTmp )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTmp,.T.,.F.)
TCSetField(cTabTmp,"CQA_DATA","D",08,0)
TCSetField(cTabTmp,"RECCQA","N",10,0)

CT2->(DbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC 

While (cTabTmp)->(!EOF())
	nRecCQA := (cTabTmp)->RECCQA

	cFilCT2 	:= (cTabTmp)->CQA_FILCT2
	dData	 	:= (cTabTmp)->CQA_DATA
	cLote 		:= (cTabTmp)->CQA_LOTE
	cSubLote	:= (cTabTmp)->CQA_SBLOTE
	cDoc		:= (cTabTmp)->CQA_DOC
	cLinha		:= (cTabTmp)->CQA_LINHA
	cEmpOri	:= (cTabTmp)->CQA_EMPORI
	cFilOri	:= (cTabTmp)->CQA_FILORI
	cMoeda		:= (cTabTmp)->CQA_MOEDLC
	cTpSald	:= (cTabTmp)->CQA_TPSALD	
	
	If CT2->(dbSeek( cFilCT2 + DTOS(dData) + cLote + cSubLote + cDoc + cLinha + cTpSald + cEmpOri + cFilOri + cMoeda ))
		cTipo		:= CT2->CT2_DC	
		cContaDeb	:= CT2->CT2_DEBITO	
		cContaCrd	:= CT2->CT2_CREDIT	
		nValor		:= CT2->CT2_VALOR	
		cCustoDeb	:= CT2->CT2_CCD	
		cCustoCrd	:= CT2->CT2_CCC	
		cItemDeb	:= CT2->CT2_ITEMD	
		cItemCrd	:= CT2->CT2_ITEMC	
		cClassDeb	:= CT2->CT2_CLVLDB	
		cClassCrd	:= CT2->CT2_CLVLCR		
		dDataLP	:= CT2->CT2_DTLP
		cFilMov	:= CT2->CT2_FILORI
		
		GRAVACQ("CT1",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		
		If !Empty(cCustoDeb) .Or. !Empty(cCustoCrd)
			GRAVACQ("CTT",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		EndIf 
	
		If !Empty(cItemDeb) .Or. !Empty(cItemCrd)
			GRAVACQ("CTD",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		EndIf 
		
		If !Empty(cClassDeb) .Or. !Empty(cClassCrd)
			GRAVACQ("CTH",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		EndIf
		
		If __nQtdEntid > 4
			For nEntid := 1 TO ( __nQtdEntid - 4 ) // quatro entidades sai padrao Conta/Centro Custo/Item Contabil/Classe de Valor
				cCampoDeb 		:= "CT2_EC"+StrZero(nEntid+4,2)+"DB"
				cCampoCred		:= "CT2_EC"+StrZero(nEntid+4,2)+"CR"
				If CT2->(FieldPos(cCampoDeb)) > 0 .And. CT2->(FieldPos(cCampoCred)) > 0
					aAdd(aEntid, { CT2->&(cCampoDeb), CT2->&(cCampoCred)} )
				EndIf
			Next
		EndIf
		
		If lCtbIsCube .And. Len(aEntid) > 0
			CtbGravCub( nValor, cTipo, cTpSald, cMoeda, dData, cContaDeb, cContaCrd, cCustoDeb, cCustoCrd, cItemDeb, cItemCrd, cClassDeb, cClassCrd, aEntid)
		EndIf

		CQA->(dbGoTo(nRecCQA))
		RecLock("CQA",.F.)
			CQA->(dbDelete())	
		MsUnLock() 
	EndIf
	
	(cTabTmp)->(dbSkip())
EndDo

dbSelectArea ( cTabTmp )
dbCloseArea ()

aSize( aEntid , 0 )
aEntid := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  Alvaro Camillo Neto
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            ,;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam

//-------------------------------------------------------------------
/*{Protheus.doc} VerIDProc
Identifica a seqUencia de controle do fonte ADVPL com a     
stored procedure, qualquer alteracao que envolva diretamente
a stored procedure a variavel sera incrementada.            
Procedure CTB001                                            

@author Marcelo Pimentel 

                         
@version P12
@since   24.07.2007
@return  IdProc
@obs	 
*/
//-------------------------------------------------------------------   
         
Static Function VerIDProc()
Return '010'