#Include "Protheus.ch"         
#Include "LOJA907.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA907
Função de teste integracao Protheus e-commerce CiaShop cancelamento de Orçamento
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	28/01/2015
@obs     
@sample LOJA907
/*/
//-------------------------------------------------------------------
Function LOJA907(aParam)
local _lJob 	:= .F. //Execução em Job
Local _cEmp 	:= nil //Empresa
Local _cFil 	:= nil //Filial
Local cFunction := "LOJA907" //Rotina
Local lLock 	:= .F. //Bloqueado   
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local cName := "" //Chave de travamento

If Valtype(aParam) != "A" 
	_cEmp := cEmpAnt
	_cFil := cFilant
	
	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf
Else

	_lJob :=  .T.
	_cEmp := aParam[1]
	_cFil := aParam[2]
EndIf



If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf

//Gera SEMAFORO - para não dar erro de execução simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt

lLock := oLJCLocker:GetLock( cName )


If lLock
	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]"+ IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - EM: "
	
	Lj907Pr(_lJob, lCallStack)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] ,STR0003 ) + STR0004 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If IsBlind()
		Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
	Else
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0003) )
	EndIf
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj907Pr
Função Processamento da integracao Protheus e-commerce
@param   	lAJob - Execução via Schedule - Default .f.
@author  Varejo
@version 	P11.8
@since   	28/01/2015
@obs     
@sample Lj907(lAJob)
/*/
//-------------------------------------------------------------------
Function Lj907Pr(lJob, lCallStack)
             
Local lOk           := .T.      //Retorna falso caso ocorra algum erro na execucao. 

Local cQuery        := ""            //Query para obter os titulos vencidos
Local dDtVenc		:= Date()        //Data limite do Orcamento
Local nTamPref		:= 0 			//Tamanho do Prefixo do Título
Local nTamNum		:= 0			//Tamanho do número do título
Local nDias			:= SuperGetMv("MV_LJECOMW",.T., 30)			//Numero de dias 
Local cC5_Status	:= "" 			//Status do pedido EC         
Local cSeq			:= "" 			//Sequencia de Execução da Rotina     
Local cRetorno		:= "" 			//Retorno da rotina 
Local lErro	   		:= .F. 			//Erro de Execução da rotina      
Local dDataIni      := Date() 		//Data Inicial de execução da rotina
Local cHoraIni		:= Time()  		//Hora Inicial de execução da rotina  
Local cErro			:= "" 			//Detalhe do erro
Local cOldUsr		:= __cUserID  	//Usuario ativo
Local cOldName		:= cUserName       //Nome do usuário ativo  
Local lNoDel		:= .F.   		//Não deletado o registro
Local lFicBk		:= lFiscal 		//Backup Variável lFiscal
Local cNumCaixa		:= ""			//codigo do Caixa
Local aAreaSX5		:= SX5->(GetArea()) //WorkArea SX5
Local aAreaSA6		:= SA6->(GetArea()) //WorkArea SA6
Local aAreaSLF		:= SLF->(GetArea()) //WorkArea SLf

Default lJob := .F.
Default lCallStack := .F.
               
Private lMsErroAuto    := .F.        //Variavel de controle caso ocorra erro no execauto.
Private lFTStartSilenc := .T.        //varivel para nao apresentar mensagem de erro em tela


__cUserID      := SuperGetMV("MV_LJECOMU",,"000001")    //UserID do Usuario do eCommerce.
cUserName      := SuperGetMV("MV_LJECOMN",,"ECOMMERCE") //Nome do Usuario do eCommerce.

SetFunName("LOJA140") 


//Posiciona no perfil do caixa

cNumCaixa := xNumCaixa() //Posiciona SA6
If SX5->(DbSeek(xFilial("SX5")+'23'+ cNumCaixa ) )	
	SLF->(DbSetOrder(1))
	SLF->(DbSeek(xFilial("SLF")+SA6->A6_COD))
EndIf


lFicBk := lFiscal
lFiscal := .F.


If nDias == 0
	nDias := 30
EndIf

//Resultado da sincronização
cSeq := GETSXENUM("MGM","MGM_SEQ")
CONFIRMSX8()

