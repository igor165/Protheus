#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA915.ch'

/*/{Protheus.doc} FINA915B
Função processamento dos registros da tabela FJP e baixa dos titulos enviado 
pela caixa economica federal referente aos recebimentos
do projeto Minha Casa Minha Vida. 

@author Totvs
@since 16/01/2015	
@version 11.80
/*/


Function FINA915B()
Local cPerg	:="FINA915"


If !Pergunte(cPerg,.T.)
    Return
EndIf

//SaveInter() // Salva variaveis publicas 

F915Seltit()

//RestInter() // Salva variaveis publicas

Pergunte(cPerg,.F.)
If MV_PAR07 == 1

	FINR915()

Endif


Return


/*/{Protheus.doc} F915Seltit
Função para seleção de titulos 

@author Totvs
@since 16/01/2015	
@version 11.80
/*/

Function F915Seltit()

Local cQuery 		:= ""
Local cChave		:= ""
Local lRet			:= .T.
Local cAliasMCMV	:= GetNextAlias()    
Local cBanco 		:= MV_PAR08
Local cAgencia		:= MV_PAR09
Local cConta		:= MV_PAR10

	cQuery:= "SELECT FJP.R_E_C_N_O_ FJPRECNO , SE1.R_E_C_N_O_ SE1RECNO"
	
	cQuery+= " FROM " + RetSqlName("FJP") + " FJP"
	cQuery+= " JOIN " + RetSqlName("SE1") + " SE1"
	cQuery+= " ON (FJP.FJP_CONTR=SE1.E1_CTRBCO AND FJP.FJP_FILIAL=SE1.E1_FILIAL) "
	cQuery+= " Where"
	cQuery+= " FJP.FJP_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"

	
	cQuery+= " AND FJP.FJP_DTPARC  BETWEEN '"  + dTos(MV_PAR03) + "' AND '" + dTos(MV_PAR04) + "'"
	cQuery+= " AND SE1.E1_VENCREA  BETWEEN FJP.FJP_DTPARC - " + CVALTOCHAR(MV_PAR06) + " AND FJP.FJP_DTPARC + " + CVALTOCHAR(MV_PAR06) 
	
	cQuery+= " AND FJP.FJP_SITUAC != '2'"
	cQuery+= " AND (E1_SALDO+E1_SDACRES-E1_SDDECRE) BETWEEN FJP_VALOR - " + CVALTOCHAR(MV_PAR05) + " AND FJP_VALOR + " + CVALTOCHAR(MV_PAR05)
	
	
	cQuery := ChangeQuery(cQuery)
		
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasMCMV,.F.,.T.)
	
	dbSelectArea("FJP")

	dbSelectArea("SE1")

	
	 If !(cAliasMCMV)->(Eof())

		cBanco 		:= MV_PAR08
		cAgencia	:= MV_PAR09
		cConta		:= MV_PAR10

		BEGIN TRANSACTION
			
	    While !(cAliasMCMV)->(Eof())
	    
	    	SE1->( DbGoTo( (cAliasMCMV)->SE1RECNO) )
			FJP->( DbGoTo( (cAliasMCMV)->FJPRECNO) )
								
				lRet:= F915GrBx((cAliasMCMV)->SE1RECNO, FJP->FJP_VALOR, cBanco, cAgencia, cConta)
				
				If lRet 
					 cChave := SE1->E1_PREFIXO + "|" + SE1->E1_NUM     + "|" + SE1->E1_PARCELA + "|" + ;
								 SE1->E1_TIPO  + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
		  				            
					 F915AtuFJP(cChave, (cAliasMCMV)->FJPRECNO)
			
				Endif
			
			(cAliasMCMV)->(dbSkip())
      
        Enddo

		END TRANSACTION
        
      Endif
	
	(cAliasMCMV)->(dbCloseArea())		 	    
    

Return


/*/{Protheus.doc} F915GrBx
Função para efetuar a baixa/estorno de titulos a pagar e receber via execauto

@author Totvs
@param nRecnoSE1  Chave do titulo para baixa
@param nValor  parametro define valor da baixa
 ------------------

@since 19/01/2015
@version 11.8
/*/
Static Function F915GrBx(nRecnoSE1, nValor, cBco915, cAge915, cCta915)

Local lRet:=  .T.
Local aVetor:= {}


Private lMsErroAuto  := .F.
Private lMsHelpAuto  := .T.
Private lMostraErro  := .F.

