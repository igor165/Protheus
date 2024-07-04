#INCLUDE "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TECA855.CH"

Static cAliasTFJ := ""
Static oGSTmpTb := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA855
    Após permissões validadas inicia as etapas necessárias para "construção" da tela
    @type  Function
    @author Natacha Romeiro
    @since 08/02/2022
/*/
//------------------------------------------------------------------------------
Function TECA855()
Local lContinua := .T.
Local cPerg     := "TEC855"
Local lCampos 	:= TecAprovOp()
Local lPergunte := TecHasPerg("MV_PAR01", cPerg)
Local lRet		:= At680Perm( Nil, __cUserId, "068" ) // Define regras de restrição
Local lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lGsAprov  := SuperGetMv("MV_GSAPROV",,"2") == "1"

If lRet 
    If !lOrcPrc
	    If lGsAprov
			If lCampos .and. lPergunte        
				If Pergunte(cPerg,.T.)
					While lContinua
						SetKey( VK_F12 ,{|| Pergunte("TEC855",.T.), At855Brow()}) 
						lContinua := At855Brow()	
					End						
				EndIf    		
			Else    
				Help( ' ', 1, 'TECA855', , STR0008, 1, 0 )	// '"Não foi possivel acessar a rotina, verifique se seu ambiente esta configurado corretamente."
			EndIf 
		else
			Help( ' ', 1, 'TECA855', ,STR0014, 1, 0 )// "A aprovação operacional está desligada neste ambiente. Habilite esta funcionalidade por meio do parâmetro MV_GSAPROV" 
		Endif		
	else
        At855vis() // Informativo na tela de aprovação operacional se o parametro MV_ORCPRC estiver como .T.													
	Endif		   
Else  
    Help( ' ', 1, 'TECA855', , STR0004, 1, 0 )	// 'Usuário sem permissão para acessar rotina
EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At855Brow
    Após permissões validadas inicia as etapas necessárias para "construção" da tela
    @type  Function
    @author Natacha Romeiro
    @since 08/02/2022
/*/
//------------------------------------------------------------------------------
Function At855Brow()

Local aSize     	:= FWGetDialogSize(oMainWnd)
Local oBrowse		:= FWMarkBrowse():New()
Local aAreaSX3		:= SX3->(GetArea())
Local aArea			:= GetArea()
Local nStepCmmIns	:= 900 //Quantidade do lote de regsitros a serem gravados na tabela temporária a cada INSERT do objeto GsTmpTable
Local nJ 			:= 1
Local nI 			:= 0
Local cMat			:= ""
Local cQuery 		:= ""
Local lOk 			:= .T.
Local lAuto			:= .F.
Local lContinua		:= .F.
Local aOrcs  		:= {}
Local aStruct		:= {}
Local aIdx			:= {}
Local aColumns    	:= {}
Local aSeek			:= {}
Local aInsertTmp	:= {}

At855Limp()
cAliasTFJ := GetNextAlias()	

oBrowse	:= FWMarkBrowse():New()