nTamPref		:= SE1->(TamSx3("E1_PREFIXO"))[1] 
nTamNum		:= SE1->(TamSx3("E1_NUM"))[1]


cQuery := " SELECT SL1.R_E_C_N_O_ SL1RECNO, SC5.R_E_C_N_O_ SC5RECNO, SL1.L1_FORMPG, SL1.L1_FILIAL, SL1.L1_NUM "
cQuery += " FROM " + RetSQLName("SL1") + " SL1, " + RetSQLName("SC5") + " SC5 "
cQuery += " WHERE SL1.L1_DTLIM   >= " + ValToSQL(Date()-nDias)
cQuery += " AND   SL1.L1_DTLIM   <  " + ValToSQL(Date())         
cQuery += " AND   SL1.L1_SERIE =   ' ' "		
cQuery += " AND   SL1.L1_DOC  =   ' ' "       
cQuery += " AND   SL1.L1_FORMPG    =  'FI' "        

If SL1->(FieldPos("L1_ECFLAG") > 0)
	cQuery += " AND   SL1.L1_ECFLAG    =  '1' "
EndIf
 
If SC5->(FieldPos("C5_STATUS") > 0) 
	cQuery += " AND  C5_STATUS IN ( '00','05')   "
EndIf   
 
If SC5->(FieldPos("C5_PEDECOM") > 0)
	cQuery += " AND  C5_PEDECOM <> ' '  "
EndIf   		

cQuery += " AND   SL1.L1_PEDRES = SC5.C5_NUM   "
cQuery += " AND   SC5.D_E_L_E_T_ =  ' ' "
CQuery += " AND   SC5.C5_FILIAL = '" + xFilial("SC5") + "'"

cQuery += " AND   SL1.L1_FILIAL = '" + xFilial("SL1") + "'"
cQuery += " AND   SL1.D_E_L_E_T_ =  '' "

If  (Select("TMPSL1") > 0)
	TMPSL1->( DbCloseArea() )
EndIf	

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Obtem os dados executando a query.                                        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbUseArea(.T., "TOPCONN", TcGenQry(Nil, Nil, cQuery), "TMPSL1", .F., .T.)

TcSetField( "TMPSL1", "SL1RECNO", "N", 10, 0 )
TcSetField( "TMPSL1", "SC5RECNO", "N", 10, 0 )

If lCallStack .AND. FindFunction("Lj900XRC")
	 Lj900XRC( "TMPSL1", "LOJA907")
EndIf

While !( Eof() )

	SL1->(DbGoTo( TMPSL1->SL1RECNO ))  //Posiciona SL1 pelo resultado da Query
	SC5->(DbGoTo( TMPSL1->SC5RECNO ))  //Posiciona SL1 pelo resultado da Query
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa os títulos de pagamentos realizados com Boleto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Verifica se a data do orcamento nao pago e maior que a data de vencimento +1
	dDtVenc	:= SL1->L1_DTLIM
	
	If  Alltrim(Str(DOW(dDtVenc))) $ '1|6|7'
		
		While (Alltrim(Str(DOW(dDtVenc))) $ '1|6|7')
			dDtVenc	+= 1
		End
		
	EndIF
	
	If  (dDtVenc >= Date())
		DbSelectArea("TMPSL1")
		DbSkip()
		Loop
	EndIf	
	
 	cC5_Status := ""
        
  	If SC5->(FieldPos("C5_STATUS")) > 0
    	cC5_Status := SC5->C5_STATUS
    EndIf
  
    cErro := ""
    //Realiza o cancelamento do Orçamento e dos títulos
    lNoDel			:= .F. 
    If !Lj907OrEx(.T., SL1->L1_FILIAL, SL1->L1_NUM, @cErro, @lNoDel)
    	//seta erro
    	SC5->(DbGoTo( TMPSL1->SC5RECNO ))
    	If !SC5->(Deleted())
			RecLock("SC5", .F.)
			SC5->C5_STATUS := cC5_Status
			SC5->(MsUnLock())		    		
    	EndIf 
    	lErro := .T.
    	
    	If !lNoDel
    		cRetorno := cRetorno + CRLF + STR0007 + STR0008 + SL1->L1_FILIAL + SL1->L1_NUM   + STR0009 + SC5->C5_FILIAL + SC5->C5_NUM + IIF(!Empty(cErro), CRLF + cErro, "")  // "<<ERRO>> " ##"Orçamento: "#" Pedido: "  
    	Else
    		cRetorno := cRetorno + CRLF + STR0008 + SL1->L1_FILIAL + SL1->L1_NUM   + STR0009 + SC5->C5_FILIAL + SC5->C5_NUM + IIF(!Empty(cErro), CRLF + cErro, "")  // ##"Orçamento: "#" Pedido: "   		
    	EndIf
    Else 
    	//gera o log com sucesso
    	cRetorno := cRetorno + CRLF + STR0008 + SL1->L1_FILIAL + SL1->L1_NUM   + STR0009  + SC5->C5_FILIAL + SC5->C5_NUM   + STR0010 + IIF(!Empty(cErro), CRLF + cErro, "") //"Orçamento: "#" Pedido: " #" cancelado " 
    EndIf    

	DbSelectArea("TMPSL1")
	DbSkip()
	