Default nValor  := 0
Default nRecnoSE1  := 0


	lMsErroAuto := .F.
	dbSelectArea( "SE1" )

	
	 	SE1->(DbGoTo(nRecnoSE1))
	
		
		AADD(aVetor,{"E1_PREFIXO"		, SE1->E1_PREFIXO 		,Nil})
		AADD(aVetor,{"E1_NUM"			, SE1->E1_NUM       	,Nil})
		AADD(aVetor,{"E1_PARCELA"		, SE1->E1_PARCELA  		,Nil})
		AADD(aVetor,{"E1_TIPO"	   	 	, SE1->E1_TIPO     		,Nil})
		AADD(aVetor,{"E1_CLIENTE"		, SE1->E1_CLIENTE  		,Nil})
		AADD(aVetor,{"E1_LOJA"	    	, SE1->E1_LOJA     		,Nil})
		AADD(aVetor,{"E1_MOEDA"	    	, SE1->E1_MOEDA     	,Nil})
		AADD(aVetor,{"AUTMOTBX"	    	, "NOR"            		,Nil})
		AADD(aVetor,{"AUTDTBAIXA"		, dDataBase				,Nil})
		AADD(aVetor,{"AUTDTDEB"			, dDataBase				,Nil})
		AADD(aVetor,{"AUTHIST"	    	, OemToAnsi(STR0010)	,Nil})
		AADD(aVetor,{"AUTBANCO"			, cBco915				,NIL}) //Banco
		AADD(aVetor,{"AUTAGENCIA"		, cAge915				,NIL}) //agencia
		AADD(aVetor,{"AUTCONTA"			, cCta915				,NIL}) //Conta
		AADD(aVetor,{"AUTVALREC"		, nValor				,NIL}) //Valor de pagamento
					
		MSExecAuto({|x,y| Fina070(x,y)},aVetor,3)
		
		//Em caso de erro na baixa desarma a transacao
		If lMsErroAuto 
			lRet:= .F.
			If !IsBlind()
				MOSTRAERRO() // Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
			EndIf
		Endif
	//Endif

Return lRet

/*/{Protheus.doc} F915AtuFJP
Função para efetuar a baixa/estorno de titulos a pagar e receber via execauto

@author Totvs
@param nRecno  Recno da FJP para atualização
@param cChave  Chave do titulo para baixado
 ------------------

@since 19/01/2015
@version 11.8
/*/
Static Function F915AtuFJP(cChave, nRecno)

Local oModel  	:= FWLoadModel("FINA915")
Local lRet			:= .T.


	dbSelectArea("FJP")
	(FJP->(DbGoTo(nRecno)))

		
	oModel:SetOperation( MODEL_OPERATION_UPDATE ) //ALTERAÇÃO
	oModel:Activate()
	
		If !Empty(cChave)
			oModel:SetValue("FJPMASTER", "FJP_SITUAC"  , "2"	)
			oModel:SetValue("FJPMASTER", "FJP_TITULO"    , cChave)
		Else
			oModel:SetValue("FJPMASTER", "FJP_SITUAC"    , "3"	)
		Endif
	
		If oModel:VldData()
		    oModel:CommitData()
	  	Else
			lRet := .F.
		    cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[6])        	
		    
		    Help( ,,"F915BVL",,cLog, 1, 0 )	             
		Endif			
					
		
	oModel:DeActivate()
	
	
Return lRet


/*/{Protheus.doc} F915CanFJP
Função para efetuar a baixa/estorno de titulos a pagar e receber via execauto

@author Totvs
 ------------------

@since 19/01/2015
@version 11.8
/*/
Function F915CanFJP()
Local oModel  	:= FWLoadModel("FINA915")
Local lRet			:= .T.


	//dbSelectArea("FJP")
	//(FJP->(DbGoTo(nRecno)))

		
	oModel:SetOperation( MODEL_OPERATION_UPDATE ) //ALTERAÇÃO
	oModel:Activate()
	
		
		oModel:SetValue("FJPMASTER", "FJP_SITUAC"  , "1"	)
		oModel:SetValue("FJPMASTER", "FJP_TITULO"    , "")
		
		If oModel:VldData()
		    oModel:CommitData()
	  	Else
			lRet := .F.
		    cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[6])        	
		    
		    Help( ,,"F915BVL",,cLog, 1, 0 )	             
		Endif			
					
		
	oModel:DeActivate()
	
	
Return lRet