Aadd(aStruct, {"OK"         , "C", 1 , 0})
Aadd(aStruct, {"TFJ_CODIGO"	, "C", TamSX3("TFJ_CODIGO")[1]	, TamSX3("TFJ_CODIGO")[2]})
Aadd(aStruct, {"TFJ_CONTRT"	, "C", TamSX3("TFJ_CONTRT")[1]	, TamSX3("TFJ_CONTRT")[2]})
Aadd(aStruct, {"TFJ_CODENT"	, "C", TamSX3("TFJ_CODENT")[1]	, TamSX3("TFJ_CODENT")[2]})
Aadd(aStruct, {"TFJ_LOJA"	, "C", TamSX3("TFJ_LOJA")  [1]	, TamSX3("TFJ_LOJA"  )[2]})
Aadd(aStruct, {"A1_NOME"	, "C", TamSX3("A1_NOME")   [1]	, TamSX3("A1_NOME"   )[2]})
Aadd(aStruct, {"TFJ_DATA"	, "D", TamSX3("TFJ_DATA")  [1]	, TamSX3("TFJ_DATA"  )[2]})
Aadd(aStruct, {"TFJ_CONREV"	, "C", TamSX3("TFJ_CONREV")[1]	, TamSX3("TFJ_CONREV")[2]})
Aadd(aStruct, {"TFJ_FILIAL"	, "C", TamSX3("TFJ_FILIAL")[1]	, TamSX3("TFJ_FILIAL")[2]})
//Cria indices para a tabela temporária 	
Aadd(aIdx, {"I1",{ "TFJ_CODIGO" }})
Aadd(aIdx, {"I2",{ "TFJ_CONTRT" }})
Aadd(aIdx, {"I3",{ "TFJ_CODENT" }})
Aadd(aIdx, {"I4",{ "TFJ_LOJA"   }})
Aadd(aIdx, {"I5",{ "A1_NOME"    }})
Aadd(aIdx, {"I6",{ "TFJ_DATA"   }})
Aadd(aIdx, {"I7",{ "TFJ_CONREV" }})
Aadd(aIdx, {"I8",{ "TFJ_FILIAL" }})
//Cria array da busca de acordo com os indices da tabela temporária
aAdd(aSeek, {TxDadosCpo('TFJ_CODIGO')[1]	,{{'','C',TamSX3('TFJ_CODIGO')[1],TamSX3('TFJ_CODIGO')[2],TxDadosCpo('TFJ_CODIGO')[1],PesqPict('TFJ','TFJ_CODIGO'),NIL}},1,.T.})
aAdd(aSeek, {TxDadosCpo('TFJ_CONTRT')[1]	,{{'','C',TamSX3('TFJ_CONTRT')[1],TamSX3('TFJ_CONTRT')[2],TxDadosCpo('TFJ_CONTRT')[1],PesqPict('TFJ','TFJ_CONTRT'),NIL}},2,.T.})
aAdd(aSeek, {TxDadosCpo('TFJ_CODENT')[1]	,{{'','C',TamSX3('TFJ_CODENT')[1],TamSX3('TFJ_CODENT')[2],TxDadosCpo('TFJ_CONREV')[1],PesqPict('TFJ','TFJ_CONREV'),NIL}},3,.T.})
aAdd(aSeek, {TxDadosCpo('TFJ_LOJA'  )[1]  	,{{'','C',TamSX3('TFJ_LOJA')  [1],TamSX3('TFJ_LOJA')  [2],TxDadosCpo('TFJ_LOJA')  [1],PesqPict('TFJ','TFJ_LOJA')  ,NIL}},4,.T.})
aAdd(aSeek, {TxDadosCpo('A1_NOME'   )[1]    ,{{'','C',TamSX3('A1_NOME')   [1],TamSX3('A1_NOME')   [2],TxDadosCpo('A1_NOME')   [1],PesqPict('AA1','A1_NOME')   ,NIL}},5,.T.})
aAdd(aSeek, {TxDadosCpo('TFJ_DATA'  )[1]	,{{'','D',TamSX3('TFJ_DATA')  [1],TamSX3('TFJ_DATA')  [2],TxDadosCpo('TFJ_DATA')  [1],PesqPict('TFJ','TFJ_DATA')  ,NIL}},6,.T.})
aAdd(aSeek, {TxDadosCpo('TFJ_CONREV')[1]	,{{'','C',TamSX3('TFJ_CONREV')[1],TamSX3('TFJ_CONREV')[2],TxDadosCpo('TFJ_CONREV')[1],PesqPict('TFJ','TFJ_CONREV'),NIL}},7,.T.})
aAdd(aSeek, {TxDadosCpo('TFJ_FILIAL')[1]	,{{'','C',TamSX3('TFJ_FILIAL')[1],TamSX3('TFJ_FILIAL')[2],TxDadosCpo('TFJ_TIPREV')[1],PesqPict('TFJ','TFJ_TIPREV'),NIL}},8,.T.})

cQuery :=  At855Qry(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFJ,.T.,.T.)

oGSTmpTb  := GSTmpTable():New('TRBAPR',aStruct, aIdx, {}, nStepCmmIns )
cRetTab := 'TRBAPR'	

If !oGSTmpTb:CreateTMPTable()
	oGSTmpTb:ShowErro()