End

TMPSL1->( DbCloseArea() )

MGM->(RECLOCK("MGM", .T.))
MGM->MGM_FILIAL  := xFilial("MGM")
MGM->MGM_SERVIC := "LOJA907"
MGM->MGM_SEQ     := cSeq
MGM->MGM_DATA    := dDataIni
MGM->MGM_HORAIN  := cHoraIni

MGM->MGM_XMLRET  := cRetorno 

MGM->MGM_HORAFI := Time()
if !lErro
	MGM->MGM_RESULT := "1"
Else
	MGM->MGM_RESULT  := "2"
endif
MGM->(msUnLock())

__cUserID      := cOldUsr
cUserName      := cOldName
lFiscal := lFicBk

//Restaura WorkAreas Abertas - Perfil de caixa
RestArea(aAreaSLF)
RestArea(aAreaSX5	)
RestArea(aAreaSA6)	


Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj907OrEx
Função de teste integracao Protheus e-commerce LOJA907
@param   lPosSL1 - Localização do SL1
@param   cFilSL1 - Filial do SL1
@param 	cSL1Num - Numero do Orçamento
@param	cErro - Mensagem de Erro retornada
@return	lRet - .t. - Sucesso na exclusão/falha na exclusão
@author  Varejo
@version 	P11.8
@since   	28/01/2015
@obs     
@sample Lj907OrEx(lPosSL1, cFilSL1, cSL1Num, cErro)
/*/
//-------------------------------------------------------------------
Function Lj907OrEx(lPosSL1, cFilSL1, cSL1Num, cErro, lNoDel)
Local lFound 	:= .T.  //Localizado orçamento
Local lRet 		:= .T.  //Retorno da rotina
Local aArea 	:= GetArea() //workArea Ativa
Local aAreaSL1 	:= {}	//WorkArea SL1
Local nRecSL1	:= 0  	//Registro SL1 
Local uRet	:= NIl //Retorno da Função de exclusão de orçamento  
Local cNumOrc := ""
Local cFilOrc := "" 

Default  lPosSL1 := .F.
Default cFilSL1 := ""
Default cSL1Num := ""   
Default cErro := ""
Default lNoDel := .F.

If lPosSL1
	SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
	lFound := SL1->(DbSeek(cFilSL1+cSL1NUM))
EndIf

If lFound 

	If !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_SERIE)
		lRet := .f.
		cErro := "LOJA907: Lj907OrEx: " + STR0011 + SL1->L1_NUM + STR0012  //"Problema encontrado na exclusão do Orçamento! Orçamento: "##"Nota Fiscal Emitida" 
	 	Lj900XLg(cErro)     	
	EndIf
			
Else
	lRet := .F.
EndIf 

If  lRet
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cancela Orcamento e exclui o pedido de venda e reservas de estoque.            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aAreaSL1 := SL1->(GetArea())      
    
    nRecSL1 := SL1->(Recno())
    cNumOrc := SL1->L1_NUM
	cFilOrc := SL1->L1_FILIAL
	uRet := lj140Exc("SL1", SL1->(Recno()), 5,,.T., SL1->L1_FILIAL, SL1->L1_NUM)
    If  (  ValType(uRet) <> "N" .OR. uRet != 1 )     
    	cErro := "LOJA907: Lj907OrEx: " + STR0013  //"Orçamento não pode ser excluído "
    	Lj900XLg(cErro)      	   
    	lRet := .F.
    	lNoDel := .T.
    Else
    	//Busca o SL1
 		SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
		lFound := SL1->(DbSeek(cFilOrc+cNumOrc))
		If lFound .AND. !SL1->(Deleted())
	    	cErro := "LOJA907: Lj907OrEx: " + STR0011  + SL1->L1_NUM  + STR0014 //" Orçamento não excluído (SL1)"
    		Lj900XLg(cErro)      	   
    		lRet := .F.		
		EndIf    	
    EndIf
    
 	lMsErroAuto := .F.

	RestArea(aAreaSL1) //Volta a posicao original

EndIf

RestArea(aArea)      

Return lRet         

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ907CnO
Função de exclusão do Pedido e-commerce
@param   cPedEcom - Codigo do Pedido e-commerce
@return	lRet - .t. - Sucesso na exclusão/falha na exclusão
@author  Varejo
@version 	P11.8
@since   	28/01/2015
@obs     
@sample LJ907CnO(cPedEcom)
/*/
//-------------------------------------------------------------------
Function LJ907CnO(cPedEcom)
Local lRet 		:= .F. //Retorno da rotina
Local cC5_NUM 	:= "" //Numero do Pedido 
Local lBusPed 	:= FindFunction( "lj901ABPed")  //Localiza o Pedido
Local cL1_NUM 	:= "" //Numero do Orçamento
Local cC5_PEDECO := "" //Numero do Pedido e-commerce