Else		
	//Preenche Tabela temporária com as informações do array
	While (cAliasTFJ)->(!Eof())
		aInsertTmp :={}

        Aadd(aInsertTmp, {'TFJ_CODIGO'	,(cAliasTFJ)->(TFJ_CODIGO)})
		Aadd(aInsertTmp, {'TFJ_CONTRT'	,(cAliasTFJ)->(TFJ_CONTRT)})
		Aadd(aInsertTmp, {'TFJ_CODENT'	,(cAliasTFJ)->(TFJ_CODENT)})
		Aadd(aInsertTmp, {'TFJ_LOJA'	,(cAliasTFJ)->(TFJ_LOJA)})
		Aadd(aInsertTmp, {'A1_NOME'	    ,(cAliasTFJ)->(A1_NOME)})
		Aadd(aInsertTmp, {'TFJ_DATA'	,SToD((cAliasTFJ)->(TFJ_DATA))}) 
		Aadd(aInsertTmp, {'TFJ_CONREV'	,(cAliasTFJ)->(TFJ_CONREV)})
		Aadd(aInsertTmp, {'TFJ_FILIAL'	,((cAliasTFJ)->(TFJ_FILIAL))})   
	
		If !Empty(aInsertTmp)			
			If oGSTmpTb:Insert(aInsertTmp)
				lOk := oGSTmpTb:Commit()
			Else
				lOk := .F.
				Exit
			EndIf
		EndIf
		(cAliasTFJ)->(DbSkip())	
	EndDo
		
	//MarkBrowse    
	For nI := 1 To Len(aStruct) 
	    If !(aStruct[nI][1] == "OK")
			aAdd( aColumns, FWBrwColumn():New() )
			If FWSX3Util():GetFieldType( aStruct[nI][1] ) == "D"
	        	aColumns[nJ]:SetData(&("{||" + aStruct[nI][1] + "}"))
	    	Else
		    	aColumns[nJ]:SetData( &("{||" + aStruct[nI][1] + "}"))
	    	EndIf			

	    	aColumns[nJ]:SetTitle(FWX3Titulo(aStruct[nI][1]))  // Titulo do campo
	    	aColumns[nJ]:SetSize(TamSX3(aStruct[nI][1])[1])    // Tamanho do campo
	    	aColumns[nJ]:SetDecimal(TamSX3(aStruct[nI][1])[2]) // Decimal
	    	aColumns[nJ]:SetPicture(X3Picture(aStruct[nI][1])) // Picture
			nJ++  
		EndIf
	Next nI
	
	RestArea(aAreaSX3)
	RestArea(aArea)
	
	If !Isblind()		
		DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[1],aSize[2] To aSize[3],aSize[4] PIXEL //"Painel de Aprovação"
			oBrowse:SetOwner(oDlg)
			oBrowse:DisableFilter()
			oBrowse:SetDescription(STR0001) //"Painel de Aprovação"
			oBrowse:SetTemporary(.T.)     	
			oBrowse:AddButton( STR0006,{||AT855ORC(((cRetTab)->TFJ_CODIGO)),/*oDlg:End()*/},,3,) // "Visualizar
			oBrowse:AddButton(STR0005,{|| lContinua := At855Msg(cRetTab, oBrowse) ,oDlg:End() },,3,) // "Aprovar"
			oBrowse:SetFieldMark("OK")
			oBrowse:SetAlias(cRetTab) //Seta o arquivo temporario para exibir a seleção dos dados
			oBrowse:SetSeek(.T., aSeek) 
			oBrowse:SetAllMark( { || oBrowse:AllMark() } )
			oBrowse:bMark := {||At855Mark(oBrowse,cRetTab,lAuto, cMat, @aOrcs)}	
			oBrowse:SetColumns(aColumns)
			oBrowse:DisableReport()
			oBrowse:SetMenuDef("")
			oBrowse:Activate()

			ACTIVATE MSDIALOG oDlg CENTERED	
	Endif	
Endif

Return lContinua 

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} At855Qry

Retorna os registros que deverão ser apresentados na tela
@author Natacha Romeiro
@since  08/02/2022

@param:
	    aFiliais    = MV_PAR01,
        cCliDe      = MV_PAR02
        cLojaDe     = MV_PAR03
        cCliAte     = MV_PAR04
        cLojaAte    = MV_PAR04 
        cOrcDe      = MV_PAR06
        cOrcAte     = MV_PAR07
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Static Function At855Qry(aFiliais, cCliDe, cLojaDe, cCliAte, cLojaAte, cOrcDe, cOrcAte)

Local cQuery	:= ""
Local cPerFil   := ""
Local cStatus   := '2'

MakeSqlExpr("TEC855")

cQuery += " SELECT DISTINCT "
cQuery += " '' BR_MARK ,"
cQuery += " TFJ.TFJ_CODIGO, TFJ.TFJ_CONTRT,TFJ_CODENT, TFJ.TFJ_LOJA, A1.A1_NOME, TFJ.TFJ_DATA, TFJ_CONREV, TFJ_FILIAL "
cQuery += " FROM " + RetSqlName('TFJ') + " TFJ "
cQuery += " INNER JOIN " + RetSqlName('SA1') + " A1 ON A1_COD = TFJ_CODENT "
cQuery += " AND A1_LOJA = TFJ_LOJA AND "
cQuery += " A1_FILIAL = '"+xfilial("SA1")+"' "
cQuery += " AND A1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TFJ.D_E_L_E_T_ = ' ' " 
cQuery += " AND TFJ.TFJ_APRVOP = '" +cStatus+ "' " 
If !Empty(MV_PAR01) 
    If "IN" $ MV_PAR01 .OR. "BETWEEN" $ MV_PAR01
    	cPerFil := RIGHT(MV_PAR01, LEN(MV_PAR01) - 1)
    	cPerFil := LEFT(cPerFil, LEN(cPerFil) - 1)
    
    	If AT('TFJ_FILIAL',MV_PAR01) > 0
    		cQuery += " AND " + cPerFil + " "
    	Else
    		cQuery += " AND TFJ.TFJ_FILIAL " + cPerFil + " "
    	EndIf
    Else
    	cQuery += " AND TFJ.TFJ_FILIAL = '" + MV_PAR01 + "' "
    EndIf
EndIf
cQuery += " AND TFJ.TFJ_CODENT BETWEEN '" +cCliDe+  "' AND '"+cCliAte+"'"
cQuery += " AND TFJ.TFJ_LOJA BETWEEN   '" +cLojaDe+ "' AND '"+cLojaAte+"'"
cQuery += " AND TFJ.TFJ_CODIGO BETWEEN '" +cOrcDe+  "' AND '"+cOrcAte+"'"

Return ChangeQuery(cQuery)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At855Mark

Função responsável por identificar os registros marcados na tela. 

@author Natacha Romeiro
@since  07/03/2022
/*/
//------------------------------------------------------------------------------
Function At855Mark(oBrowse,cRetTab,lAuto, cMat, aOrcs)

Local aArea		:= GetArea()
Local cMarca	:= ""
Default cMat	:= ""
Default lAuto	:= .F.

DbSelectArea(cRetTab)

cMarca := oBrowse:Mark()
While !(cRetTab)->(Eof()) 
	RecLock(cRetTab, .F.)
		
	If (cRetTab)->OK <> cMarca
		(cRetTab)->OK := ' '
	Else
		(cRetTab)->OK := cMarca
	EndIf
	MsUnlock()
	(cRetTab)->(DbSkip())
End

RestArea(aArea)

If !lAuto
	oBrowse:Refresh()
EndIf

Return 

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/{Protheus.doc} At855Msg
    Exibe msg durante o processamento da Aprovação dos registros 
    @type  Function
    @author Natacha Romeiro
    @since 09/02/2022
    @version 12
    @param aOrcs, Array, Array com os orçamentos a serem aprovados
    @example
    At855Aprov(aOrcs)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Static Function At855Msg(cRetTab, oBrowse)
    	
	MsgRun(STR0009, STR0010, {|| At855Aprov(cRetTab, oBrowse)}) //Processando aprovação dos registros" ## "Aguarde"
	
	oBrowse:Refresh()
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At855Aprov
	Realiza a aprovação dos orçamentos
    @type  Function
    @author Luiz Gabriel
	@since 		09/02/2022
	@author		Vitor kwon
/*/
//------------------------------------------------------------------------------
Function At855Aprov(cRetTab, oBrowse)