Default cPedEcom := ""               

If lBusPed
	lj901ABPed(cPedEcom, @cC5_NUM,  ,  , @cC5_PEDECO)  
EndIf

If !Empty(cC5_NUM)
	//Busca o Orçamento relacionado ao pedido
	cL1_NUM := 	lj907BOPed(cC5_NUM, cC5_PEDECO) 
	If !Empty(cL1_NUM)
		lRet := Lj907OrEx(.t., xFilial("SL1"), cL1_NUM)		
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ907CnO
Função de Busca do Orçamento Associado ao Pedido
@param  cC5_NUM - Codigo do Pedido 
@return	cL1_NUM - Numero do Orcamento
@author  Varejo
@version 	P11.8
@since   	28/01/2015
@obs     
@sample LJ907CnO(cPedEcom)
/*/
//-------------------------------------------------------------------
Static Function lj907BOPed(cC5_NUM, cC5_PEDECO) 
Local cL1_NUM 	:= "" //Numero do Orçamento
Local cSql 		:= "" //Query                            
Local cFilSC5 	:= xFilial("SC5") //Filial do Pedido
Local cFilSL1 	:= xFilial("SL1") //Filial do Orçamento
Local cAlias 	:= GetNextAlias() //Alias da Consulta
   
Default cC5_NUM := ""
Default cC5_PEDECO := ""
	
cSQL := " SELECT L1_NUM "
cSQL += " FROM " + RetSqlName("SL1") + " SL1 "
cSQL += " WHERE L1_FILIAL = '" + cFilSL1 + "' "
cSQL += " AND L1_PEDRES = '" + cC5_NUM + "' "  
If !Empty(cC5_PEDECO) 
	cSQL += " AND L1_ECPEDEC = '" + cC5_PEDECO + "' "   
EndIf

cSQL += " AND D_E_L_E_T_ <> '*' "

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSQL),cAlias, .F., .T.)

(cAlias)->(DBGoTop())

If  !(cAlias)->(Eof())  	
	cL1_NUM :=  (cAlias)->L1_NUM
EndIf


(cAlias)->(DBCloseArea())
	
Return cL1_NUM          

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA907
Função de teste integracao Protheus e-commerce CiaShop cancelamento de Orçamento
@author  Varejo
@version 	P11.8
@since   	28/01/2015
@sample LOJA901A
/*/
//-------------------------------------------------------------------

User Function ECOM014 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja907(aParam)
	
REturn