Local aAreaTFJ	:= TFJ->(GetArea())
Local nX        := 0
Local lRet      := .F.
Local aOrcs 	:= {}

DbSelectArea("TFJ")
DbSetOrder(1) //TFJ_FILIAL+TFJ_CODIGO

(cRetTab)->(DbGoTop())

While (cRetTab)->(!EOF())
	If oBrowse:IsMark()
		aadd(aOrcs, {(cRetTab)->TFJ_CODIGO,;
						(cRetTab)->TFJ_CONTRT,;
						(cRetTab)->TFJ_CONREV,;
						(cRetTab)->TFJ_FILIAL }) 							
	EndIf	
	(cRetTab)->( DbSkip() )
EndDo

For nX := 1 To Len(aOrcs)
    
   If TFJ->( MSSeek(aOrcs[nX][4] +aOrcs[nX][1] ) )
       RecLock('TFJ',.F.)
           TFJ->TFJ_APRVOP := "1" //Aprovado
           TFJ->TFJ_DTAPRO := Date()
           TFJ->TFJ_USAPRO := __cUserId
       TFJ->(MsUnlock())
       lRet      := .T.
   EndIf
Next nX 
RestArea(aAreaTFJ)

If lRet        
    MsgInfo(STR0011, "")  // 'Registros processados com sucesso!'
    aOrcs := {}
Else    
    MsgInfo(STR0012, "") // 'Falha no processamento!'
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT855ORC
	@description Abertura do orçamento de Serviços na rotina teca855 com o paramatro MV_ORCPRC desativado
	@since 		09/02/2022
	@author		Vitor kwon
/*/
//------------------------------------------------------------------------------
Function AT855ORC(cCodOrc)
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
    If lOrcPrc 
		Help(,,"AT855ORC",,STR0013 ,1,0)  // "Rotina disponivel apenas se o parãmetro MV_ORCPRC estiver desativado (.F.)"
	else
	    FwMsgRun(Nil,{|| At190dGrOrc(@cCodOrc)}, Nil, "") 
	Endif	
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At855Limp
    Limpa a tabela temporia como um "refresh"
    @type  Function
    @author Natacha Romeiro
    @since 22/03/2022
/*/
//------------------------------------------------------------------------------
Static Function At855Limp()

If !Empty(cAliasTFJ) 
	(cAliasTFJ)->(DbCloseArea())
EndIf

If oGSTmpTb != NIL
	oGSTmpTb:Close()
	TecDestroy(oGSTmpTb)
EndIf

Return 


//------------------------------------------------------------------------------
/*/{Protheus.doc} At855vis()

Informativo na tela de aprovação operacional se o parametro MV_ORCPRC estiver como .T.

@author Vitor kwon
@since 11/05/2022
/*/
//------------------------------------------------------------------------------
Function At855vis()

Local oDlg	 := Nil
Local cLink  := "https://tdn.totvs.com/pages/viewpage.action?pageId=667367910"
Local oMemo  := Nil

If !isBlind()
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0020) FROM 0,0 TO 200,1050 PIXEL //Atenção

	TSay():New( 010,010,{||OemToAnsi(STR0018 )},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"Prezado cliente,"
	TSay():New( 020,010,{||OemToAnsi(STR0019 )},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"Para utilizar esta rotina será necessario realizar algumas configurações que estao disponiveis no link abaixo:"
	@ 050,010 GET oMemo VAR cLink SIZE 273,010 PIXEL READONLY MEMO
	TButton():New(070,010, OemToAnsi(STR0015), oDlg,{|| ShellExecute(STR0016, cLink, "", "", 1) },030,011,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Abrir Link"#"Open"
	TButton():New(070,050, OemToAnsi(STR0017), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Sair"
                                                         
	ACTIVATE MSDIALOG oDlg CENTER
EndIf
Return ( .T. )
