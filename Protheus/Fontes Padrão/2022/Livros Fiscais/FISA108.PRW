#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA108.CH"
 
#DEFINE MV_GGFCT83	      01
#DEFINE MV_ENECT83	      02
#DEFINE MV_COMCT83	      03
#DEFINE MV_2DCT83	   	  04
#DEFINE MV_UTENC83	      05 //Define a utilização de energia elétrica na CAT83.
#DEFINE MV_CAT8301	      06 //Define código e descricação da movimentação automática 1E para 2D
#DEFINE MV_CAT8302	      07 //Define código e descricação da movimentação automática 1C para 2D
#DEFINE MV_CAT8303	      08 //Define código e descricação da movimentação automática 1C para 2E
#DEFINE MV_CAT8304	      09 //Define código e descricação da cdumovimentação automática 2E para Demais Fichas
#DEFINE MV_CAT8305         10 //Define código e descricação da movimentação para perdas e sobras na SBC
#DEFINE MV_RTCAT83         11 //Define se os rateios da Cat83 serão definidos e gravados automaticamente ou se o usuário irá definir manualmente.
#DEFINE MV_FORPROC         12 //Define se a cat83 continuará o processamento com fichas pendente ATENÇÃO: NÃO ORIENTAR O CLIENTE A UTILIZAR, SE POSSIVEL NEM CITAR A EXISTENCIA, NÃO É ACONSELHAVEL O USO
#DEFINE MV_ELCAT83         13 //Define o cod. do enquadramento legal da operação por estado conforme a tabela CCV.
#DEFINE MV_1BCT83          14 //Define Código de produto genérico para processamento da Cat83 da Ficha 1B
#DEFINE MV_LIMSLDF         15 //Define o limite que deve ser considerado para zerar o saldo final na CDU, caso o mesmo resulte em negativo
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA108

Função que irá fazer o processamento das fichas da CAT083.

@author Erick G. Dias
@since 08/04/2014
@version 11.80
 
/*/ 
//-------------------------------------------------------------------
Function FISA108()
    
Local oProcess
Local lEnd	:= .F.
Local lProcessou	:= .T.
Local lDicion:= AliasIndic('CDU') .And. AliasIndic('CDZ') .And. AliasIndic('CLP') .And. AliasIndic('CLQ') .And. AliasIndic('CLR') .And. AliasIndic('CLT') .And. ;
	AliasIndic('CLU') .And. AliasIndic('CLV') .And. AliasIndic('CLW') .And. AliasIndic('CLX') .And. AliasIndic('CLZ') .And. AliasIndic('F01') .And. ;
	AliasIndic('F04') .And. AliasIndic('F06') .And. AliasIndic('F0H') 

PRIVATE aFil		:= {}

STATIC lAutomato   := IiF(IsBlind(),.T.,.F.)
STATIC aParSX6
  
/*
Valida se existe as tabelas no ambiente da 12, 
Tabelas: CDU, CDZ, CLP, CLQ, CLR, CLT, CLU, CLV, CLW, CLX, CLZ, F01, F04,  F06, F0H
*/
If lDicion
	If !lAutomato
		
		If  pergunte('FSA108',.T.)
			oProcess := FISProgress():New({|lEnd| lEnd :=PROCCAT083(oProcess,@lProcessou)},'Processamento da CAT083')
			oProcess:Activate()
			
			If lProcessou
				FWExecView('Filial: ' + FWGETCODFILIAL + ' - ' +SM0->M0_FILIAL,'FISA108', MODEL_OPERATION_UPDATE,, { || .F. }, { || .T. })
			EndIF
			
		EndIF
	Else
	   Conout("Inicio Processamento Automático Cat83 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		//Não será necessario passar nenhum parametro
		//Pois nao utilizo a barra de preocessamento, e não preciso do retorno se processou corretamente
		PROCCAT083()	
		Conout("Fim Processamento Automático Cat83 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	EndIf
		
Else
	Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas')
EndIF
    
Return

Static Function PROCCAT083(oProcess,lProcessou)
    
    Local cArqTmp		:= ''
    Local cAliasTmp	:= ''
    Local cMsg		:= 'Já existe apuração processada para as filiais:'+ CRLF
    Local lProcSuces	:= .T.
    Local lExistApur	:= .F.
    Local nPos		:= 0
    Local nQtdProc	:= 0
    Local cAliasMod  := "MOD"
    Local aAreaSM0	:= {}
    Local lFimPer    := (Month(mv_par01) == 12 .And. Month(mv_par02) = 12)  
    Local TimeFim
    Local TimeInicio
    
    Default lProcessou := .F.
    
    dbSelectArea('CLP')
    dbSelectArea('CLQ')
    dbSelectArea('CLR')
    dbSelectArea('CLT')
    dbSelectArea('CLU')
    dbSelectArea('CLV')
    dbSelectArea('CLW')
    dbSelectArea('CLX')
    
    aFil	:= FSA008Fil(IIF(!Empty(mv_par03) .And. (mv_par03 == 1 .Or. mv_par03 == 2 ), mv_par03 == 1, .F.))
    nQtdProc	:= Len(aFil)
    DbSelectArea("SM0")
    
    IF Len(aFil) > 0
        
        aAreaSM0 := SM0->(GetArea())
        CLR->(dbSetOrder(3))//CLR->(dbSetOrder(4)) 
        
        //Processo o laço primeiro para verificar quais filiais já possuem processamento realizado
        For nPos:= 1 to Len(aFil)
            
            SM0->(DbGoTop ())
            SM0->(MsSeek (aFil[nPos][1]+aFil[nPos][2], .T.))	//Pego a filial mais proxima
            //SM0->M0_CODIGO,SM0->M0_CODFIL
            cFilAnt := FWGETCODFILIAL
            
            If CLR->(MsSeek(xFilial("CLR")+ dTos(mv_par01)))
            	
                //Já existe informação gravada para a filial
                aFil[nPos][6]	:= .F.
                cMsg	+= ' - ' + aFil[nPos][2]	+CRLF
                lExistApur	:= .T.
                nQtdProc --
            EndIF
            
        Next nPos
        
        RestArea (aAreaSM0)
        cFilAnt := FWGETCODFILIAL
        
        If lExistApur
            cMsg	+= CRLF
            cMsg	+= 'Deseja reprocessar apuração destas filiais?'
            If lAutomato .Or. ( ApMsgYesNo(cMsg) )		//Exibe as filiais que já processaram, e pergunta se deseja reprocessar
                //Aqui clicou no sim e deseja reprocessar novamente todas as filiais
                nQtdProc	:= Len(aFil)
                For nPos:= 1 to Len(aFil)
                    aFil[nPos][6]	:= .T.
                Next nPos
            EndIF
        EndIF
        
        TimeInicio := Time()
        ProcCache()
        
        ProcLogIni({})
        ProcLogAtu("INICIO","#### --- Início do Processamento --- #### " + Time(),,upper('FISA108'))

		 If !lAutomato
	        oProcess:Set1Progress((14*nQtdProc) + 2)
	        oProcess:Set2Progress(1)
	        
	        oProcess:Inc1Progress('Processando Filial : ' + FWGETCODFILIAL)
	        
	        oProcess:SetDetProgress('Início do Processamento',TimeInicio,;
	            'Fim do Processamento',"" ,;
	            'Tempo de Processamento',"" ,;
	            "","")
        EndIf
        
        For nPos:= 1 to Len(aFil)
            
            If aFil[nPos][6]
                
                SM0->(DbGoTop ())
                SM0->(MsSeek (aFil[nPos][1]+aFil[nPos][2], .T.))	//Pego a filial mais proxima
                cFilAnt := FWGETCODFILIAL
                
                If !lAutomato
	                //Processa toda apuração da CAT83
	                ProcLogAtu("MENSAGEM","Inicialização das tabelas - Filial " + FWGETCODFILIAL + " " + Time())
	                oProcess:Inc1Progress(FWGETCODFILIAL + ' - Inicializando Tabelas')
	                oProcess:Inc2Progress('Inicializando tabelas para Processamento ')
                EndIf
                
                LimpaTab()
                CriaTabTmp(@cArqTmp,@cAliasTmp)
                ProcLogAtu("MENSAGEM","Conclusão da inicialização das tabelas - Filial " + FWGETCODFILIAL + " " + Time())
                
                
                IF aParSX6[MV_RTCAT83]
                    PCAT83_MOD((mv_par01),(mv_par02),"","ZZZZZZZZZ",@cAliasMod)
                    ProcRateio(cAliasMod)
                EndIf
                
                If !lAutomato
                	  oProcess:Inc1Progress(FWGETCODFILIAL + ' - Atualizando Saldos Iniciais')
                	  oProcess:Inc2Progress(FWGETCODFILIAL + ' - Atualizando Saldos Iniciais')
                EndIf
                
                ProcSldIni(mv_par01,cAliasTmp)
                
                Copia5A(mv_par01, mv_par02) 
                
                If !lAutomato
                	  oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Documentos de Entrada')
                	  oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Documentos de Entrada')
                EndIf
                
                ProcSD1(mv_par01, mv_par02,cAliasTmp, oProcess)
                
                If !lAutomato
                	  oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Operações de Estoque')
                	  oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Operações de Estoque')
                EndIf
                
                ProcSD3(mv_par01, mv_par02,cAliasTmp,oProcess)
                
                If !lAutomato
                   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Perdas Produção')
                   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Perdas Produção')
                EndIf
                
                ProcSBC(mv_par01, mv_par02,cAliasTmp,oProcess)
                
                If !lAutomato
                   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Documentos de Saída')
                   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Documentos de Saída')
                EndIf
                
                ProcSD2(mv_par01, mv_par02,cAliasTmp,oProcess)
                
                IF (mv_par05 == 2 .OR. mv_par05 == 3).AND.  IntTms()
                
                	   If !lAutomato    
                    	   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Documentos de Saída - Transportes')
                    	   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Documentos de Saída - Transportes')
                	   EndIf 
                    
                    ProcDT6(mv_par01, mv_par02,cAliasTmp,oProcess, Iif (mv_par05 == 2,'6G','6H' ))
                    
                    If !lAutomato
                       oProcess:Set2Progress(4)
                       oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Saídas 1E para 2D')
                       oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Saídas 1E para 2D')
                    EndIF
                    
                    SaiTotAuto(mv_par01, mv_par02, cAliasTmp, '1')
                    
                EndIF
                
                If aParSX6[MV_UTENC83]  == '3'
               
                   If !lAutomato
                      //utilização da energia elétrica para transportes na ficha 2D
                      oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Saídas 1C para 2D')
                      oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Saídas 1C para 2D')
                   EndIf
               
                    SaiTotAuto(mv_par01, mv_par02, cAliasTmp, '3')
                ElseIf aParSX6[MV_UTENC83]  == '2'

                    If !lAutomato
                       //utilização da energia como gasto gerais na ficha 2E
                       oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Saídas 1C para 2E')
                       oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Saídas 1C para 2E')
                    EndIf

                    SaiTotAuto(mv_par01, mv_par02, cAliasTmp, '2')
                EndIF
                
                If !lAutomato
                   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando saídas de Gastos Gerais')
                   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando saídas de Gastos Gerais')
                EndIf
                
                EntSaiGGF(mv_par01, mv_par02, cAliasTmp)
                
                Atu2F(mv_par01,mv_par02) 
                
                If !lAutomato
                    oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Rateio da ficha 4B')
                    oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Rateio da ficha 4B')
                EndIf
                
                Proc4B(mv_par01,mv_par02)
                
                If !lAutomato
                   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Serviço de Comunicação (Fichas 1D/6C)')
                   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Serviço de Comunicação (Fichas 1D/6C)')
                EndIf
                
                Proc1D6C(mv_par01,mv_par02)
                
                If !lAutomato
                   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Atualizando valores de Custo e ICMS')
                   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Atualizando valores de Custo e ICMS')
                EndIf
                
                lProcSuces	:= ProcValCAT(mv_par01,mv_par02,cAliasTmp,oProcess)
                               
                
                If !lAutomato
                   oProcess:Set2Progress(2)
                   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Atualizando Fichas 6A e 6B.')
                   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Atualizando Fichas 6A e 6B.')
                EndIf
                
                Atu6A6B(mv_par01,mv_par02,cAliasTmp)
                
                /*oProcess:Set2Progress(2)
                oProcess:Inc1Progress(FWGETCODFILIAL + ' - Atualizando Valores de estornos de Produção')
                oProcess:Inc2Progress(FWGETCODFILIAL + ' -  Atualizando Valores de estornos de Produção')
                //AtuEstProd(mv_par01,mv_par02)*/
                
                DevVenda(mv_par01,mv_par02)
                
                //Verificando as saídas da ficha 13-Energia para gastos gerais
                Atu1C2E(mv_par01,mv_par02)
                
                If !lAutomato
                   oProcess:Inc1Progress(FWGETCODFILIAL + ' - Atualizando valores de saldos finais')
                   oProcess:Inc2Progress(FWGETCODFILIAL + ' - Atualizando valores de saldos finais')
                EndIf
                
                ProcSldFin(mv_par01,mv_par02)
                
                If mv_par04 == 1 .Or. lFimPer
                    
                    If !lAutomato
                       oProcess:Set2Progress(1)
                       oProcess:Inc1Progress(FWGETCODFILIAL + ' - Processando Inventário ficha 5G')
                       oProcess:Inc2Progress(FWGETCODFILIAL + ' - Processando Inventário ficha 5G')
                       oProcess:Inc2Progress(' ')
                    EndIf
                    
                    Proc5G(mv_par01, mv_par02, lFimPer)
                EndIf
                
                IF lProcSuces
                	   
                	   If !lAutomato
                       oProcess:Inc1Progress(FWGETCODFILIAL + ' - Verificando Saldos Finais')
                       oProcess:Inc2Progress(FWGETCODFILIAL + ' - Verificando Saldos Finais')
                    EndIf
                    
                    lProcSuces := ProcCdu(mv_par01,mv_par02)
                EndIf    
                
                DbSelectArea (cAliasTmp)
                (cAliasTmp)->(DbCloseArea ())
            EndIF
            
        Next nPos
        
        If !lAutomato
	        oProcess:Set1Progress(1)
	        oProcess:Set2Progress(1)
	        oProcess:Inc1Progress('Concluído')
	        oProcess:Inc2Progress('Concluído')
        EndIf
        
        RestArea (aAreaSM0)
        cFilAnt := FWGETCODFILIAL
        
        ProcLogAtu("FIM","#### --- Final do Processamento --- #### " + Time(),,upper('FISA108'))
        
        TimeFim := Time()
        
        If !lAutomato
           oProcess:SetDetProgress('Início do Processamento',TimeInicio,;
               'Fim do Processamento',TimeFim ,;
               'Tempo de Processamento',ELAPTIME(TimeInicio,TimeFim) ,;
               "","")
        EndIf
        
        If lProcSuces
            MsgInfo('Apuração Concluída com Sucesso')
        Else
            MsgInfo('Apuração Concluída, porém existem fichas que não foram concluídas, favor verificar relatório de Resumo de Processamento!')
        EndIF
        lProcessou	:= .T.
    Else
        MsgInfo('Processamento não será feito pois nenhuma filial foi selecionada')
        lProcessou	:= .F.
    EndIF
    
Return

Static Function MenuDef()
Return FWMVCMenu( "FISA108")

//Return FWMVCMenu( 'FISA108' )

Static Function ModelDef()
    
    Local oModel
    Local oStruABA	:= FWFormStruct(1,'CLR')
    Local oStruABA1	:= MT24Struct(1,'ABA1')
    Local bLoadABA1  := { || LoadGrid() }
    
    oModel	:=	MPFormModel():New('FISA108')
    
    oModel:AddFields( 'MODEL_CAT83' ,, oStruABA)
    oModel:SetPrimaryKey({'CLR_FILIAL', 'CLR_FILMOV','CLR_PERIOD','CLR_FICHA','CLR_PROD','CLR_NRLAN', 'CLR_NRORD'})
    
    oModel:AddGrid( 'MODEL_CAT83G', 'MODEL_CAT83', oStruABA1,,,,,bLoadABA1)
    oModel:GetModel( 'MODEL_CAT83G' ):SetNoInsertLine( .T. )
    oModel:GetModel( 'MODEL_CAT83G' ):SetNoUpdateLine( .T. )
    oModel:GetModel( 'MODEL_CAT83G' ):SetNoDeleteLine( .T. )
    
Return oModel

Static Function ViewDef()
    
    Local oModel     	 := FWLoadModel( 'FISA108' )
    Local oView        := FWFormView():New()
    Local oStruABA1   := MT24Struct(2, 'ABA1')
    
    oView:SetModel( oModel )
    oView:AddUserButton( 'Relatórios', 'RELATORIOS', {|oView| FISR100()} )
    oView:AddUserButton( 'Histórico', 'HISTÓRICO', {|oView| ProcLogView("","FISA108")} )
    
    //Cria View para cada grid
    oView:AddGrid( 'VIEW_ABA1' ,oStruABA1  ,'MODEL_CAT83G'  )
    
    //Títulos das telas
    oView:EnableTitleView('VIEW_ABA1','Apuração Módulo 6 -  CAT 83')//'Operações de Saída por CST e Regime'
    
    //Cria a pasta
    oView:CreateFolder( 'PASTAS' )
    
    //Cria as abas
    oView:AddSheet( 'PASTAS', 'ABA01', 'CAT83' )//'OPERAÇÕES DE SAÍDAS'
    
    //Cria BOX
    oView:CreateHorizontalBox( 'TELA1', 100,,, 'PASTAS', 'ABA01' )
    
    //Relaciona cada grid com sua respectiva aba na tela
    oView:SetOwnerView( 'VIEW_ABA1'  , 'TELA1')
    
   // oView:SetViewProperty("*", "ENABLENEWGRID")
   //  oView:SetViewProperty( "*", "GRIDNOORDER") 
    
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} x002Tabs

Função que monta as propriedades de cada campo da tabela temporária
de cada aba das telas de apuração

@param  	cTabela  - Tabela a qual serão criados os campos
@return	aCampos  - Array com as propriedades dos campos que serão criados

@author Erick G. Dias
@since 08/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function a024Tabs(cTabela)
    
    Local aCampos	:= {}
    
    //aAdd(aCampos, {/*Título*/,/*Nome do campo*/,/*Tipo*/,/*Tamanho*/,/*Decimal*/,/*Ordem*/,/*Array com help*/,/*Picture*/,/*Campo editáveç*/})
    
    Do Case
        
    Case cTabela == 'ABA'
        aAdd(aCampos, {'Operações','ABA_CMP1' ,'C',75,0,'01',{'Apuração CAT 83'},'@!'				  ,.T.})//'Operações'
        aAdd(aCampos, {'Operações','ABA_CMP2' ,'C',75,0,'01',{'Apuração CAT 83'},'@!'				  ,.T.})//'Operações'
    Case cTabela == 'ABA1'
        //---------------------------------------------
        // Cria as colunas da primeira tela da apuração
        //---------------------------------------------
        aAdd(aCampos, {'Ficha - Hipótese de Geração' + space(200),'ABA1_CMP1' ,'C',50,0,'01',{'Ficha - Hipótese de Geração'},'@!'	,.T.})//'Ficha - Hipótese de Geração'
        aAdd(aCampos, {'Valor Total','ABA1_CMP2','N',14,2,'02',{'Valor Total'},'@E 999,999,999.99',.T.})//'Valor Total'
        
    EndCase
    
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} a002LdGrid

Função que irá retornar as informações para pouplar as linhas
das tabelas temporárias de cada aba da tela de apuração.

@param  	cTabela  - Tabela a qual serão será populada
@return	aLoad   - Array com as informações e valores para popular as telas

@author Erick G. Dias
@since 08/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function LoadGrid()
    
    Local aLoad  		:= {}
    Local nX			:= 0
    Local objMod6 	:= MOD6XCAT83():New()
    Local nPos			:= 0
    
    objMod6:setDtDe(mv_par01)
    objMod6:setDtAte(mv_par02)
    
    aAreaSM0 := SM0->(GetArea())
    For nPos	:= 1 to Len(aFil)
        
        SM0->(DbGoTop ())
        SM0->(MsSeek (aFil[nPos][1]+aFil[nPos][2], .T.))	//Pego a filial mais proxima
        cFilAnt := FWGETCODFILIAL
        
        objMod6:ProcMod6()
        
    Next nPos
    
    RestArea (aAreaSM0)
    cFilAnt := FWGETCODFILIAL
    
    //---------------------------------------------------------------------------------
    // Insere informações na primeira tela da apuração - Resumo das operações de saídas
    //---------------------------------------------------------------------------------
    aAdd( aLoad, { nX++,  { '',} } )
    aAdd( aLoad, { nX++,  { STR0001,objMod6:getValor('6A')} } )//'   -   Ficha 6A - Operações com Aplicação de Alíquotas Diversificadas'
    aAdd( aLoad, { nX++,  { STR0002,objMod6:getValor('6B')} } )//'   -   Ficha 6B - Operações com Redução de Base de Cálculo'
    aAdd( aLoad, { nX++,  { STR0003,objMod6:getValor('6C')} } )//'   -   Ficha 6C - Operações Sem Pagamento do Imposto(Exportação)'
    aAdd( aLoad, { nX++,  { STR0004,objMod6:getValor('6D')} } )//'   -   Ficha 6D - Operações Sem Pagamento do Imposto(Zona Franca de Manaus)'
    aAdd( aLoad, { nX++,  { STR0005,objMod6:getValor('6E')} } )//'   -   Ficha 6E - Operações Sem Pagamento do Imposto(Demais Casos)'
    aAdd( aLoad, { nX++,  { '',} } )
    aAdd( aLoad, { nX++,  { STR0006,objMod6:getValor('6F')} } )//'   -   Ficha 6F - Operações Não geradoras de Crédito Acumulado'
    aAdd( aLoad, { nX++,  { '',} } )
    aAdd( aLoad, { nX++,  { STR0007,objMod6:getValor('6G')} } )//'   -   Ficha 6G - Demonstrativo das Prestações de Serviço de Transporte - Crédito Outorgado'
    aAdd( aLoad, { nX++,  { STR0008,objMod6:getValor('6H')} } )//'   -   Ficha 6H - Demonstrativo das Prestações de Serviço de Transporte - Combustível e Redespacho'
    
    FreeObj( objMod6 )
    objMod6:= Nil
    
Return( aLoad )

Static Function MT24Struct(nOpcao,cTabela)
    
    Local aCampos	:= {}
    Local nCont	:= 0
    Local oStru
    
    //Chama Função para criar os campos conforme tabela processada
    aCampos:= a024Tabs(cTabela)
    
    //Quando for chamada para criar Model
    If nOpcao == 1
        
        oStru := FWFormStruct( 1 , '')
        For nCont := 1 to len (aCampos)
            oStru:AddField( ; 					// Ord. Tipo Desc.
            aCampos[nCont][1] , ;// [01] C Titulo do campo
            aCampos[nCont][1] , ;// [02] C ToolTip do campo
            aCampos[nCont][2] , ;// [03] C identificador (ID) do Field
            aCampos[nCont][3] , ;// [04] C Tipo do campo
            aCampos[nCont][4] , ;// [05] N Tamanho do campo
            aCampos[nCont][5] , ;	// [06] N Decimal do campo
            NIL				,;	// [07] B Code-block de validação do campo
            NIL 				, ;	// [08] B Code-block de validação When do campo
            {}					, ;	// [09] A Lista de valores permitido do campo
            NIL 				, ;	// [10] L Indica se o campo tem preenchimento obrigatório
            nil					, ;	// [11] B Code-block de inicializacao do campo
            NIL 				, ;	// [12] L Indica se trata de um campo chave
            .F. 				, ;	// [13] L Indica se o campo pode receber valor em uma operação de update.
            .F. ) 					// [14] L Indica se o campo é virtual
        Next nCont
        
        //Quando for chamada para criar a View
    ElseIF nOpcao == 2
        
        oStru := FWFormStruct( 2, '')
        For nCont := 1 to len (aCampos)
            oStru:AddField( ;
                aCampos[nCont][2], ; // [01] C Nome do Campo
            aCampos[nCont][6], ;	// [02] C Ordem
            aCampos[nCont][1], ;	// [03] C Titulo do campo
            aCampos[nCont][1], ;	// [04] C Descrição do campo
            aCampos[nCont][7], ; // [05] A Array com Help
            aCampos[nCont][3], ; 	// [06] C Tipo do campo
            aCampos[nCont][8], ; // [07] C Picture
            NIL 			   , ;	// [08] B Bloco de Picture Var
            ''                 , ; 	// [09] C Consulta F3
            aCampos[nCont][9]	, ; 	// [10] L Indica se o campo é evitável
            nil				   , ; 	// [11] C Pasta do campo
            NIL                , ;	// [12] C Agrupamento do campo
            {}                 , ; 	// [13] A Lista de valores permitido do campo
            NIL                , ;	// [14] N Tamanho Maximo da maior opção do combo
            NIL                , ; 	// [15] C Inicializador de Browse
            .F.                , ; 	// [16] L Indica se o campo é virtual
            NIL )
        Next nCont
        
    EndIF
    
Return oStru

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaTab()
Função que irá chamar função para deletar informações de cada tabela.

@author Erick G. Dias
@since 01/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function LimpaTab()
    
    DeleteTab('CLP')
    DeleteTab('CLQ')
    DeleteTab('CLR')
    DeleteTab('CLT')
    DeleteTab('CLU')
    //DeleteTab('CLV')
    DeleteTab('CLW')
    DeleteTab('CLX')
    DeleteTab('F04')
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteTab()
Strings para poder limpar as tabelas da apuração da cat quando usuário
desejar refazer os cálculos.

@author Erick G. Dias
@since 01/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function DeleteTab(cTab)
    
    Local cQuery	:= ''
    
    Do Case
    Case cTab == 'CLP'
        cQuery := "DELETE FROM "+RetSqlName("CLP")+" "
        cQuery += "WHERE CLP_FILIAL='"+xFilial("CLP")+"' AND "
        cQuery += "CLP_PERIOD>='"+dTos(mv_par01)+"' AND CLP_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
    Case cTab == 'CLQ'
        cQuery := "DELETE FROM "+RetSqlName("CLQ")+" "
        cQuery += "WHERE CLQ_FILIAL='"+xFilial("CLQ")+"' AND "
        cQuery += "CLQ_DATA>='"+dTos(mv_par01)+"' AND CLQ_DATA <= '" + dTos(mv_par02)  + " ' "
        
    Case cTab == 'CLR'
        cQuery := "DELETE FROM "+RetSqlName("CLR")+" "
        cQuery += "WHERE CLR_FILIAL='"+xFilial("CLR")+"' AND "
        cQuery += "CLR_PERIOD>='"+dTos(mv_par01)+"' AND CLR_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
    Case cTab == 'CLT'
        cQuery := "DELETE FROM "+RetSqlName("CLT")+" "
        cQuery += "WHERE CLT_FILIAL='"+xFilial("CLT")+"' AND "
        cQuery += "CLT_PERIOD>='"+dTos(mv_par01)+"' AND CLT_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
    Case cTab == 'CLU'
        cQuery := "DELETE FROM "+RetSqlName("CLU")+" "
        cQuery += "WHERE CLU_FILIAL='"+xFilial("CLU")+"' AND "
        cQuery += "CLU_PERIOD>='"+dTos(mv_par01)+"' AND CLU_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
    Case cTab == 'CLV' .And. (mv_par04 == 1 .Or. (Month(mv_par01) == 12 .And. Month(mv_par02) = 12)  ) 
        cQuery := "DELETE FROM "+RetSqlName("CLV")+" "
        cQuery += "WHERE CLV_FILIAL='"+xFilial("CLV")+"' AND "
        cQuery += "CLV_PERIOD>='"+dTos(mv_par01)+"' AND CLV_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
    Case cTab == 'CLW'
        cQuery := "DELETE FROM "+RetSqlName("CLW")+" "
        cQuery += "WHERE CLW_FILIAL='"+xFilial("CLW")+"' AND "
        cQuery += "CLW_PERIOD>='"+dTos(mv_par01)+"' AND CLW_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
    Case cTab == 'CLX'
        cQuery := "DELETE FROM "+RetSqlName("CLX")+" "
        cQuery += "WHERE CLX_FILIAL='"+xFilial("CLX")+"' AND "
        cQuery += "CLX_PERIOD>='"+dTos(mv_par01)+"' AND CLX_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
        
    Case cTab == 'F04'
        cQuery := "DELETE FROM "+RetSqlName("F04")+" "
        cQuery += "WHERE F04_FILIAL='"+xFilial("F04")+"' AND "
        cQuery += "F04_PERIOD>='"+dTos(mv_par01)+"' AND F04_PERIOD <= '" + dTos(mv_par02)  + " ' "
        
    EndCase
    
    IF !EmpTy(Alltrim(cQuery))
        TcSqlExec(cQuery)
    EndIF
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AdFichaMov()
Função para gravação das fichas 1A, 1B, 1C, 1D, 1E, 2A, 2B, 2C, 2D, 2E, 2F,
2G, 3A, 3B e 3C. independente da sua origem, pois será considerado objeto oCat83
já populado. Aqui a função irá verificar através do código de lançamento a origem e
destino, se origem for externa irá gravar somente o destino, se o destino for externo
irá gravar somente a origem, caso contrário irá gravar a ficha de origem realizando a baixa
e tambéma ficha de destino atualizando o saldo de forma automática.

@author Erick G. Dias
@since 09/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AdFichaMov(oCat83,oTabCLR,oTabF04)
    
    Local cFichaOrig	:= SubStr(oCat83:getCdLanto(),1,2) // Pega Ficha de origem
    Local cFichaDest	:= SubStr(oCat83:getCdLanto(),3,2) // Pega Ficha de destino
    Local lProcFicha	:= .F.
    Local lAcumula	:= .F.
    Local nCont		:= 0
    Local cNumOrd	:= ''
    Local lSaldo	:= .T.
    Local cIdCab	:= ''
    Local cProdCab	:= ''
    Local a1C			:= {}
    
    /*Primeiro irá adicionar os valores de detalhes para posteriormente - CLS
    adicionar as informações da movimentação - CLR
    
    As informações passadas abaixo são as informações em comum para ficha de origem e ficha de destino*/
    
    //DETALHAMENTO DA MOVIMENTAÇÃO
    
    oTabCLR:setParam('CLR_ICMS'		,oCat83:getVICMS()	)
    oTabCLR:setParam('CLR_CUSTO'	,oCat83:getVCusto()	)
    oTabCLR:setParam('CLR_UICMS'	,oCat83:getUniICMS()	)
    oTabCLR:setParam('CLR_UCUSTO'	,oCat83:getUniCust()	)
    oTabCLR:setParam('CLR_IPI'		,oCat83:getVIPI()		)
    oTabCLR:setParam('CLR_OUTROS'	,oCat83:getVOutros()	)
    oTabCLR:setParam('CLR_QTDE'		,oCat83:getQtde()		)
    oTabCLR:setParam('CLR_PERCCJ'	,oCat83:getPerCust()	)
    oTabCLR:setParam('CLR_QTDECP'	,oCat83:getQtdeCOO()	)
    oTabCLR:setParam('CLR_SAIDA'	,oCat83:getVSaida()	)
    oTabCLR:setParam('CLR_VCROUT'	,oCat83:getCrdOuto()	)
    oTabCLR:setParam('CLR_VCRDSP'	,oCat83:getCrdOper()	)
    oTabCLR:setParam('CLR_VCRCOM'	,oCat83:getCrdComu()	)
    oTabCLR:setParam('CLR_ICMCMP'	,oCat83:getIcmsCom()	)
    oTabCLR:setParam('CLR_ICMSDE'	,oCat83:getIcmsDev()	) //ICMS Devido
    oTabCLR:setParam('CLR_VPRENG'	,oCat83:getTotNGe()	)
    oTabCLR:setParam('CLR_ICMDEB'	,oCat83:getIcmsNGE()	) //ICMS debitado
    oTabCLR:setParam('CLR_VPREGE'	,oCat83:getTotGer()	)
    oTabCLR:setParam('CLR_ICMST'	,oCat83:getIcmsST()	)
    oTabCLR:setParam('CLR_VCROUT'	,oCat83:getOutProp()	)
    oTabCLR:setParam('CLR_CROUST'	,oCat83:getOutST()	)
    oTabCLR:setParam('CLR_VALBC'	,oCat83:getBasItem()	)
    oTabCLR:setParam('CLR_PCROUT'	,oCat83:getPerOuto()	)
    oTabCLR:setParam('CLR_TOTICM'	,oCat83:getTotICMS()	)
    oTabCLR:setParam('CLR_CREDAC'	,oCat83:getCrdAcum()	)
    oTabCLR:setParam('CLR_ALIQ'		,oCat83:getAliq()		)
    
    
    //Informações do cabecalho da movimentação
    oTabCLR:setParam('CLR_PERIOD'	,oCat83:getPeriodo()	)
    oTabCLR:setParam('CLR_PROD'		,oCat83:getCodProd()	)
    oTabCLR:setParam('CLR_IDNF'		,oCat83:getIdNf()		)
    oTabCLR:setParam('CLR_IDTMD'	,oCat83:getCodPart()	)
    oTabCLR:setParam('CLR_IDREM'	,oCat83:getIdRemet()	)
    oTabCLR:setParam('CLR_IDDEST'	,oCat83:getIdDest()	)
    oTabCLR:setParam('CLR_HIST'		,oCat83:getHist()		)
    oTabCLR:setParam('CLR_FILMOV'	,oCat83:getFilMov()	)
    oTabCLR:setParam('CLR_ARMAZ'	,oCat83:getArmazem()	)
    oTabCLR:setParam('CLR_NUMSEQ'	,oCat83:getNumSeq()	)
    oTabCLR:setParam('CLR_UFINI'	,oCat83:getUfIni()	)
    oTabCLR:setParam('CLT_UFDST'	,oCat83:getUfDest()	)
    oTabCLR:setParam('CLR_TPRD'		,oCat83:getTpReq()	)
    oTabCLR:setParam('CLR_NRDI'		,oCat83:getNDIDSI()	)
    oTabCLR:setParam('CLR_CODLAN'	,oCat83:getCdLanto()	)
    oTabCLR:setParam('CLR_TABMOV'	,oCat83:getTabMov()	)
    oTabCLR:setParam('CLR_ENQLEG'	,oCat83:getEnqLeg()	)
    oTabCLR:setParam('CLR_DESPAC'	,oCat83:getDespach()	)
    oTabCLR:setParam('CLR_COMOPE'	,oCat83:getComprov()	)
    oTabCLR:setParam('CLR_VEICUL'	,oCat83:getCodVeic()	)
    oTabCLR:setParam('CLR_KM'		,oCat83:getKM()		)
    oTabCLR:setParam('CLR_INDRAT'	,oCat83:getIndRat()	)
    oTabCLR:setParam('CLR_FOCORR'	,oCat83:getFPerda()	)
    oTabCLR:setParam('CLR_TPRD'		,oCat83:getTpReq()	)
    oTabCLR:setParam('CLR_UNID'		,oCat83:getUnidade()	)
    oTabCLR:setParam('CLR_TPDOC'	,oCat83:getTpDoc()	)
    oTabCLR:setParam('CLR_NRLAN'	,oCat83:getNrLanc())
    oTabCLR:setParam('CLR_PRDMOV'	,oCat83:getInsumo()	)
    oTabCLR:setParam('CLR_PART'		,oCat83:getCodPart()	)
    oTabCLR:setParam('CLR_CODREM'	,oCat83:getCodRem()	)
    oTabCLR:setParam('CLR_CODDST'	,oCat83:getCodDes()	)
    oTabCLR:setParam('CLR_EXPIND'  ,oCat83:getExpInd() )
    oTabCLR:setParam('CLR_PERRAT'  ,oCat83:getPerRat() ) 
    
    //Primeira volta processa ficha de origem se houver
    //Segunda volta processa ficha de destino se houver

    For nCont := 1 to 2
        lProcFicha	:= .F.
        lSaldo	:= .F.
        lAcumula	:= .F.
        
        /*Verifica aqui se a origem é externa...se for então não é necessário
        //processar/realizar baixa em nenhuma ficha de origem*/
        If nCont == 1	.AND. SubStr(cFichaOrig,1,1) <> '7'
            
            IF cFichaOrig == 'ZZ' //Se código iniciar com ZZ significa que está incluíndo linha de saldo inicial na ficha
                oTabCLR:setParam('CLR_TPMOV'		,'E'	) // A gravação da ficha de origem é sempre uma saída
                oTabCLR:setParam('CLR_CODLAN'		,'SALDO'	)
                oCat83:setFicha(cFichaDest)
                lProcFicha	:= .T.
                lSaldo	:= .T. // Irá incluir linha de saldo inicial
                cProdCab	:= 	oCat83:getCodProd()
            Else
                oCat83:setFicha(cFichaOrig)
                
                If SubStr(cFichaDest,1,1) <> '7'
                    oCat83:setCodOrig(cFichaDest) // Irá gravar primeiro a entrada então deverá gravar ficha de destino
                ElseIf SubStr(cFichaOrig,1,1) == '3' .AND. SubStr(oCat83:getCdLanto(),3,3) == '777'
                    cFichaDest	:= '6' + SubStr(oCat83:getCdLanto(),6,1)
                    oCat83:setCodOrig(cFichaDest)
                EndIF
                oTabCLR:setParam('CLR_TPMOV'		,'S'	) // A gravação da ficha de origem é sempre uma saída
                
                               
                If oCat83:getFicha() $ '11/12/13/14/15/21/22/25/26/27'
                    cProdCab	:= 	oCat83:getInsumo()
                Else
                    cProdCab	:= 	oCat83:getCodProd()
                EndIF

                // Para os casos de devoluções de Insumo 
                IF SubStr(oCat83:GetTpReq(),1,2) == 'DE'  .And. SubStr(oCat83:getFicha(),1,1) == '2' .And. !(SubStr(oCat83:GetTpReq(),3,1)$'5|7|4') .And.  !(Substr(oCat83:getCdLanto(),1,2)$'70') .And. !(Substr(oCat83:getCdLanto(),5,2)$'16')
                    cProdCab    :=  oCat83:getCodProd() 
                    oTabCLR:setParam('CLR_TPMOV'        ,'J'    ) // Trata-se de devolução de Produção - Saida I=Dev.Prod(Ent);J=Dev.Prod(Sai)
                EndIf    
            
                
                //Se for saída de alguma ficha para ficha 5B de perda, então o código de cabeçaho deverá ser o
                If substr(oCat83:getCdLanto(),3,2) == '52'
                    IF oCat83:getFicha() $'11/12/13/14/15'
                        cProdCab    :=  oCat83:getInsumo()
                    ELSE
                        cProdCab	:= 	oCat83:getCodProd()
                        oTabCLR:setParam('CLR_PRDMOV'	,oCat83:getInsumo()	)
                    EndIf
                EndIF
                
                //Estorno(Saída)
                IF oCat83:getEstorno()
                    oTabCLR:setParam('CLR_TPMOV'		,'H'	) //Trata-se de estorno na produção (Saída)
                    //Devolução
                ElseIF !Empty(oCat83:getTpMov())
                    oTabCLR:setParam('CLR_TPMOV'		,oCat83:getTpMov()	) //Trata-se de uma devolução
                EndIF
                
                
                lProcFicha	:= .T.
            EndIF
            
            //---------------------------------------------
            //Trecho onde deverá acumular valor na ficha 1C
            //---------------------------------------------
            
            IF cFichaOrig $ '13'//Se ficha de origem for 1C, então não deverá incluir ficha mas sim acumular.
                
                //Verifica se já existe saída da ficha 2F para alguma ficha
                a1C:= ExitFicha(oCat83:getPeriodo(), oCat83:getCodProd(), oCat83:getInsumo(), 'S', oCat83:getCdLanto(),cFichaOrig)
                
                If Len(a1C) > 0
                    
                    //Se já existir saída então irá somente acumular o valor de quantidade na saída da 2F e entrada na ficha de destino
                    //Atualiza a entrada na ficha de origem
                    CLR->(dbSetOrder(3))//CLR->(dbSetOrder(4))
                    If CLR->(MsSeek(xFilial("CLR") + DTOS(oCat83:getPeriodo()) + str(a1C[1][1],9) + Alltrim(cFichaOrig)+'O'))
                        RecLock('CLR',.F.)
                        CLR->CLR_QTDE		+=	oCat83:getQtde()
                        CLR->(MsUnLock())
                    EndIF
                    
                    //Atualiza a entrada na ficha de destino
                    If CLR->(MsSeek(xFilial("CLR") + DTOS(oCat83:getPeriodo()) + str(a1C[1][1],9) + Alltrim(a1C[1][2])+'D'))
                        RecLock('CLR',.F.)
                        CLR->CLR_QTDE		+=	oCat83:getQtde()
                        CLR->(MsUnLock())
                    EndIF
                    Exit //Sai do laço
                EndIF
            EndIF
        EndIf
        
        /*Verifica aqui se o destino é externa...se for então não é necessário
        //processar/realizar baixa em nenhuma ficha de destino*/
        
        If nCont == 2
            
            //Destino diferente de 7 deverá gravar ficha de destino
            If SubStr(cFichaDest,1,1) <> '7' .AND. cFichaOrig <> 'ZZ'
                lProcFicha	:= .T.
                //Se destino for 7 e origem for igual a 3. significa que é uma saída do módulo 3 para módulo 6.
            ElseIF SubStr(cFichaOrig,1,1) == '3' .AND. SubStr(oCat83:getCdLanto(),3,3) == '777'
                cFichaDest	:= '6' + SubStr(oCat83:getCdLanto(),6,1)
                //Passo aqui o valor do ICMS que é o valor do crédito no módulo 6.
                oTabCLR:setParam('CLR_CREDAC'	,oCat83:getVICMS()	)
                lProcFicha	:= .T.
            EndIF
            
            If lProcFicha
                oCat83:setFicha(cFichaDest)
                oTabCLR:setParam('CLR_TPMOV'		,'E'	) // A gravação da ficha de destino é sempre entrada.
                
                //Quanto for ZF de Manaus sempre será comprovada, pois já deve existir o código suframa no cadastro
                IF cFichaDest == "64"
                    oTabCLR:setParam('CLR_COMOPE',"1")
                EndIf
                
                //Estorno(Entrada)
                IF oCat83:getEstorno()
                    oTabCLR:setParam('CLR_TPMOV'		,'D'	) //Trata-se de estorno na produção (Entrada)
                    //Devolução de venda
                ElseIF !Empty(oCat83:getTpMov())
                    oTabCLR:setParam('CLR_TPMOV'		,oCat83:getTpMov()	) //Trata-se de uma devolução
                EndIF
                
                // Para os casos de devoluções de Insumo 
                IF SubStr(oCat83:GetTpReq(),1,2) == 'DE' .And. !(SubStr(oCat83:GetTpReq(),3,1)$'7|4') .And.  !(Substr(oCat83:getCdLanto(),1,2)$'70') .And. !(Substr(oCat83:getCdLanto(),5,2)$'16')
                    cProdCab    := oCat83:getInsumo()
                    oTabCLR:setParam('CLR_TPMOV'        ,'I'    ) // Trata-se de devolução de Produção - Entrada na Ficha - I=Dev.Prod(Ent);J=Dev.Prod(Sai)
                Else    
                    cProdCab	:= 	oCat83:getCodProd()
                EndIf    

				  If cFichaDest == '52'				  	
					cProdCab	:= 	oCat83:GetCodRes()
				  EndIF
                
                If SubStr(cFichaOrig,1,1) <> '7'
                    oCat83:setCodOrig(cFichaOrig) // Irá gravar a saida então deverá gravar ficha de origem
                EndIF
                
                If oCat83:getFicha() $ '61/62/63/64/65/66/67/68'
                    cProdCab	:=  PADR(oCat83:getFicha(),TAMSX3("B1_COD")[1])
                EndIF
                
            EndIF
        EndIF
        
        //Se atender critério irá processar a ficha
        If lProcFicha
            //Atualiza as informações que não sao em comum para ficha de origem e destino e realiza gravação da ficha
            
            //Número sequencial da ficha
            cNumOrd	:=  FSA108Seq(oCat83:getFicha(),oCat83:getAlsTmp(),lSaldo)
            
            cIdCab:= AddCab(oTabF04, oCat83:getPeriodo(), cProdCab, oCat83:getFicha() )
            
            If nCont == 1 //Primeira volta então irá popular com número de ordem da origem
                oCat83:setNrdOri(cNumOrd)
                oTabCLR:setParam('CLR_ORIDES'	,'O'	)
            ElseIF nCont == 2  //Segunda volta então irá popular com número de ordem de destino
                oCat83:setNrdDest(cNumOrd)
                oTabCLR:setParam('CLR_ORIDES'	,'D'	)
            EndIF
            
            oTabCLR:setParam('CLR_IDCAB'	,cIdCab	)
            oTabCLR:setParam('CLR_FICHA'	,oCat83:getFicha()	)
            oTabCLR:setParam('CLR_NRORD'	,cNumOrd) // Passa número sequencia da ficha
            oTabCLR:setParam('CLR_CODORI'	,oCat83:getCodOrig()	)
            
            oTabCLR:Save()
            
            
        EndIF
        
    Next nCont
    
    oTabCLR:Clear()
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFicha6C()
Função para gravar uma nova ficha 6B nas tabelas respectivas, independente
da sua origem, pois será considerado objeto oCat83 já populado.

@author Erick G. Dias
@since 01/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddFicha6C(oCat83,oTabCLR,oTabF04)
    
    Local cIdCab:= AddCab(oTabF04, oCat83:getPeriodo(),oCat83:getCodProd(), '63' )
    
    
    oTabCLR:setParam('CLR_FICHA'	,'63')
    oTabCLR:setParam('CLR_IDCAB'	,cIdCab			    )
    oTabCLR:setParam('CLR_SAIDA'	,oCat83:getVSaida()	)
    oTabCLR:setParam('CLR_CUSTO'	,oCat83:getVCusto()	)
    oTabCLR:setParam('CLR_ICMS'		,oCat83:getVICMS()	)
    oTabCLR:setParam('CLR_PCROUT'	,oCat83:getPerOuto()	)
    oTabCLR:setParam('CLR_VCROUT'	,oCat83:getCrdOuto()	)
    oTabCLR:setParam('CLR_VCRDSP'	,oCat83:getCrdOper()	)//Despesa operacionais
    oTabCLR:setParam('CLR_VCRCOM'	,oCat83:getCrdComu()	)//Valor crédito comunicação
    oTabCLR:setParam('CLR_ICMCMP'	,oCat83:getIcmsCom()	)
    oTabCLR:setParam('CLR_CREDAC'	,oCat83:getCrdAcum()	)
    oTabCLR:setParam('CLR_PERIOD'	,oCat83:getPeriodo()	)
    oTabCLR:setParam('CLR_PROD'		,oCat83:getCodProd()	)
    oTabCLR:setParam('CLR_NRLAN'	,oCat83:getNrLanc()	)
    oTabCLR:setParam('CLR_IDDET'	,oCat83:getIdDetal()	)
    oTabCLR:setParam('CLR_IDNF'		,oCat83:getIdNf()		)
    oTabCLR:setParam('CLR_IDREM'	,oCat83:getIdRemet()	)
    oTabCLR:setParam('CLR_IDDEST'	,oCat83:getIdDest()	)
    oTabCLR:setParam('CLR_ARMAZ'	,oCat83:getArmazem()	)
    oTabCLR:setParam('CLR_ENQLEG'	,oCat83:getEnqLeg()	)
    oTabCLR:setParam('CLR_COMOPE'	,oCat83:getComprov()	)
    oTabCLR:setParam('CLR_DESPAC'	,oCat83:getDespach()	)
    oTabCLR:setParam('CLR_NRLAN'	,oCat83:getNrLanc())
    oTabCLR:setParam('CLR_TPMOV'		,'E'	)
    oTabCLR:setParam('CLR_EXPIND'   ,oCat83:getExpInd())
    oTabCLR:Save()
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddCab()
Adiciona Nova Cabecalho da Ficha

@author Erick G. Dias
@since 02/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddCab(oTabF04, dData, cProd, cFicha, lConclui )
    
    DEFAULT lConclui := .F.
    
    oTabF04:setParam('F04_PERIOD'		,dData		)
    oTabF04:setParam('F04_PROD'			,cProd	)
    oTabF04:setParam('F04_FICHA'		,cFicha		)
    oTabF04:setParam('F04_STATUS'		,IIF(lConclui, '1', '2')	) //Será criado com STATUS não concluído
    
    
Return oTabF04:Save()


//-------------------------------------------------------------------
/*/{Protheus.doc} AddNota()
Adiciona nova nota fiscal na tabela CLQ, para utilização das informações
nas tabelas de movimenações.

@author Erick G. Dias
@since 02/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddNota(oTabCLQ, dData, cTpDoc, cCfop, cTpmov, cSerie, cNumero, cItem, cTipo, dDtOri, cTpOri, cSerOri, cNumOri, cItOri)
    
    
    DEFAULT dDtOri	:= CTOD('  /  /    ')
    DEFAULT cTpOri	:= ''
    DEFAULT cSerOri	:= ''
    DEFAULT cNumOri	:= ''
    DEFAULT cTipo	:= ''
    DEFAULT cItOri	:= ''
    
    oTabCLQ:setParam('CLQ_DATA'		,dData		)
    oTabCLQ:setParam('CLQ_TPDOC'	,cTpDoc	)
    oTabCLQ:setParam('CLQ_CFOP'		,cCfop		)
    oTabCLQ:setParam('CLQ_TPMOV'	,cTpmov	) //Saida / Entrada
    oTabCLQ:setParam('CLQ_SERIE'	,cSerie	)
    oTabCLQ:setParam('CLQ_NRDOC'	,cNumero	)
    oTabCLQ:setParam('CLQ_ITEM'		,cItem		)
    oTabCLQ:setParam('CLQ_TIPO'		,cTipo		)
    oTabCLQ:setParam('CLQ_DTORI'	,dDtOri	)
    oTabCLQ:setParam('CLQ_TPDCOR'	,cTpOri	)
    oTabCLQ:setParam('CLQ_SERORI'	,cSerOri	)
    oTabCLQ:setParam('CLQ_DOCORI'	,cNumOri	)
    oTabCLQ:setParam('CLQ_ITEORI'	,cItOri	)
    
    
Return oTabCLQ:Save()

//-------------------------------------------------------------------
/*/{Protheus.doc} AddPart()
Adiciona novo participante na tabela CLP, para utilização das informações
nas tabelas de movimenações.

@author Erick G. Dias
@since 02/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddParti(oTabCLP,dData,cFilPart,cCodPart,cLojaPart,cTpPart, lExterior)
    
    Local cCnpj := ''
    Local cIdPart 	:= ""
    
    IF cTpPart == '1' //Fornecedor
        SA2->(DbSetOrder(1))
        IF (SA2->(dbSeek(xFilial("SA2")+cCodPart + cLojaPart)))
            cCnpj:= SA2->A2_CGC
        EndIf
    Elseif cTpPart == '2'
        SA1->(DbSetOrder(1))
        IF (SA1->(dbSeek(xFilial("SA1")+cCodPart + cLojaPart)))
            cCNPJ:= SA1->A1_CGC
        EndIf
    ENDIF
    
    /*Se for exterior o ID do partifipante será gerado de acordo com seu dados: Tipo (1-Cliente|2-Fornecedor) +  Código + Loja.
      Se eu gravar com um ID aleatório não consigo separar os participantes que já foram inseridos no arquivo, pois no arquivo só pode ter um por CNPJ
    */
    IF lExterior
    	cIdPart := Alltrim(cTpPart + cCodPart + cLojaPart) 
    Else
    	cIdPart	:= Alltrim(cvaltochar(FSA108Seq('PA',oTabCLP:getAlsTmp() ))) //PA = participante

    EndIf 


    oTabCLP:setParam('CLP_IDPART'		,cIdPart		)
    oTabCLP:setParam('CLP_PERIOD'       ,dData          )
    oTabCLP:setParam('CLP_FLPART'       ,cFilPart       )
    oTabCLP:setParam('CLP_COD'          ,cCodPart       )
    oTabCLP:setParam('CLP_LOJA'         ,cLojaPart      )
    oTabCLP:setParam('CLP_TPPART'       ,cTpPart        )
    oTabCLP:setParam('CLP_CNPJ'         ,cCnpj          )

    
Return oTabCLP:Save(lExterior)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddRateio()
.

@author Erick G. Dias
@since 02/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddRateio(oTabCLT, dData,cProdDest, cFicha, nPerRat, nValCusto,;
        nValICMS, cInsumo, nQtde, nPrcUnit, nVlProjSai, ;
        nPerInsumo )
    
   // CLT_FILIAL+DTOS(CLT_PERIOD)+CLT_FICHA+CLT_PRDDST+CLT_INSUMO
    IF !(CLT->(dbSeek(xFilial("CLT")+DTOS(dData) + cFicha + cProdDest + cInsumo)))
    oTabCLT:setParam('CLT_PERIOD'		,dData				)
    oTabCLT:setParam('CLT_PRDDST'		,cProdDest			)
    oTabCLT:setParam('CLT_FICHA'		,cFicha			)
    oTabCLT:setParam('CLT_PERRAT'		,nPerRat			)
    oTabCLT:setParam('CLT_VALCUS'		,nValCusto			)
    oTabCLT:setParam('CLT_VALICM'		,nValICMS			)
    oTabCLT:setParam('CLT_INSUMO'		,cInsumo		)
    oTabCLT:setParam('CLT_QTDE'			,nQtde				)
    oTabCLT:setParam('CLT_PRCUNI'		,nPrcUnit			)
    oTabCLT:setParam('CLT_VLPRJS'		,nVlProjSai		)
    oTabCLT:setParam('CLT_PEATIC'		,nPerInsumo		)
    oTabCLT:Save()
     ENDIF   
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFicha5A()
.

Ficha Técnica

@author Erick G. Dias
@since 02/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddFicha5A(oTabCLU, cPeriodo, cProd, nPrcIns, cUnid,;
        nQuant, nQtdIns, nQtdUnt, nUnitCus, nValCusto,;
        nUnitIcms, nValIcms,nPerda,cApProd, lSobrePoe, cFicha)
    
Default cApProd	:= '2'
Default lSobrePoe	:= .F.

oTabCLU:setParam('CLU_PERIOD'		,cPeriodo		)
oTabCLU:setParam('CLU_PROD'			,cProd			)
oTabCLU:setParam('CLU_PRDINS'		,nPrcIns		)
oTabCLU:setParam('CLU_UNID'			,cUnid			)
oTabCLU:setParam('CLU_QUANT'		,nQuant		)//QTD PRODUZIDA
oTabCLU:setParam('CLU_QTDINS'		,nQtdIns		)//QTD DO INSUMO UTILIZADO
oTabCLU:setParam('CLU_QTDUNT'		,nQtdUnt		)//QTD POR UNIDADE DE PRODUTO
oTabCLU:setParam('CLU_UNTCUS'		,nUnitCus		)//VALOR DO CUSTO UNITARIO
oTabCLU:setParam('CLU_VALCUS'		,nValCusto		)//VALOR DO CUSTO TOTAL POR UNIDADE
oTabCLU:setParam('CLU_UNTICM'		,nUnitIcms		)//VALOR DO ICMS UNITARIO
oTabCLU:setParam('CLU_VALICM'		,nValIcms		)//VALOR DO ICMS TOTAL POR UNIDADE
oTabCLU:setParam('CLU_PERDA'		,nPerda		)
oTabCLU:setParam('CLU_APPROD'		,cApProd		)
oTabCLU:setParam('CLU_FICHA'       ,cFicha       )

oTabCLU:Save(lSobrePoe)
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFicha5G()
.

@author Erick G. Dias
@since 06/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddFicha5G(oTabCLV, cPeriodo, cProd, cCodInsumo, nQtde,;
        nValCusto, nValIcms)
    
    oTabCLV:setParam('CLV_PERIOD'		,cPeriodo		)
    oTabCLV:setParam('CLV_PROD'			,cProd			)
    oTabCLV:setParam('CLV_PRDINS'		,cCodInsumo	)
    oTabCLV:setParam('CLV_QUANT'		,nQtde			)
    oTabCLV:setParam('CLV_VALCUS'		,nValCusto		)
    oTabCLV:setParam('CLV_VALICM'		,nValIcms		)
    oTabCLV:Save()
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFicha5H()
.

@author Erick G. Dias
@since 06/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddFicha5H(oTabCLW, cPeriodo, cProd, cNrLan, cNrDoc,;
        cSerie, dDtDcEx, cNrDcEx, cSerEx, cNrDesp )
    
    oTabCLW:setParam('CLW_PERIOD'		,cPeriodo		)
    oTabCLW:setParam('CLW_PROD'			,cProd			)
    oTabCLW:setParam('CLW_NRLAN'		,cNrLan		)
    oTabCLW:setParam('CLW_NRDOC'		,cNrDoc		)
    oTabCLW:setParam('CLW_SERIE'		,cSerie		)
    oTabCLW:setParam('CLW_DTDCEX'		,dDtDcEx		)
    oTabCLW:setParam('CLW_NRDCEX'		,cNrDcEx		)
    oTabCLW:setParam('CLW_SRDCEX'		,cSerEx		)
    oTabCLW:setParam('CLW_NRDESP'		,cNrDesp		)
    oTabCLW:Save()
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFicha5H()


@author Erick G. Dias
@since 06/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AddFicha5I(oTabCLX, cPeriodo, cCodVeic, cPlaca, cCnpj,;
        cUf, cMun, cRenavam, cMarca, cMod, ;
        cAno, cRendComb  )
    
    oTabCLX:setParam('CLX_PERIOD'		,cPeriodo		)
    oTabCLX:setParam('CLX_CODVCL'		,cCodVeic		)
    oTabCLX:setParam('CLX_PLACA'		,cPlaca		)
    oTabCLX:setParam('CLX_CNPJ'			,cCnpj			)
    oTabCLX:setParam('CLX_UF'			,cUf			)
    oTabCLX:setParam('CLX_MUN'			,cMun			)
    oTabCLX:setParam('CLX_RENAV'		,cRenavam		)
    oTabCLX:setParam('CLX_MARCA'		,cMarca		)
    oTabCLX:setParam('CLX_MOD'			,cMod			)
    oTabCLX:setParam('CLX_ANO'			,cAno			)
    oTabCLX:setParam('CLX_RCOMB'		,cRendComb		)
    oTabCLX:Save()
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSldIni()
Função que irá processar os valores de saldos iniciais cadastrados
pelo usuário através da rotina MATA016 tabela CDU.

@author Erick G. Dias
@since 07/04/2015
@version 11.80d
/*/
//-------------------------------------------------------------------
Static Function ProcSldIni(dPeriodo,cAliasTmp)
    
    Local cSlctCDU	:= ''
    Local cAliasCDU	:= ''
    Local oCat83		:= CAT83ESTR():New()
    Local cPer			:= substr( dtos(dPeriodo),1,4)+substr( dtos(dPeriodo),5,2)
    Local oTabCLR		:= TABCLR():New()
    Local oTabF04		:= TABF04():New()
    Local oTabCLQ		:= TABCLQ():New()
    
    ProcLogAtu("MENSAGEM","Início Saldo Inicial - Filial " + FWGETCODFILIAL + " " + Time())
    DbSelectArea ('CDU')
    
    oCat83:setAlsTmp(cAliasTmp)
    oTabF04:setAlsTmp(cAliasTmp)
    
    cSlctCDU := '%CDU.CDU_CUSINI,	CDU.CDU_ICMINI,	CDU.CDU_QTDINI,	CDU.CDU_FICHA, CDU.CDU_PRODUT%'
    cAliasCDU	:=	GetNextAlias()
    
    BeginSql Alias cAliasCDU
        COLUMN CDU_PERIOD AS DATE
        SELECT
        %Exp:cSlctCDU%
        FROM
        %Table:CDU% CDU
        WHERE
        CDU.CDU_FILIAL=%xFilial:CDU% AND
        CDU.CDU_PERIOD = %Exp:cPer% AND
        (CDU.CDU_CUSINI > 0 OR CDU.CDU_QTDINI > 0 OR CDU.CDU_ICMINI > 0) AND
        CDU.%NotDel%
    EndSql
    
    DbSelectArea (cAliasCDU)
    (cAliasCDU)->(DbGoTop ())
    Do While !(cAliasCDU)->(Eof ())
        
        oCat83:setNrLanc(0)//Busca número de lançamento unívoco do saldo será zero
        oCat83:setPeriodo(dPeriodo)
        oCat83:setCodProd((cAliasCDU)->CDU_PRODUT)
        oCat83:setFilMov(cFilAnt)
        oCat83:setCdLanto('ZZ'+(cAliasCDU)->CDU_FICHA+ 'ZZ')
        oCat83:setVICMS((cAliasCDU)->CDU_ICMINI)
        oCat83:setVCusto((cAliasCDU)->CDU_CUSINI)
        oCat83:setQtde((cAliasCDU)->CDU_QTDINI)
        IF (cAliasCDU)->CDU_QTDINI > 0
        	oCat83:setUniICMS((cAliasCDU)->CDU_ICMINI/(cAliasCDU)->CDU_QTDINI)
        	oCat83:setUniCust((cAliasCDU)->CDU_CUSINI/(cAliasCDU)->CDU_QTDINI)
        Else
        	oCat83:setUniICMS((cAliasCDU)->CDU_ICMINI)
        	oCat83:setUniCust((cAliasCDU)->CDU_CUSINI)
        EndIf 	
        oCat83:setTabMov('CDU')
        
        AdFichaMov(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        
        (cAliasCDU)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCDU)
    (cAliasCDU)->(DbCloseArea ())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    ProcLogAtu("MENSAGEM","Fim Saldo Inicial - Filial " + FWGETCODFILIAL + " " + Time())
Return


Static Function QrySD2(lCount, dDtIni, dDtAte,lSerTransp)
    
    Local cCmpSD2       := ''
    Local cJoinCompl    := ''
    Local cFiltro	      := ''
    Local cChF2D2       := ''
    Local cChF1D2       := '' 
    Local cChFTD2       := '' 
    Local cChDLD2       := ''
    
    Local lIntTms			:= .F.
    Default lSerTransp	:= .F.
    
    IF lCount
        cCmpSD2 := '% COUNT(*) SD2COUNT %'
    Else
        cCmpSD2 := '%'
        cCmpSD2 +='SD2.D2_FILIAL, SD2.D2_DTDIGIT, SD2.D2_DOC,'  
        cCmpSD2 += 'SD2.'+SerieNfId("SD2",3,"D2_SERIE") + ' AS D2_SERIE,'
        cCmpSD2 +='SD2.D2_CLIENTE, SD2.D2_LOJA,SD2.D2_CLASFIS,'
        cCmpSD2 +='SD2.D2_COD, SD2.D2_ITEM, SD2.D2_QUANT, SD2.D2_EMISSAO, SD2.D2_VALIPI, SD2.D2_VALICM,'
        cCmpSD2 +='SD2.D2_BASEICM, SD2.D2_TOTAL,SD2.D2_TIPO, SD2.D2_CF, SD2.D2_CUSTO1, SD2.D2_CODLAN, '
        cCmpSD2 +='SD2.D2_PICM,SD2.D2_LOCAL,SD2.D2_UM, SD2.D2_SERIORI,SD2.D2_NFORI, SD2.D2_ITEMORI, SD2.D2_VALIMP5,SD2.D2_VALIMP6,SD2.D2_CF,SD2.D2_TOTAL,'
        cCmpSD2 +='SF2.F2_ESPECIE,SF2.F2_TIPO, SF2.F2_EST,'
        cCmpSD2 +='SFT.FT_CROUTSP,SFT.FT_VALICM,SFT.FT_BASEICM, '
        cCmpSD2 +='SF1.F1_EMISSAO,SF1.F1_ESPECIE,'
        cCmpSD2 +='CDL.CDL_NRDESP, CDL.CDL_NFEXP, CDL.CDL_SEREXP, CDL.CDL_EMIEXP, CDL.CDL_NATEXP,'
        cCmpSD2 +='SF4.F4_CODLEG,SF4.F4_CROUTSP, F4_SITTRIB'
        
        IF lSerTransp
            cCmpSD2	+= " ,SFT.FT_CLASFIS ,DT6.DT6_CLIREM,	DT6.DT6_LOJREM,	DT6.DT6_CLIDES,	DT6.DT6_LOJDES "
        EndIF
        
        cCmpSD2	+='%'
    EndIF
    
    //Join considerando a função SerieNfId
    cChF2D2 := '% SF2.' + SerieNfId("SF2",3,"F2_SERIE") + ' = SD2.' + SerieNfId("SD2",3,"D2_SERIE") + '%'
    cChF1D2 := '% SF1.' + SerieNfId("SF1",3,"F1_SERIE") + ' = SD2.' + SerieNfId("SD2",3,"D2_SERIORI") + '%'
    cChFTD2 := '% SFT.' + SerieNfId("SFT",3,"FT_SERIE") + ' = SD2.' + SerieNfId("SD2",3,"D2_SERIE")  + '%'
    cChDLD2 := '% CDL.' + SerieNfId("CDL",3,"CDL_SERIE")+ ' = SD2.' + SerieNfId("SD2",3,"D2_SERIE") + '%'

    
    IF lSerTransp
        //Integração com TMS para processamento das fichas 6G e 6H. Deverá obrigatoriamente ter os lançamentos na DT6
        cJoinCompl	:=	"INNER JOIN "+RetSqlName("DT6")+" DT6 ON(DT6_FILIAL='"+xFilial("DT6")+"' AND "
        cJoinCompl	+=  "DT6_FILDOC=SD2.D2_FILIAL AND "
        cJoinCompl	+=  "DT6_DOC=SD2.D2_DOC AND "
        cJoinCompl	+=  "DT6_SERIE= "+"SD2."+SerieNfId("SD2",3,"D2_SERIE") + ' AND '
        cJoinCompl	+=  "DT6.D_E_L_E_T_='') "
        
    Else
        cFiltro	:= "SD2.D2_CODLAN <> ' ' AND"
    EndIF
    
    cJoinCompl := "%" + cJoinCompl + "%"
    cFiltro 	:= "%" + cFiltro + "%"
    
    cAliasSD2	:=	GetNextAlias()
    
    BeginSql Alias cAliasSD2
        COLUMN D2_EMISSAO AS DATE
        COLUMN F1_EMISSAO AS DATE
        COLUMN CDL_EMIEXP AS DATE
        SELECT
        %Exp:cCmpSD2%
        FROM
        %Table:SD2% SD2
        JOIN %table:SF2% SF2 ON SF2.F2_FILIAL 			= %xFilial:SF2%
        AND SF2.F2_DOC 		= SD2.D2_DOC
        //AND %EXP:"SF2." + SerieNfId("SF2",3,"F2_SERIE")% = %EXP:"SD2." + SerieNfId("SD2",3,"D2_SERIE")%
        AND %EXP:cChF2D2%
        AND SF2.F2_CLIENTE	= SD2.D2_CLIENTE
        AND SF2.F2_LOJA 		= SD2.D2_LOJA
        AND SF2.F2_TIPO 		= SD2.D2_TIPO
        AND SF2.%NotDel%
        
        JOIN %table:SF4% SF4 ON SF4.F4_FILIAL 			= %xFilial:SF4% AND
        SF4.F4_CODIGO 		= SD2.D2_TES AND
        SF4.F4_CRDACUM  		= '1' AND
        SF4.%NotDel%
        
        LEFT JOIN %table:SF1% SF1 ON SF1.F1_FILIAL 	= %xFilial:SF1%
        AND SF1.F1_DOC	 	= SD2.D2_NFORI
        //AND %SerieNfId("SF1",3,"F1_SERIE")% = %SerieNfId("SD2",3,"D2_SERIORI")%
        AND %EXP:cChF1D2%
        AND SF1.F1_FORNECE 	= SD2.D2_CLIENTE
        AND SF1.F1_LOJA 	 	= SD2.D2_LOJA
        AND SF1.%NotDel%
        
        JOIN %table:SFT% SFT ON SFT.FT_FILIAL 	= %xFilial:SFT%
        AND SFT.FT_NFISCAL	 	= SD2.D2_DOC
        //AND %SerieNfId("SFT",3,"FT_SERIE")% = %SerieNfId("SD2",3,"D2_SERIE")%
        AND %EXP:cChFTD2%
        AND SFT.FT_CLIEFOR 	= SD2.D2_CLIENTE
        AND SFT.FT_LOJA 	 	= SD2.D2_LOJA
        AND SFT.FT_PRODUTO 	= SD2.D2_COD
        AND SFT.FT_ITEM 	 	= SD2.D2_ITEM
        AND SFT.%NotDel%
        
        LEFT JOIN %table:CDL% CDL ON CDL.CDL_FILIAL 	= %xFilial:CDL%
        AND CDL.CDL_DOC		= SD2.D2_DOC
        //AND %SerieNfId("CDL",3,"CDL_SERIE")% = %SerieNfId("SD2",3,"D2_SERIE")%
        AND %EXP:cChDLD2%
        AND CDL.CDL_CLIENT 	= SD2.D2_CLIENTE
        AND CDL.CDL_LOJA 	= SD2.D2_LOJA
        AND CDL.CDL_ITEMNF	= SD2.D2_ITEM
        AND CDL.%NotDel%
        %Exp:cJoinCompl%
        
        
        WHERE
        SD2.D2_FILIAL	=%xFilial:SD2% AND
        SD2.D2_EMISSAO 	>= %Exp:dTos(dDtIni)% AND SD2.D2_EMISSAO 	<= %Exp:dTos(dDtAte)% AND
        %Exp:cFiltro%
        SD2.%NotDel%
    EndSql
    
Return cAliasSD2


Static Function QrySD1(lCount, dDtIni, dDtAte )
    
    Local cAliasSD1 := ''
    Local cChF1D1   := ''
    Local cChF2D1   := ''
    Local cChFTD1   := ''
    Local cChD5D1   := ''

    
    
    DbSelectArea ('SD1')
    
    If lCount
        cCmpSD1 := '% COUNT(*) SD1COUNT %'
    Else
        
        cCmpSD1	:= '%'
        cCmpSD1	+='SD1.D1_FILIAL, SD1.D1_DTDIGIT, SD1.D1_DOC, SD1.' + SerieNfId("SD1",3,"D1_SERIE") + ' AS D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA,'
        cCmpSD1	+='SD1.D1_COD, SD1.D1_ITEM, SD1.D1_QUANT, SD1.D1_EMISSAO, SD1.D1_VALIPI, SD1.D1_VALICM,'
        cCmpSD1	+='SD1.D1_BASEICM, SD1.D1_TOTAL,SD1.D1_TIPO, SD1.D1_CF, SD1.D1_CUSTO, SD1.D1_CODLAN,'
        cCmpSD1	+='SD1.D1_PICM,SD1.D1_LOCAL,SD1.D1_UM, SD1.D1_NFORI,SD1.D1_SERIORI, SD1.D1_ITEMORI,SD1.D1_VALIMP5,SD1.D1_VALIMP6,SD1.D1_CF,  '
        cCmpSD1	+='SF1.F1_ESPECIE, SF1.F1_TIPO, SF1.F1_EST,'
        cCmpSD1   +='SFT.FT_VALICM,'
        cCmpSD1	+='SF2.F2_EMISSAO,F2_ESPECIE,'
        cCmpSD1	+='CD5.CD5_NDI,'
        cCmpSD1	+='SF4.F4_CODLEG'
        cCmpSD1	+= '%'
        
    EndIF

    
      //Join considerando a função SerieNfId
    cChF1D1 := '% SF1.' + SerieNfId("SF1",3,"F1_SERIE") + ' = SD1.' + SerieNfId("SD1",3,"D1_SERIE") + '%'
    cChF2D1 := '% SF2.' + SerieNfId("SF2",3,"F2_SERIE") + ' = SD1.' + SerieNfId("SD1",3,"D1_SERIORI") + '%'
    cChFTD1 := '% SFT.' + SerieNfId("SFT",3,"FT_SERIE") + ' = SD1.' + SerieNfId("SD1",3,"D1_SERIE")  + '%'
    cChD5D1 := '% CD5.' + SerieNfId("CD5",3,"CD5_SERIE")+ ' = SD1.' + SerieNfId("SD1",3,"D1_SERIE") + '%'

    
    cAliasSD1	:=	GetNextAlias()
    
    BeginSql Alias cAliasSD1
        COLUMN D1_DTDIGIT AS DATE
        COLUMN D1_EMISSAO AS DATE
        COLUMN F2_EMISSAO AS DATE
        SELECT
        %Exp:cCmpSD1%
        FROM
        %Table:SD1% SD1
        JOIN %table:SF1% SF1 ON SF1.F1_FILIAL 			= %xFilial:SF1%
        AND SF1.F1_DOC 		= SD1.D1_DOC
        //AND SF1.F1_SERIE 		= SD1.D1_SERIE
        AND %EXP:cChF1D1%
        AND SF1.F1_FORNECE 	= SD1.D1_FORNECE
        AND SF1.F1_LOJA 		= SD1.D1_LOJA
        AND SF1.F1_TIPO 		= SD1.D1_TIPO
        AND SF1.%NotDel%
        
        JOIN %table:SF4% SF4 ON SF4.F4_FILIAL 			= %xFilial:SF4% AND
        SF4.F4_CODIGO 		= SD1.D1_TES AND
        SF4.F4_CRDACUM  		= '1' AND
        SF4.%NotDel%
        
        LEFT JOIN %table:SF2% SF2 ON SF2.F2_FILIAL 	= %xFilial:SF2%
        AND SF2.F2_DOC 		= SD1.D1_NFORI
        //AND SF2.F2_SERIE 		= SD1.D1_SERIORI
        AND %EXP:cChF2D1%
        AND SF2.F2_CLIENTE 	= SD1.D1_FORNECE
        AND SF2.F2_LOJA 		= SD1.D1_LOJA
        AND SF2.%NotDel%
        LEFT  JOIN %table:SFT% SFT ON SFT.FT_FILIAL   = %xFilial:SFT%
        AND SFT.FT_NFISCAL      = SD1.D1_DOC
        //AND SFT.FT_SERIE        = SD1.D1_SERIE
        AND %EXP:cChFTD1%
        AND SFT.FT_CLIEFOR      = SD1.D1_FORNECE
        AND SFT.FT_LOJA         = SD1.D1_LOJA
        AND SFT.FT_PRODUTO      = SD1.D1_COD
        AND SFT.FT_ITEM         = SD1.D1_ITEM
        AND SFT.%NotDel%
        LEFT JOIN %table:CD5% CD5 ON CD5.CD5_FILIAL 	= %xFilial:CD5%
        AND CD5.CD5_DOC		= SD1.D1_DOC
        //AND CD5.CD5_SERIE 	= SD1.D1_SERIE
        AND %EXP:cChD5D1%
        AND CD5.CD5_FORNEC 	= SD1.D1_FORNECE
        AND CD5.CD5_LOJA 		= SD1.D1_LOJA
        AND CD5.CD5_ITEM 		= SD1.D1_ITEM
        AND CD5.%NotDel%
        
        WHERE
        SD1.D1_FILIAL	=%xFilial:SD1% AND
        SD1.D1_DTDIGIT 	>= %Exp:dTos(dDtIni)% AND SD1.D1_DTDIGIT 	<= %Exp:dTos(dDtAte)% AND
        SD1.D1_CODLAN <> ' ' AND
        SD1.%NotDel%
    EndSql
    
Return cAliasSD1


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSD1()
Função que irá buscar da tabela SD1 movimentações para a gravação das fichas
considerando o código de lançamento como critério para ser processada, irá preencher
objeto de estrutura da cat83 e irá chamar as funções para gravação das
respectivas fichas.

@param dDtIni,Date,Date inicial do Processamento
@param dDtAte,Date,Date Final do Processamento

@author Erick G. Dias
@since 09/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcSD1(dDtIni, dDtAte,cAliasTmp, oProcess)
    
    Local oCat83		:= CAT83ESTR():New()
    Local oTabCLR		:= TABCLR():New()
    Local oTabCLP		:= TABCLP():New()
    Local oTabCLQ		:= TABCLQ():New()
    Local oTabF04		:= TABF04():New()
    Local cAliasSD1		:= ''
    Local cIdNf     	:= ''
    Local cIdPart		:= ''
    Local cEnqLeq		:= ''
    Local lIntEasy		:= GetNewPar("MV_EASY","N") == "S"
    Local aAverage		:= {}
    Local nProc			:= 0
    Local nTot			:= 0
    Local cCodEner		:= PADR(aParSX6[MV_ENECT83],TAMSX3("B1_COD")[1])
    Local cCodCom		:= PADR(aParSX6[MV_COMCT83],TAMSX3("B1_COD")[1])
    Local cCodFhc1B  	:= PADR(aParSX6[MV_1BCT83],TAMSX3("B1_COD")[1]) 
    Local cCodPart		:= ''
    Local lDev			:= .F.
    Local nQuant     	:= 0
    
    nTot				:=  QtdeSd1(dDtIni, dDtAte)
    
    If !lAutomato
    	oProcess:Set2Progress(nTot)
    EndIf
    
    ProcLogAtu("MENSAGEM","Início Documentos de entrada - Filial " + FWGETCODFILIAL + " " + Time())
    
    oTabCLQ:setAlsTmp(cAliasTmp)
    oTabCLP:setAlsTmp(cAliasTmp)
    oTabF04:setAlsTmp(cAliasTmp)
    
    cAliasSd1	:= QrySD1(.F., dDtIni, dDtAte )
    
    DbSelectArea (cAliasSD1)
    (cAliasSD1)->(DbGoTop ())
    oCat83:setAlsTmp(cAliasTmp) //Passa alias da tabela principal para estrutura da cat
    Do While !(cAliasSD1)->(Eof ())
        nProc++
        
        If !lAutomato
        	oProcess:Inc2Progress('Processando Documento Fiscal de Aquisição - Processando ' +Alltrim(STR(nProc)) + ' de ' +Alltrim(STR(nTot) ))
        EndIf
        
        lDev       := (cAliasSD1)->D1_TIPO $ 'DB'
        
        //Se for nota fiscal de complemento de ICMS, levo quantidade 1, pois na D1_QUANT fica gravado zero para essas notas fiscais
        nQuant     := IIF((cAliasSD1)->F1_TIPO=='I', 1, (cAliasSD1)->D1_QUANT)
        
        //Adiciona nota fiscal e retorna ID
        cIdNf	:= AddNota(oTabCLQ, ;
            (cAliasSD1)->D1_DTDIGIT, ;
            (cAliasSD1)->F1_ESPECIE, ;
            (cAliasSD1)->D1_CF, ;
            IIF(lDev, 'G', 'E'), ; //Saida /Entrada*/
            (cAliasSD1)->D1_SERIE, ;
            (cAliasSD1)->D1_DOC, ;
            (cAliasSD1)->D1_ITEM,;
            (cAliasSD1)->F1_TIPO,;
            (cAliasSD1)->F2_EMISSAO,;
            (cAliasSD1)->F2_ESPECIE,;
            (cAliasSD1)->D1_SERIORI,;
            (cAliasSD1)->D1_NFORI,;
            (cAliasSD1)->D1_ITEMORI)
        
        
        cCodPart	:= Alltrim(Iif (lDev,'SA1' ,'SA2')+ (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA)
        //Adiciona participante e retorna ID
        
        
        cIdPart := AddParti(oTabCLP,;
            dDtIni,;
            cFilAnt,;
            (cAliasSD1)->D1_FORNECE,;
            (cAliasSD1)->D1_LOJA,;
            Iif((cAliasSD1)->D1_TIPO $ 'DB','2' ,'1'),(cAliasSD1)->F1_EST =='EX' ) // Devolução/beneficiamento é 2-Cliente SA1, se não é 1-Fornecedor SA2
        
        
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca número de lançamento unívoco
        oCat83:setPeriodo(dDtIni)
        
        IF  SubStr((cAliasSD1)->D1_CODLAN,1,2)  == '13' .OR. SubStr((cAliasSD1)->D1_CODLAN,3,2)  == '13'
            //Se o destino for ficha 1C Energia Elétrica irá mandar o produto genérico de energia.
            oCat83:setCodProd(cCodEner) //Produto Destino
            oCat83:setInsumo(cCodEner)
        ElseIF SubStr((cAliasSD1)->D1_CODLAN,1,2)   == '14' .OR. SubStr((cAliasSD1)->D1_CODLAN,3,2)   == '14' //Entrada de serviço de COmunicação
            //Se o destino for ficha 1D Serviço Comunicação então irá utilizar códihgo genérico
            oCat83:setCodProd(cCodCom) //Produto Destino
            oCat83:setInsumo(cCodCom)
        ElseIF SubStr((cAliasSD1)->D1_CODLAN,1,2)   == '12' .OR. SubStr((cAliasSD1)->D1_CODLAN,3,2)   == '12' //Controle de Valores Agregados na Industrialização por outro Estabelecimento
            //Se o destino for ficha 1B - Controle de Valores Agregados na Industrialização por outro Estabelecimento
            oCat83:setCodProd(cCodFhc1B) //Produto Destino
            oCat83:setInsumo(cCodFhc1B)    
        Else
            oCat83:setCodProd((cAliasSD1)->D1_COD)
            oCat83:setInsumo((cAliasSD1)->D1_COD)
        EndIF
        
        cEnqLeq := RetEnqLeg((cAliasSD1)->F4_CODLEG, (cAliasSD1)->F1_EST)
            
        oCat83:setIdNf(cIdNf)
        oCat83:setCodPart(cIdPart)
        oCat83:setFilMov(cFilAnt)
        oCat83:setArmazem((cAliasSD1)->D1_LOCAL)
        oCat83:setCdLanto((cAliasSD1)->D1_CODLAN)
        oCat83:setVICMS((cAliasSD1)->FT_VALICM)
        oCat83:setVCusto(IIF((cAliasSD1)->F1_TIPO=='I',0,(cAliasSD1)->D1_CUSTO))
        oCat83:setUniICMS((cAliasSD1)->FT_VALICM/nQuant)
        oCat83:setUniCust((cAliasSD1)->D1_CUSTO/nQuant)
        oCat83:setVIPI((cAliasSD1)->D1_VALIPI)
        oCat83:setQtde(nQuant)
        oCat83:setAliq((cAliasSD1)->D1_PICM)
        oCat83:setUnidade((cAliasSD1)->D1_UM)
        oCat83:setEnqLeg(cEnqLeq)
        oCat83:setTabMov('SD1')
        oCat83:setTpDoc( ModCodCHv( amodnot((cAliasSD1)->F1_ESPECIE) ) )
        oCat83:setVOutros((cAliasSD1)->(D1_VALIMP5+D1_VALIMP6)) // outros impostos PIS COFINS
        
        // caso retorno de beneficiamento deverá enviar número da nota de remessa.
        IF (cAliasSD1)->F1_TIPO == 'B'
            oCat83:setHist((cAliasSD1)->D1_NFORI)
        EndIF
        
        //Devolucao dentro do periodo
        If (cAliasSD1)->F1_TIPO 	== 'D' .And. (cAliasSD1)->F2_EMISSAO >= dDtIni .And. (cAliasSD1)->F2_EMISSAO <= dDtAte
            oCat83:setTpMov('G') //Indica que trata-se de uma devolução de Venda
        ElseIf (cAliasSD1)->F1_TIPO   == 'D' //Devolução fora do periodo
            oCat83:setTpMov('Z')
        EndIF
        
        
        //Documento de importação
        IF SubStr((cAliasSD1)->D1_CF,1,1) == '3'
            
            //Verifica integração com SIGAEIC.
            IF lIntEasy
                aAverage := AvGetImpSped(xFilial ("SD1"), (cAliasSD1)->D1_DOC, (cAliasSD1)->D1_SERIE, (cAliasSD1)->D1_FORNECE, (cAliasSD1)->D1_LOJA)
                IF Len(aAverage) > 0
                    oCat83:setNDIDSI(aAverage[1,2,1,2,1])
                EndIF
            Else
                //Verifica se número da DI está preenchido, caso importação.
                If !Empty(AllTrim((cAliasSD1)->CD5_NDI))
                    oCat83:setNDIDSI((cAliasSD1)->CD5_NDI)
                EndIF
            Endif
            
        EndIF
        
        //Processa a ficha
        AdFichaMov(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        
        (cAliasSD1)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSD1)
    (cAliasSD1)->(DbCloseArea ())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabCLP)
    oTabCLP:= nil
    
    FreeObj(oTabCLQ)
    oTabCLQ:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    ProcLogAtu("MENSAGEM","Fim Documentos de entrada - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSD2()
Função que irá buscar da tabela SD2 movimentações para a gravação das fichas
considerando o código de lançamento como critério para ser processada, irá preencher
objeto de estrutura da cat83 e irá chamar as funções para gravação das
respectivas fichas.

@param dDtIni,Date,Date inicial do Processamento
@param dDtAte,Date,Date Final do Processamento

@author Erick G. Dias
@since 10/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcSD2(dDtIni, dDtAte,cAliasTmp,oProcess)
    
    Local oCat83		:= CAT83ESTR():New()
    Local oTabCLR		:= TABCLR():New()
    Local oTabCLP		:= TABCLP():New()
    Local oTabCLQ		:= TABCLQ():New()
    Local oTabCLW		:=	TABCLW():New()
    Local oTabF04		:=	TABF04():New()
    Local cAliasSD2	:= ''
    Local cIdNf		:= ''
    Local cIdPart		:= ''
    Local cEnqLeq		:= ''
    Local lEEC			:= GetNewPar("MV_EECFAT",.F.)
    Local aEEC			:= {}
    Local lExpCopInd	:= .F. //Exportação Comprovada Indireta, deverá gerar informações na ficha 5H
    Local nProc		:= 0
    Local nTot			:= 0
    Local cCodPart	:= ''
    Local lDev			:= .F.
    Local cCodEner	:= PADR(aParSX6[MV_ENECT83],TAMSX3("B1_COD")[1])
    Local cCodCom		:= PADR(aParSX6[MV_COMCT83],TAMSX3("B1_COD")[1])
    Local cCodFhc1B  := PADR(aParSX6[MV_1BCT83],TAMSX3("B1_COD")[1])
    Local lTms			:= IntTms()
    
    ProcLogAtu("MENSAGEM","Início Documentos de Saídas - Filial " + FWGETCODFILIAL + " " + Time())
    
    oTabCLQ:setAlsTmp(cAliasTmp)
    oTabCLP:setAlsTmp(cAliasTmp)
    oTabF04:setAlsTmp(cAliasTmp)
    nTot	:= QtdeSd2(dDtIni, dDtAte, .F.)
    
    If !lAutomato
    	oProcess:Set2Progress(nTot)
    	oProcess:Inc1Progress(FWGETCODFILIAL + ' - Buscando movimentações SD2')
    	oProcess:Inc2Progress(FWGETCODFILIAL + ' - Buscando movimentações SD2')
    EndIf
    
    cAliasSD2	:=	QrySD2(.F., dDtIni, dDtAte, .F. )
    
    DbSelectArea (cAliasSD2)
    (cAliasSD2)->(DbGoTop ())
    oCat83:setAlsTmp(cAliasTmp) //Passa alias da tabela principal para estrutura da cat
    Do While !(cAliasSD2)->(Eof ())
        nProc++
        
        If !lAutomato
        	oProcess:Inc2Progress('Processando Documento Fiscal de Saída - Processando ' +Alltrim(STR(nProc)) + ' de ' + alltrim(STR(nTot)) )
        EndIf
        
        //Adiciona nota fiscal e retorna ID
        lDev       := (cAliasSD2)->D2_TIPO $ 'DB'
        
        cIdNf	:= AddNota(oTabCLQ, ;
            (cAliasSD2)->D2_EMISSAO, ;
            (cAliasSD2)->F2_ESPECIE, ;
            (cAliasSD2)->D2_CF, ;
            IIF(lDev, 'F', 'S'), ;
            (cAliasSD2)->D2_SERIE, ;
            (cAliasSD2)->D2_DOC, ;
            (cAliasSD2)->D2_ITEM,;
            (cAliasSD2)->F2_TIPO,;
            (cAliasSD2)->F1_EMISSAO,;
            (cAliasSD2)->F1_ESPECIE,;
            (cAliasSD2)->D2_SERIORI,;
            (cAliasSD2)->D2_NFORI,;
            (cAliasSD2)->D2_ITEMORI)
        
        cCodPart	:= Alltrim(Iif (lDev,'SA2' ,'SA1')+ (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA)
        
        //Adiciona participante e retorna ID
        cIdPart	:= AddParti(oTabCLP,;
            dDtIni,;
            cFilAnt,;
            (cAliasSD2)->D2_CLIENTE,;
            (cAliasSD2)->D2_LOJA,;
            Iif((cAliasSD2)->D2_TIPO $ 'DB','1' ,'2'), (cAliasSD2)->F2_EST =='EX' ) // Devolução/beneficiamento é 2-Cliente SA1, se não é 1-Fornecedor SA2
               
        cEnqLeq := RetEnqLeg((cAliasSD2)->F4_CODLEG, (cAliasSD2)->F2_EST) 
          
        //Popula objeto oCat83 para que possa ser processada a Ficha
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca sequencial unívoco
        oCat83:setPeriodo(dDtIni)
        oCat83:setCodProd((cAliasSD2)->D2_COD)
        oCat83:setInsumo((cAliasSD2)->D2_COD)
        oCat83:setIdNf(cIdNf)
        oCat83:setCodPart(cIdPart)
        oCat83:setFilMov(cFilAnt)
        oCat83:setArmazem((cAliasSD2)->D2_LOCAL)
        oCat83:setCdLanto((cAliasSD2)->D2_CODLAN)
        oCat83:setVIPI((cAliasSD2)->D2_VALIPI)
        oCat83:setQtde((cAliasSD2)->D2_QUANT)
        oCat83:setAliq((cAliasSD2)->D2_PICM)
        oCat83:setUnidade((cAliasSD2)->D2_UM)
        oCat83:setEnqLeg(cEnqLeq)
        oCat83:setTabMov('SD2')
        oCat83:setTpDoc( ModCodCHv( amodnot((cAliasSD2)->F2_ESPECIE) ) )
        oCat83:setVOutros((cAliasSD2)->(D2_VALIMP5+D2_VALIMP6))
        oCat83:setVSaida((cAliasSD2)->D2_TOTAL)
        
        oCat83:setBasItem((cAliasSD2)->FT_BASEICM)
        oCat83:setIcmsNGE((cAliasSD2)->FT_VALICM) //ICMS debitado
        
        If (cAliasSD2)->F2_TIPO 	== 'D'
            oCat83:setTpMov('F') //Indica que trata-se de uma devolução de Compra
            oCat83:setVICMS((cAliasSD2)->D2_VALICM)
            oCat83:setVCusto((cAliasSD2)->D2_CUSTO1)
        EndIF

		 IF  SubStr((cAliasSD2)->D2_CODLAN,1,2)  == '52' 
		 	oCat83:setVICMS((cAliasSD2)->FT_VALICM) 
			oCat83:setVCusto((cAliasSD2)->D2_CUSTO1)
		EndIF
	        
        If (cAliasSD2)->FT_CROUTSP > 0
            oCat83:setPerOuto((cAliasSD2)->F4_CROUTSP) //Percentual do Crédito Outorgado
        EndIF
        
        IF  SubStr((cAliasSD2)->D2_CODLAN,1,2)  == '13' .OR. SubStr((cAliasSD2)->D2_CODLAN,3,2)  == '13'
            //Se o destino for ficha 1C Energia Elétrica irá mandar o produto genérico de energia.
            oCat83:setCodProd(cCodEner) //Produto Destino
            oCat83:setInsumo(cCodEner)
        ElseIF SubStr((cAliasSD2)->D2_CODLAN,1,2)   == '14' .OR. SubStr((cAliasSD2)->D2_CODLAN,3,2)   == '14' //Entrada de serviço de COmunicação
            //Se o destino for ficha 1D Serviço Comunicação então irá utilizar códihgo genérico
            oCat83:setCodProd(cCodCom) //Produto Destino
            oCat83:setInsumo(cCodCom)
         ElseIF SubStr((cAliasSD2)->D2_CODLAN,1,2)   == '12' .OR. SubStr((cAliasSD2)->D2_CODLAN,3,2)   == '12' //Controle de Valores Agregados na Industrialização por outro Estabelecimento 
            //Se o destino for ficha 1B - Controle de Valores Agregados na Industrialização por outro Estabelecimento
            oCat83:setCodProd(cCodFhc1B) //Produto Destino
            oCat83:setInsumo(cCodFhc1B)     
        Else
            oCat83:setCodProd((cAliasSD2)->D2_COD)
            oCat83:setInsumo((cAliasSD2)->D2_COD)
        EndIF
        //Verifica CFOP de exportação indireta ou CFOP de exportação direta
        lExpCopInd	 := .F.
        IF SUBSTR((cAliasSD2)->D2_CF,2,3) $ '501/502' .OR. SUBSTR((cAliasSD2)->D2_CF,1,1) == '7'
            
            IF lEEC
                //Irá buscar informações de exportação através da integração com EEC.
                aEEC	:= FisGetEEC((cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA)
                If Len(aEEC) > 0
                    oCat83:setDespach(IIF(!Empty(AllTrim(aEEC[2])),aEEC[2],aEEC[3])) // Traz número da declaração de exportação para despacho de exportação
                EndIF
                
                //Exportação Indireta, deverá gerar ficha 5H
                IF aEEC[4]=="1"
                    lExpCopInd	:= .T.
                EndIF
                
            Else
                //Processar informações de exportação através das tabelas de complemento de exportação.
                oCat83:setDespach((cAliasSD2)->CDL_NRDESP)
                
                //Exportação Indireta, deverá gerar ficha 5H
                oCat83:SetExpInd('NAO')
                IF (cAliasSD2)->CDL_NATEXP == '1'
                    lExpCopInd	:= .T.
                    oCat83:SetExpInd('SIM')
                EndIF
                
            EndIF
            
            oCat83:setComprov('2')
            If lExpCopInd .OR. !Empty(oCat83:GetDespach())//indireto comprovado
                oCat83:setComprov('1')
            EndIf
            
        EndIF
        
        //----------------------------------
        //Processa a ficha
        //----------------------------------
        AdFichaMov(@oCat83,oTabCLR,oTabF04)
        
        //Processa ficha 5H
        IF lExpCopInd
            
            //Se for exportação comprovada e for ficha 6C deverá gerar ficha 5H
            //A ficha 5H é gerada depois da 6C pois é necessário saber qual número de ordem foi
            //utilizado na 6C para poder utilizar o mesmo número na 5H.
            If oCat83:getFicha() == '63' .AND. oCat83:getComprov() == '1'
                If lEEC
                    //Gerar ficha 5H através da integração com EEC
                    AddFicha5H(oTabCLW, dDtIni, (cAliasSD2)->D2_COD, oCat83:getNrLanc(), (cAliasSD2)->D2_DOC,;
                        (cAliasSD2)->D2_SERIE, aEEC[5], aEEC[6], aEEC[7], oCat83:getDespach())
                Else
                    //Gerar ficha 5H através da tabela CDL do complemento de notas fiscais.
                    AddFicha5H(oTabCLW, dDtIni, (cAliasSD2)->D2_COD, oCat83:getNrLanc(), (cAliasSD2)->D2_DOC,;
                        (cAliasSD2)->D2_SERIE,  (cAliasSD2)->CDL_EMIEXP, (cAliasSD2)->CDL_NFEXP, ;
                        (cAliasSD2)->CDL_SEREXP, oCat83:getDespach())
                EndIF
            EndIF
        EndIF
        
        oCat83:Clear()
        
        (cAliasSD2)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSD2)
    (cAliasSD2)->(DbCloseArea ())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabCLP)
    oTabCLP:= nil
    
    FreeObj(oTabCLQ)
    oTabCLQ:= nil
    
    FreeObj(oTabCLW)
    oTabCLW:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    ProcLogAtu("MENSAGEM","Fim Documentos de Saídas - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSD2()
Função que irá buscar da tabela SD2 movimentações para a gravação das fichas
considerando o código de lançamento como critério para ser processada, irá preencher
objeto de estrutura da cat83 e irá chamar as funções para gravação das
respectivas fichas.

@param dDtIni,Date,Date inicial do Processamento
@param dDtAte,Date,Date Final do Processamento

@author Erick G. Dias
@since 10/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcDT6(dDtIni, dDtAte,cAliasTmp,oProcess, cFicha)
    
    Local oCat83		:= CAT83ESTR():New()
    Local oTabCLR		:= TABCLR():New()
    Local oTabCLP		:= TABCLP():New()
    Local oTabCLQ		:= TABCLQ():New()
    Local oTabCLW		:=	TABCLW():New()
    Local oTabF04		:=	TABF04():New()
    Local cAliasSD2	:= ''
    Local cIdNf		:= ''
    Local cEnqLeq		:= ''
    Local cCodTomad	:= ''
    Local cCodDest	:= ''
    Local cCodReme	:= ''
    Local cIdTomad	:= ''
    Local cIdDest		:= ''
    Local cIdReme		:= ''
    Local cUfOri		:= ''
    Local cUfDest		:= ''
    Local nProc		:= 0
    Local nTot			:= 0
    
    ProcLogAtu("MENSAGEM","Início Documentos Serviço Transportes - Filial " + FWGETCODFILIAL + " " + Time())
    
    oTabCLQ:setAlsTmp(cAliasTmp)
    oTabCLP:setAlsTmp(cAliasTmp)
    oTabF04:setAlsTmp(cAliasTmp)
    nTot	:= QtdeSd2(dDtIni, dDtAte, .T.)

	If !lAutomato
    	oProcess:Set2Progress(nTot)
    	oProcess:Inc1Progress(FWGETCODFILIAL + ' - Buscando movimentações DT6')
    	oProcess:Inc2Progress(FWGETCODFILIAL + ' - Buscando movimentações DT6')
    EndIf
    
    cAliasSD2	:=	QrySD2(.F., dDtIni, dDtAte , .T.)
    
    DbSelectArea (cAliasSD2)
    (cAliasSD2)->(DbGoTop ())
    oCat83:setAlsTmp(cAliasTmp) //Passa alias da tabela principal para estrutura da cat
    Do While !(cAliasSD2)->(Eof ())
        nProc++
        
        If !lAutomato
        	oProcess:Inc2Progress('Processando Documentos Serviço Transportes- Processando ' +Alltrim(STR(nProc)) + ' de ' + alltrim(STR(nTot)) )
        EndIf
        //Adiciona nota fiscal e retorna ID
        
        cUfOri		:= ''
        cUfDest	:= ''
        
        cIdNf	:= AddNota(oTabCLQ, ;
            (cAliasSD2)->D2_EMISSAO, ;
            (cAliasSD2)->F2_ESPECIE, ;
            (cAliasSD2)->D2_CF, ;
            'S', ; //Saida /Entrada
        (cAliasSD2)->D2_SERIE, ;
            (cAliasSD2)->D2_DOC, ;
            (cAliasSD2)->D2_ITEM,;
            (cAliasSD2)->F2_TIPO,;
            (cAliasSD2)->F1_EMISSAO,;
            (cAliasSD2)->F1_ESPECIE,;
            (cAliasSD2)->D2_SERIORI,;
            (cAliasSD2)->D2_NFORI,;
            (cAliasSD2)->D2_ITEMORI)
        
        cCodTomad	:= Alltrim( 'SA1'+ (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA)
        cCodDest	:= Alltrim( 'SA1'+ (cAliasSD2)->DT6_CLIDES + (cAliasSD2)->DT6_LOJDES)
        cCodReme	:= Alltrim( 'SA1'+ (cAliasSD2)->DT6_CLIREM + (cAliasSD2)->DT6_LOJREM)
        
        //Adiciona participante e retorna ID
        cIdTomad	:= AddParti(oTabCLP,;
            dDtIni,;
            cFilAnt,;
            (cAliasSD2)->D2_CLIENTE,;
            (cAliasSD2)->D2_LOJA,;
            '2')
        
        //Adiciona participante e retorna ID
        cIdDest	:= AddParti(oTabCLP,;
            dDtIni,;
            cFilAnt,;
            (cAliasSD2)->DT6_CLIDES,;
            (cAliasSD2)->DT6_LOJDES,;
            '2')
        
        //Adiciona participante e retorna ID
        cIdReme	:= AddParti(oTabCLP,;
            dDtIni,;
            cFilAnt,;
            (cAliasSD2)->DT6_CLIREM,;
            (cAliasSD2)->DT6_LOJREM,;
            '2')
        
        cEnqLeq := RetEnqLeg((cAliasSD2)->F4_CODLEG, (cAliasSD2)->F2_EST)
          
        //Remetende
        IF SA1->(MsSeek (xFilial ("SA1")+(cAliasSD2)->DT6_CLIREM+(cAliasSD2)->DT6_LOJREM))
            cUfOri	:=	SA1->A1_EST
        EndIF
        
        //Destinatario
        IF SA1->(MsSeek (xFilial ("SA1")+(cAliasSD2)->DT6_CLIDES+(cAliasSD2)->DT6_LOJDES))
            cUfDest	:= SA1->A1_EST
        EndIF
        
        //Popula objeto oCat83 para que possa ser processada a Ficha
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca sequencial unívoco
        oCat83:setPeriodo(dDtIni)
        oCat83:setCodProd((cAliasSD2)->D2_COD)
        oCat83:setInsumo((cAliasSD2)->D2_COD)
        oCat83:setIdNf(cIdNf)
        oCat83:setCodPart(cCodTomad)
        oCat83:setCodRem(cCodReme)
        oCat83:SetCodDes(cCodDest)
        oCat83:setFilMov(cFilAnt)
        oCat83:setArmazem((cAliasSD2)->D2_LOCAL)
        oCat83:setVIPI((cAliasSD2)->D2_VALIPI)
        oCat83:setQtde((cAliasSD2)->D2_QUANT)
        oCat83:setAliq((cAliasSD2)->D2_PICM)
        oCat83:setUnidade((cAliasSD2)->D2_UM)
        oCat83:setEnqLeg(cEnqLeq)
        oCat83:setTabMov('DT6')
        oCat83:setTpDoc( ModCodCHv( amodnot((cAliasSD2)->F2_ESPECIE) ) )
        oCat83:setUfIni(cUfOri)
        oCat83:setUfDest(cUfDest)
        
        IF cFicha == '6G'
            //Ficha 6G
            oCat83:setCdLanto('7067XX') //Código de lançamento para inclusão da informação na ficha 6G
            IF SubStr(Padl((cAliasSD2)->FT_CLASFIS,3),2,2) $ '10/51/70'
                //Com ST
                oCat83:setTotGer((cAliasSD2)->D2_TOTAL) 		//- VL PRESTAÇÂO
                oCat83:setIcmsST((cAliasSD2)->D2_VALICM) 		//- icms contribuinte st
                oCat83:setOutST((cAliasSD2)->FT_CROUTSP)	 	//- credito outorgado  com st
            Else
                //Sem ST
                oCat83:setTotNGe((cAliasSD2)->D2_TOTAL)  		//- vl prestação nao geradora
                oCat83:setIcmsNGE((cAliasSD2)->D2_VALICM) 	//- icms debitado pelo prestador
                oCat83:setCrdOuto((cAliasSD2)->FT_CROUTSP) 	//- credito outorgado  sem st
            EndIF
        Elseif cFicha == '6H'
            //Ficha 6H
            oCat83:setCdLanto('7068XX') //Código de lançamento para inclusão da informação na ficha 6H
            oCat83:setVSaida((cAliasSD2)->D2_TOTAL)
            oCat83:setIcmsNGE((cAliasSD2)->D2_VALICM) //ICMS debitado
        EndIF
        
        //----------------------------------
        //Processa a ficha
        //----------------------------------
        AdFichaMov(@oCat83,oTabCLR,oTabF04)
        
        oCat83:Clear()
        
        (cAliasSD2)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSD2)
    (cAliasSD2)->(DbCloseArea ())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabCLP)
    oTabCLP:= nil
    
    FreeObj(oTabCLQ)
    oTabCLQ:= nil
    
    FreeObj(oTabCLW)
    oTabCLW:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    ProcLogAtu("MENSAGEM","Fim Documentos Serviço Transportes - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdeSd3()
Função que irá retornar a quantidade de linhas da SD3 que serao processadas

@author Erick Dias
@since 10/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QtdeSd3(dDtIni, dDtAte)
    Local cAliasSD3	:= ''
    Local nQtde 	:= 0
    
    cAliasSD3	:= QrySD3(.T., dDtIni, dDtAte)
    
    Do While !(cAliasSD3)->(Eof ())
        
        nQtde	:= (cAliasSD3)->SD3COUNT
        
        (cAliasSD3)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSD3)
    (cAliasSD3)->(DbCloseArea ())
    
Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} QtdeSD2()
Função que irá retornar a quantidade de linhas da SD3 que serao processadas

@author Erick Dias
@since 10/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QtdeSD2(dDtIni, dDtAte, lSerTransp)
    Local cAliasSD2	:= ''
    Local nQtde 	:= 0
    DEFAULT lSerTransp	:= .F.
    
    cAliasSD2	:= QrySD2(.T., dDtIni, dDtAte, lSerTransp)
    
    Do While !(cAliasSD2)->(Eof ())
        
        nQtde	:= (cAliasSD2)->SD2COUNT
        
        (cAliasSD2)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSD2)
    (cAliasSD2)->(DbCloseArea ())
    
Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} QtdeSBC()
Função que irá retornar a quantidade de linhas da SD3 que serao processadas

@author Erick Dias
@since 10/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QtdeSBC(dDtIni, dDtAte)
    Local cAliasSBC	:= ''
    Local nQtde 	:= 0
    
    cAliasSBC	:=QrySBC(.T., dDtIni, dDtAte)
    
    Do While !(cAliasSBC)->(Eof ())
        
        nQtde	:= (cAliasSBC)->SBCCOUNT
        
        (cAliasSBC)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSBC)
    (cAliasSBC)->(DbCloseArea ())
    
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdeSd1()
Função que irá retornar a quantidade de linhas da SD3 que serao processadas

@author Erick Dias
@since 10/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QtdeSd1(dDtIni, dDtAte)
    Local cAliasSD1	:= ''
    Local nQtde 	:= 0
    
    cAliasSD1	:= QrySD1(.T., dDtIni, dDtAte)
    
    Do While !(cAliasSD1)->(Eof ())
        
        nQtde	:= (cAliasSD1)->SD1COUNT
        
        (cAliasSD1)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSD1)
    (cAliasSD1)->(DbCloseArea ())
    
Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} QrySD3()
Função que monta a query para processamento da SD3

@author Erick Dias
@since 10/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QrySD3(lCOUNT, dDtIni, dDtAte)
    
    Local cCmpSD3	:= ''
    Local cOrder	:= '%%'
    
    If lCOUNT
        cCmpSD3 := '% COUNT(*) SD3COUNT %'
    Else
        cCmpSD3 := '%'
        cCmpSD3 +='SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_PRODUTO,SC2.C2_UM,'
        cCmpSD3 +='SD3.D3_COD AS INSUMO, SD3.D3_UM, SD3.D3_CF, SD3.D3_LOCAL, SD3.D3_QUANT, SD3.D3_DOC,'
        cCmpSD3 +='SD3.D3_EMISSAO, SD3.D3_CODLAN,  SD3.D3_NUMSEQ, CLZ.CLZ_CODIGO,SC2.C2_ITEM, SD3.D3_ESTORNO, SD3.D3_OP'
 
        cCmpSD3 += '%'
        
        cOrder	:= '% ORDER BY SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_UM%'
        
    EndIF
    
    cAliasSD3   :=  GetNextAlias()
    
    BeginSql Alias cAliasSD3
        COLUMN D3_EMISSAO AS DATE
        SELECT
        %Exp:cCmpSD3%
        FROM
        %Table:SD3% SD3
        LEFT JOIN %table:SC2% SC2 ON (SC2.C2_FILIAL = %xFilial:SC2%
            AND (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN) = SD3.D3_OP
            AND SC2.%NotDel%)

        JOIN %table:SB1% SB1 ON (SB1.B1_FILIAL = %xFilial:SB1% AND
            SB1.B1_COD = SD3.D3_COD AND
            SB1.%NotDel%)

        LEFT JOIN %table:CLZ% CLZ ON CLZ.CLZ_FILIAL = %xFilial:CLZ%
        AND (CLZ.CLZ_TM+CLZ.CLZ_CF) = SD3.D3_TM + SD3.D3_CF
        AND CLZ.%NotDel%
        WHERE
        SD3.D3_FILIAL = %xFilial:SD3% AND
        SD3.D3_EMISSAO  >= %Exp:dTos(dDtIni)% AND SD3.D3_EMISSAO    <= %Exp:dTos(dDtAte)% AND
        SD3.D3_CODLAN <> ' ' AND SD3.D3_ESTORNO = ' ' AND  SUBSTRING(SD3.D3_CODLAN,3,2) <> '52' AND
        SD3.D3_CF NOT IN('DE7','RE7') AND
        SD3.%NotDel%
        %Exp:cOrder%
        
    EndSql
    
Return cAliasSD3
//-------------------------------------------------------------------
/*/{Protheus.doc} Qry2F()
Função que monta a query para processamento das fichas de Desmontagem 2F

@author Graziele Mendonça Paro
@since 26/09/2016  
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Qry2F(lCOUNT, dDtIni, dDtAte)
    
    Local cAlias2F   :=  GetNextAlias()
    
    BeginSql Alias cAlias2F
        COLUMN D3_EMISSAO AS DATE
        
        SELECT SD3ORI.D3_DOC,SD3ORI.D3_EMISSAO,
            SD3ORI.D3_COD    AS CODORI,
            SD3ORI.D3_UM AS UMORI,
            SD3ORI.D3_LOCAL AS LOCALORI,
            SD3ORI.D3_QUANT AS QTDORI,
            SD3ORI.D3_CODLAN AS CODLANORI,
            SD3ORI.D3_NUMSEQ AS NUMSEQORI,
            SD3ORI.D3_CF AS CFORI,
            CLZORI.CLZ_CODIGO AS CLZORI,
            SD3ORI.D3_ITEM  AS ITEMORI,
            SD3DES.D3_COD    AS CODDES,
            SD3DES.D3_UM AS UMDES,
            SD3DES.D3_LOCAL AS LOCALDES,
            SD3DES.D3_QUANT AS QTDDES,
            SD3DES.D3_CODLAN CODLANDES,
            SD3DES.D3_NUMSEQ AS NUMSEQDES,
            SD3DES.D3_CF AS CFDES,
            CLZDES.CLZ_CODIGO AS CLZDES,
            SD3DES.D3_ITEM AS ITEMDES
        FROM   %TABLE:SD3%  SD3ORI
        INNER JOIN %TABLE:SD3% SD3DES
            ON ( SD3ORI.D3_FILIAL = %xFilial:SD3%
            AND SD3ORI.D3_NUMSEQ = SD3DES.D3_NUMSEQ
            AND SD3DES.%NotDel%
            AND SD3DES.D3_ESTORNO = ' '
            AND SD3ORI.D3_FILIAL = SD3DES.D3_FILIAL
            AND SD3DES.D3_CODLAN <> ''
            AND SD3DES.D3_ESTORNO = ' ' )
        INNER JOIN %TABLE:SB1% SB1ORI
            ON ( SB1ORI.B1_FILIAL = %xFilial:SB1%
            AND SB1ORI.B1_COD = SD3ORI.D3_COD
            AND SB1ORI.%NotDel% )
            JOIN %TABLE:SB1% SB1DES
        ON ( SB1DES.B1_FILIAL = %xFilial:SB1%
            AND SB1DES.B1_COD = SD3DES.D3_COD
            AND SB1DES.%NotDel%)
            LEFT JOIN %TABLE:CLZ% CLZORI
        ON ( CLZORI.CLZ_FILIAL = %xFilial:CLZ%
            AND ( CLZORI.CLZ_TM + CLZORI.CLZ_CF ) =
            SD3ORI.D3_TM + SD3ORI.D3_CF
            AND CLZORI.%NotDel%)
            LEFT JOIN %TABLE:CLZ% CLZDES
        ON ( CLZDES.CLZ_FILIAL = %xFilial:CLZ%
            AND ( CLZDES.CLZ_TM + CLZDES.CLZ_CF ) = (
            SD3DES.D3_TM + SD3DES.D3_CF )
            AND CLZDES.%NotDel%)
        WHERE  SD3ORI.D3_FILIAL = %xFilial:SD3%
            AND SD3ORI.D3_EMISSAO >= %Exp:dTos(dDtIni)%
            AND SD3ORI.D3_EMISSAO <= %Exp:dTos(dDtAte)%
            AND SD3ORI.D3_CODLAN <> ' '
            AND SD3ORI.D3_ESTORNO = ' '
            AND Substring(SD3ORI.D3_CODLAN, 3, 2) <> '52'
            AND SD3ORI.D3_CF = 'RE7'
            AND SD3ORI.%NotDel%
        ORDER  BY SD3ORI.D3_FILIAL, SD3ORI.D3_COD, SD3ORI.D3_UM
    
    EndSql
 
Return cAlias2F


//-------------------------------------------------------------------
/*/{Protheus.doc} QrySBC()
Função que monta a query para processamento da SD3

@author Erick Dias
@since 10/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QrySBC(lCOUNT, dDtIni, dDtAte)
    
    Local cCmpSBC	:= ''
    Local cOrder	:= '%%'
    
    If lCOUNT
        cCmpSBC := '% COUNT(*) SBCCOUNT %'
    ElseIf SBC->(ColumnPos("BC_CODLAN"))>0
        cCmpSBC := '%'
        cCmpSBC +='SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_PRODUTO,SC2.C2_UM,'
        cCmpSBC +='SBC.BC_PRODUTO	, SBC.BC_CODLAN , SBC.BC_QUANT  , SBC.BC_LOCORIG, SBC.BC_NUMSEQ, SBC.BC_DATA, SBC.BC_CODDEST'
        
        cCmpSBC += '%'
        
        cOrder	:= '% ORDER BY SBC.BC_FILIAL, SBC.BC_PRODUTO, SBC.BC_DATA%'
        
    EndIF
    
    cAliasSBC   :=  GetNextAlias()
    
    BeginSql Alias cAliasSBC
        COLUMN BC_DATA AS DATE
        SELECT
        %Exp:cCmpSBC%
        FROM
        %Table:SBC% SBC
        LEFT JOIN %table:SC2% SC2 ON SC2.C2_FILIAL = %xFilial:SC2%
        AND (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN) = SBC.BC_OP
        AND SC2.%NotDel%
        
        WHERE
        SBC.BC_FILIAL = %xFilial:SBC% AND
        SBC.BC_DATA  >= %Exp:dTos(dDtIni)% AND SBC.BC_DATA    <= %Exp:dTos(dDtAte)% AND
        SBC.BC_CODLAN <> ' ' AND
        SBC.%NotDel%
        %Exp:cOrder%
        
    EndSql
    
Return cAliasSBC


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSD3()


@author Graziele Paro
@since 03/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcSD3(dDtIni, dDtAte,cAliasTmp,oProcess)
    
    Local oCat83        := CAT83ESTR():New()
    Local oTabCLR       := TABCLR():New()
    Local oTabCLQ       := TABCLQ():New()
    Local oTabF04		  := TABF04():New()
    Local cAliasSD3 	   := ''
    Local cAlias2F      := '' 
    Local cIdD3         := ''
    Local nTot				:= 0
    Local nProc			:= 0
    Local cCodGGF		:= PADR(aParSX6[MV_GGFCT83],TAMSX3("B1_COD")[1])
    Local cCodEner	:= PADR(aParSX6[MV_ENECT83],TAMSX3("B1_COD")[1])
    Local cCodFhc2D	:= PADR(aParSX6[MV_2DCT83],TAMSX3("B1_COD")[1])
    Local cCodFhc1B  := PADR(aParSX6[MV_1BCT83],TAMSX3("B1_COD")[1])
    
    ProcLogAtu("MENSAGEM","Início Documentos Internos - Filial " + FWGETCODFILIAL + " " + Time())
    
    nTot	:= QtdeSd3(dDtIni, dDtAte)
    
    If !lAutomato
    	oProcess:Set2Progress(nTot)
    	oProcess:Inc1Progress(FWGETCODFILIAL + ' - Buscando movimentações SD3')
    	oProcess:Inc2Progress(FWGETCODFILIAL + ' - Buscando movimentações SD3')
    EndIf
    
    cAliasSD3	:= QrySD3(.F., dDtIni, dDtAte)
    oTabF04:setAlsTmp(cAliasTmp)
    DbSelectArea (cAliasSD3)
    (cAliasSD3)->(DbGoTop ())
    oTabCLQ:setAlsTmp(cAliasTmp)
    oCat83:setAlsTmp(cAliasTmp) //Passa alias da tabela principal para estrutura da cat
    Do While !(cAliasSD3)->(Eof ())
        nProc++
        
        If !lAutomato
        	oProcess:Inc2Progress('Processando Operações de Estoque  - Processando ' +Alltrim(STR(nProc)) + ' de ' + Alltrim(STR(nTot) ))
        EndIf
        
        //Adiciona nota fiscal e retorna ID
        cIdD3   := AddNota(oTabCLQ, ;
            (cAliasSD3)->D3_EMISSAO, ;
            , ;
            , ;
            , ; //Saida /Entrada
        , ;
            IIF(EMPTY((cAliasSD3)->C2_NUM),(cAliasSD3)->D3_DOC, (cAliasSD3)->C2_NUM),;
            (cAliasSD3)->C2_ITEM)
                      
        
        //Popula objeto oCat83 para que possa ser processada a Ficha
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca sequencial unívoco
        oCat83:setFilMov(cFilAnt)
        oCat83:setPeriodo(dDtIni)
        
        If (cAliasSD3)->D3_ESTORNO == 'S' .Or. (cAliasSD3)->D3_CF $ 'ER0/ER1'
            //Aqui trata de um estorno de MP, PI ou PA.
            oCat83:setEstorno(.T.)
        EndIF
        /*Preenchimento do Produto Princial*/
        If SubStr((cAliasSD3)->D3_CODLAN,3,2) == '25'
            //Se o destino for ficha 2E Gastos Gerais irá mandar o produto genérico GGF.
            oCat83:setCodProd(cCodGGF) //Produto Destino
        ElseIf SubStr((cAliasSD3)->D3_CODLAN,3,2) == '24'
            //Se o destino for ficha 2D Custos para Transportes irá mandar o produto genérico da ficha 2D.
            oCat83:setCodProd(cCodFhc2D) //Produto Destino
        //Se for uma Transferência entre produtos e não tiver OP
        ElseIf (cAliasSD3)->D3_CF == 'RE4' .And. EMPTY((cAliasSD3)->D3_OP)// SubStr((cAliasSD3)->D3_CODLAN,1,2) == '11'    
            oCat83:setCodProd((cAliasSD3)->INSUMO)
        Else
            oCat83:setCodProd((cAliasSD3)->C2_PRODUTO) //Produto Destino
        EndIF
        
        /*Preenchimento do Insumo*/
        If SubStr((cAliasSD3)->D3_CODLAN,1,2) == '25'
            //Se o destino for ficha 2E Gastos Gerais irá mandar o produto genérico GGF.
            oCat83:setInsumo(cCodGGF) //Produto Destino
        ElseIF SubStr((cAliasSD3)->D3_CODLAN,1,2) == '13' .OR. SubStr((cAliasSD3)->D3_CODLAN,3,2) == '13'
            //Se o destino for ficha 1C Energia Elétrica irá mandar o produto genérico de energia.
            oCat83:setInsumo(cCodEner) //Produto Destino
            oCat83:setCodProd(cCodEner)
        ElseIf   SubStr((cAliasSD3)->D3_CODLAN,1,2) == '12' .OR. SubStr((cAliasSD3)->D3_CODLAN,3,2) == '12'
            //Se o destino for ficha 1B - Controle de Valores Agregados na Industrialização por outro Estabelecimento
            oCat83:setInsumo(cCodFhc1B) //Produto Destino 
        Else
            oCat83:setInsumo((cAliasSD3)->INSUMO) //Produto Movimentado
        EndIF     
        
        /*Situações aonde o Produto Principal e o Movimentado é o mesmo*/ 
        
        
        /*Entrada nas fichas - Lançamento Complementar é utilizado geralmente para ajustes de ENTRADA no estoque. Códigos que podem ser utilizados:
        701116,701216,701316,701416,702116,702216,702316,702516,702616,702716,703116  e 703216
        Não podem ser utilizados os códigos: 
        701216 – Não posso utilizar, pois na ficha 12 não existe quantidade, logo se for realizado um lançamento no estoque de forma manual não existe como fazer complemento de ICMS e Custo, que é o que trata a ficha em questão.
		702716 - Não tratamos a ficha 2G.
		701416 - Não posso utilizar, pois na ficha 14  não existe quantidade, logo se for realizado um lançamento no estoque de forma manual não existe como fazer complemento de ICMS e Custo, que é o que trata a ficha em questão.
		702116, 702216 e 702613 -  Não tem sentido fazer um ajuste de entrada utilizando este código, pois a quantidade desta ficha acontece apenas nos lançamentos de saída. E no Protheus a forma de gerar produtos 
		2A,  2B e 2C é apenas realizando o apontamento de produção.
		702616 - Não pode ser utilizado, pois não existe como fazer uma entrada em um processo de desmontagem dentro do Protheus
        
        Com esse lançamento o produto principal e movimentado é sempre o mesmo
        Entrada de Lançamento Complementar*/
        If  SubStr((cAliasSD3)->D3_CODLAN,1,2) == '70'  .And. SubStr((cAliasSD3)->D3_CODLAN,5,2) == '16'  .And. !(SubStr((cAliasSD3)->D3_CODLAN,3,2)$'13|12|25|32')
        	oCat83:setCodProd((cAliasSD3)->INSUMO)
        	oCat83:setInsumo((cAliasSD3)->INSUMO)
        /*Saída nas Fichas - Outros lançamentos
        
         Não podem ser utilizados os códigos: 
         127017 - Não posso utilizar, pois na ficha 12 não existe quantidade, logo se for realizado um lançamento no estoque de forma manual não existe como fazer complemento de ICMS e Custo, que é o que trata a ficha em questão.
         147017 - Não posso utilizar, pois na ficha 14  não existe quantidade, logo se for realizado um lançamento no estoque de forma manual não existe como fazer complemento de ICMS e Custo, que é o que trata a ficha em questão.
        */	
        ElseIf SubStr((cAliasSD3)->D3_CODLAN,1,2)$'11|31|32|33' .And. (SubStr((cAliasSD3)->D3_CODLAN,3,2)$'76|70|77')	
        	oCat83:setCodProd((cAliasSD3)->INSUMO)
        	oCat83:setInsumo((cAliasSD3)->INSUMO)
        EndIf 	
        
        oCat83:setNumSeq((cAliasSD3)->D3_NUMSEQ)
        oCat83:setCdLanto((cAliasSD3)->D3_CODLAN)
        oCat83:setQtde((cAliasSD3)->D3_QUANT) 
        oCat83:setArmazem((cAliasSD3)->D3_LOCAL)
        oCat83:setTpReq((cAliasSD3)->D3_CF)
        oCat83:setTpDoc((cAliasSD3)->CLZ_CODIGO)
        oCat83:setIdNf(cIdD3)
        oCat83:setUnidade((cAliasSD3)->C2_UM)

        oCat83:setTabMov('SD3')
        
        //Processa a ficha
        AdFichaMov(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        
        (cAliasSD3)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSD3)
    (cAliasSD3)->(DbCloseArea ())
    
    //Colocar aqui a função que busca os dados da desmontagem

    cAlias2F   := Qry2F(.F., dDtIni, dDtAte)
    
     Do While !(cAlias2F)->(Eof ())
        nProc++
        
        If !lAutomato
            oProcess:Inc2Progress('Processando Operações de Desmontagem  - Processando ' +Alltrim(STR(nProc)) + ' de ' + Alltrim(STR(nTot) ))
        EndIf
        
        //Adiciona nota fiscal e retorna ID
        cIdD3   := AddNota(oTabCLQ, ;
            (cAlias2F)->D3_EMISSAO, ;
            , ;
            , ;
            , ; 
            , ;
            (cAlias2F)->D3_DOC, ;
            (cAlias2F)->CODORI)
        
        //Popula objeto oCat83 para que possa ser processada a Ficha
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca sequencial unívoco
        oCat83:setFilMov(cFilAnt)
        oCat83:setPeriodo(dDtIni)

        //Se for RE7 é pq se trata do produto antes de ser desmontado
        IF (cAlias2F)->CFDES == 'RE7'
            oCat83:setCdLanto((cAlias2F)->CODLANORI)
            oCat83:setInsumo((cAlias2F)->CODORI)
            oCat83:setCodProd((cAlias2F)->CODORI)
            oCat83:setQtde((cAlias2F)->QTDORI)
            oCat83:setUnidade((cAlias2F)->UMORI)
            oCat83:setTpDoc((cAlias2F)->CLZORI)
            oCat83:setNumSeq((cAlias2F)->NUMSEQORI)
            oCat83:setArmazem((cAlias2F)->LOCALORI)
            oCat83:setTpReq((cAlias2F)->CFDES)
        Else
            oCat83:setCdLanto((cAlias2F)->CODLANDES) 
            oCat83:setInsumo((cAlias2F)->CODORI)
            oCat83:setCodProd((cAlias2F)->CODDES)
            oCat83:setQtde((cAlias2F)->QTDDES)
            oCat83:setUnidade((cAlias2F)->UMDES)
            oCat83:setTpDoc((cAlias2F)->CLZDES)
            oCat83:setNumSeq((cAlias2F)->NUMSEQDES)
            oCat83:setArmazem((cAlias2F)->LOCALDES)
            oCat83:setTpReq((cAlias2F)->CFDES)
        EndIf
        oCat83:setIdNf(cIdD3)
        oCat83:setTabMov('SD3')
        
        //Processa a ficha
        AdFichaMov(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        
        (cAlias2F)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias2F)
    (cAlias2F)->(DbCloseArea ())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabCLQ)
    oTabCLQ:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    ProcLogAtu("MENSAGEM","Fim Documentos Internos - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcMMPF()
Função que irá calcular MMPF do módulo 1 e 3, considerando todas as entradas
já gravadas das fichas na tabela CLR/CLS.

@param dDtIni,Date,Date inicial do Processamento
@param DtFim,Date,Date Final do Processamento
@param cModulo,String,Módulo que será necessário cálculo

@author Graziele Paro
@since 03/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
STATIC FUNCTION CalcMMPF(DtIni, DtFim, cModulo)
    Local aMedia    := {}
    Local npos			:= 0
    Local cAliasCLR	:= ''
    Local nMMPFIcms	:= 0
    Local nMMOFCusto	:= 0
    
    F04->(dbSetOrder(2))
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM((CASE WHEN CLR_TPMOV IN('E', 'Z') THEN CLR_QTDE ELSE 0 END))-SUM(CASE WHEN CLR_TPMOV = 'F' THEN CLR_QTDE ELSE 0 END)  CLR_QTDE,"
    cSelect 	+= "SUM((CASE WHEN CLR_TPMOV IN('E', 'Z') THEN CLR_ICMS ELSE 0 END))-SUM(CASE WHEN CLR_TPMOV ='F' THEN CLR_ICMS ELSE 0 END)  CLR_ICMS,"
    cSelect 	+= "SUM((CASE WHEN CLR_TPMOV IN('E', 'Z') THEN CLR_CUSTO ELSE 0 END))-SUM(CASE WHEN CLR_TPMOV ='F' THEN CLR_CUSTO ELSE 0 END)  CLR_CUSTO,"
    cSelect 	+= "F04.F04_ID , F04.F04_PROD, F04.F04_FICHA"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
        
    If cModulo == '1'
        //Para módulo 1 serão consideradas no MMPF as fichas 1A e 1B.
        cWhere		+=  "CLR.CLR_FICHA IN ('11','12') AND CLR.CLR_TPMOV IN ('E','F') AND"
    ElseIf cModulo == '3'
        //Para módulo 1 serão consideradas no MMPF as fichas 3A e 3B.
        cWhere		+=  "CLR.CLR_FICHA IN ('31','32', '33') AND CLR.CLR_TPMOV IN ('E','Z', 'F') AND"
    EndIF
    
    cWhere      +=  " F04.F04_PROC = '1' AND F04.F04_STATUS = '2'   AND"   
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND F04.D_E_L_E_T_=' ')  "
    cGroupBy	:=	 "GROUP BY F04.F04_ID , F04.F04_PROD, F04.F04_FICHA "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        //Calcula MMPF de ICMS
        nMMPFIcms	:= (cAliasCLR)->CLR_ICMS / (cAliasCLR)->CLR_QTDE

        //Calcula MMPF de Custo
        nMMOFCusto	:= (cAliasCLR)->CLR_CUSTO / (cAliasCLR)->CLR_QTDE
        
        aAdd(aMedia,{})
        nPos := Len (aMedia)
        aAdd(aMedia[nPos],(cAliasCLR)->F04_FICHA ) //Ficha
        aAdd(aMedia[nPos],(cAliasCLR)->F04_PROD )  //Produto
        aAdd(aMedia[nPos],nMMPFIcms )				 //MMPF de ICMS
        aAdd(aMedia[nPos],nMMOFCusto)				 //MMPF de Custo
        
        //Deve ir no cabecalho e atualizar o valor de MMPF de ICMS e Custo
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->F04_ID))
            RecLock('F04',.F.)
            
            F04->F04_FATORI	:= nMMPFIcms
            F04->F04_FATORC	:= nMMOFCusto
            
            F04->(MsUnLock())
        EndIF
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return (aMedia)

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTmp()
Funbção que irá criar tabela temporária para controle do número sequencial
de cada ficha, e do número unívoco para todas as fichas.

@author Erick G. Dias
@since 10/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function CriaTabTmp(cArquivo,cAliasTRB)
    
    Local aCmp		:= {}
    DEFAULT cArquivo      := ''
    DEFAULT cAliasTRB     := ''
    
    cAliasTRB     := "SEQORDCAT83"
    
    aAdd (aCmp, {'FICHA'		,	'C', 	002,	0})	/*Número da Ficha*/
    aAdd (aCmp, {'SEQUENCIAL',	'N', 	009,	0})	/*Número sequencial das fichas*/
    
    cArquivo	:= CriaTrab (aCmp)
    DbUseArea (.T., __LocalDriver, cArquivo, cAliasTRB)
    IndRegua (cAliasTRB, cArquivo, 'FICHA')
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA108Seq()
Função que irá fazer o controle dos números sequenciais das fichas da CAT83,
retornando o próximo número disponível conforme a Ficha.

Esta função fará controle tanto do número de ordem de cada ficha
quando o número de lançamento unívoco em comum para todas as fichas.
Para fazer controle do número de ordem deverá passar a ficha correspondente,
já para o número de lançamento unívoco, deverá passar ficha 00.

@author Erick G. Dias
@since 10/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function FSA108Seq(cFicha,cAliasTab, lSaldoIni)
    
    Local nSequencia	:= 0
    DEFAULT lSaldoIni	:= .F.
    
    
    If (cAliasTab)->(MsSeek(cFicha))
        //Ficha já está cadastrada, basta incrementar o número
        nSequencia	:= (cAliasTab)->SEQUENCIAL
        RecLock((cAliasTab),.F.)
        nSequencia	++
        (cAliasTab)->SEQUENCIAL := nSequencia
        (cAliasTab)->(MsUnLock())
    Else
        //Ficha ainda não existe, inserir a ficha na tabela e incrementar o número
        IF cFicha == '00' .OR. lSaldoIni
            nSequencia	:= 1
        Else
            nSequencia	:= 2
        EndIF
        
        RecLock((cAliasTab),.T.)
        (cAliasTab)->FICHA	:= cFicha
        (cAliasTab)->SEQUENCIAL := nSequencia
        (cAliasTab)->(MsUnLock())
    EndIF
    
Return nSequencia

//-------------------------------------------------------------------
/*/{Protheus.doc} ModCodCHv()
Função que que trata os códigos da tabela 4.2 da CAT083, recebendo o modelo
do documento e retornando o código CHV.

@param cModeo,String,Modelo do documento fiscal

@author Erick G. Dias
@since 27/05/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ModCodCHv(cModelo)
    
    Local cCodChv	:= ''
    
    Do Case
    Case cModelo == '01'
        cCodChv	:= '1'
        
    Case cModelo == '1B'
        cCodChv	:= '2'
        
    Case cModelo == '02'
        cCodChv	:= '3'
        
    Case cModelo == '2D'
        cCodChv	:= '4'
        
    Case cModelo == '2E'
        cCodChv	:= '5'
        
    Case cModelo == '04'
        cCodChv	:= '6'
        
    Case cModelo == '06'
        cCodChv	:= '7'
        
    Case cModelo == '07'
        cCodChv	:= '8'
        
    Case cModelo == '08'
        cCodChv	:= '9'
        
    Case cModelo == '8B'
        cCodChv	:= '10'
        
    Case cModelo == '09'
        cCodChv	:= '11'
        
    Case cModelo == '10'
        cCodChv	:= '12'
        
    Case cModelo == '11'
        cCodChv	:= '13'
        
    Case cModelo == '13'
        cCodChv	:= '14'
        
    Case cModelo == '14'
        cCodChv	:= '15'
        
    Case cModelo == '15'
        cCodChv	:= '16'
        
    Case cModelo == '16'
        cCodChv	:= '17'
        
    Case cModelo == '17'
        cCodChv	:= '18'
        
    Case cModelo == '18'
        cCodChv	:= '19'
        
    Case cModelo == '20'
        cCodChv	:= '20'
        
    Case cModelo == '21'
        cCodChv	:= '21'
        
    Case cModelo == '22'
        cCodChv	:= '22'
        
    Case cModelo == '23'
        cCodChv	:= '23'
        
    Case cModelo == '24'
        cCodChv	:= '24'
        
    Case cModelo == '25'
        cCodChv	:= '25'
        
    Case cModelo == '26'
        cCodChv	:= '26'
        
    Case cModelo == '27'
        cCodChv	:= '27'
        
    Case cModelo == '28'
        cCodChv	:= '28'
        
    Case cModelo == '29'
        cCodChv	:= '29'
        
    Case cModelo == '30'
        cCodChv	:= '30'
        
    Case cModelo == '55'
        cCodChv	:= '31'
        
    Case cModelo == '57'
        cCodChv	:= '32'
        
    EndCase
    
Return cCodChv

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc14to63()
Função que irá processar todas aquisições de serviço de comunicação
relacionadas a exportação demonstradas na ficha 1D, e irá transportar para
um lançamento na ficha 6C.

@param cPeriodo

@author Erick G. Dias
@since 02/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Proc14to63(dDtDe, dDtAte, cAliasTmp)
    
    Local cAliasCLR	:= ''
    Local oCat83		:= CAT83ESTR():New()
    Local oTabCLR		:= TABCLR():New()
    Local oTabF04		:= TABF04():New()
    Local lAtuCab		:= .F.
    
    /*
    Função não será chamada pois na geração do arquivo não existe relação entre 1D com 6C
    desta maneira não é possível demonstrar a transferencia de valores da 1D para 6C.
    */
    
    oCat83:setAlsTmp(cAliasTmp)
    oTabF04:setAlsTmp(cAliasTmp)
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM(CLR.CLR_CUSTO) AS CLR_CUSTO, SUM(CLR.CLR_ICMS) as CLR_ICMS, SUM(CLR_OUTROS) as CLR_OUTROS, CLR.CLR_PROD"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(dDtDe)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(dDtAte)+"' AND "
    cWhere		+=  "CLR.CLR_FICHA IN ('14') AND"
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbGoTop ())
    
    Do While !(cAliasCLR)->(Eof ())
        
        //Aqui irá adicionar uma ficha 6C
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca número de lançamento unívoco
        oCat83:setPeriodo(dDtDe)
        oCat83:setCodProd((cAliasCLR)->CLR_PROD)
        oCat83:setVCusto((cAliasCLR)->CLR_CUSTO)
        oCat83:setVICMS((cAliasCLR)->CLR_ICMS)
        oCat83:setVOutros((cAliasCLR)->CLR_OUTROS)
        oCat83:setCrdComu((cAliasCLR)->CLR_ICMS)
        oCat83:setCrdAcum((cAliasCLR)->CLR_ICMS)
        oCat83:setCdLanto('1463  ')//Código ficticio somente para processamento do arquivo texto.
        oCat83:setFilMov(cFilAnt)
        oCat83:setTabMov('CLR')
        AddFicha6C(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        
        lAtuCab	:= .T.
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    IF lAtuCab
        //Irá atualizar status das fichas que tiveram saídas automaticas pelo ERP.
        AtuCab(dDtDe,dDtAte, 'Saída da Ficha processada automaticamente', '3',.T.,.T.)
    EndIF
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SaiTotAuto()
Função que irá fazer saída automáica de eneria elétrica ou serviço de transporte
de forma automática, considerando o total de ICMS e Custo, e fazendo um único lançamento

@param cPeriodo

@author Erick G. Dias
@since 02/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function SaiTotAuto(dDtDe, dDtAte, cAliasTmp, cOpcao)
    
    Local cAliasCLR	:= ''
    Local oCat83		:= CAT83ESTR():New()
    Local oTabCLR		:= TABCLR():New()
    Local oTabF04		:= TABF04():New()
    Local oTabCLQ    	:= TABCLQ():New()
    Local cTipoMov		:= ''
    Local lAtuCab		:= .F.
    Local cCodEner		:= PADR(aParSX6[MV_ENECT83],TAMSX3("B1_COD")[1])
    Local cCodGGF		:= PADR(aParSX6[MV_GGFCT83],TAMSX3("B1_COD")[1])
    Local cCodFhc2D		:= PADR(aParSX6[MV_2DCT83],TAMSX3("B1_COD")[1])
    
    IF cOpcao == '1'
        ProcLogAtu("MENSAGEM","Início Lançamento Ficha 1E para 2D - Filial " + FWGETCODFILIAL + " " + Time())
        cTipoMov	:= SubStr(aParSX6[MV_CAT8301],1,At(";",aParSX6[MV_CAT8301])-1)
    ElseIF cOpcao == '3'
        ProcLogAtu("MENSAGEM","Início Lançamento Ficha 1C para 2D - Filial " + FWGETCODFILIAL + " " + Time())
        cTipoMov	:= SubStr(aParSX6[MV_CAT8302],1,At(";",aParSX6[MV_CAT8302])-1)
    ElseIF cOpcao == '2'
        ProcLogAtu("MENSAGEM","Início Lançamento Ficha 1C para 2E - Filial " + FWGETCODFILIAL + " " + Time())
        cTipoMov	:= SubStr(aParSX6[MV_CAT8303],1,At(";",aParSX6[MV_CAT8303])-1)
    EndIF
    
    oCat83:setAlsTmp(cAliasTmp)
    oTabF04:setAlsTmp(cAliasTmp)
    oTabCLQ:setAlsTmp(cAliasTmp)
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM(CLR.CLR_CUSTO) AS CLR_CUSTO, SUM(CLR.CLR_ICMS) as CLR_ICMS, SUM(CLR.CLR_QTDE) AS CLR_QTDE"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(dDtDe)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(dDtAte)+"' AND "
    
    IF cOpcao == '1' //Servico transporte adquirido para 2D
        cWhere		+=  "CLR.CLR_FICHA IN ('15') AND"
    ElseIf cOpcao == '2' .or. cOpcao == '3' //energia elétrica para 2E ou 2D.
        cWhere		+=  "CLR.CLR_FICHA IN ('13') AND"
    Endif
    cGroupBy	:="GROUP BY CLR.CLR_FICHA "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbGoTop ())
    

    
    Do While !(cAliasCLR)->(Eof ())
    
    
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca número de lançamento unívoco     
        cIdD3   := AddNota(oTabCLQ, ;
            LastDay(dDtDe), ;
            , ;
            , ;
            , ; //Saida /Entrada
            , ;
            oCat83:getNrLanc(), ;
            '1')
        
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca número de lançamento unívoco
        oCat83:setPeriodo(dDtDe)
        oCat83:setFilMov(cFilAnt)
        oCat83:setTpDoc(cTipoMov) //Passa o tipo de documento informado através dos parâmetros MV_CAT8301, MV_CAT8302 ou MV_CAT8303
        oCat83:setIdNf(cIdD3)
        
        If cOpcao == '1'
            oCat83:setCdLanto('152421') //este código irá fazer uma baixa na ficha 1E com somatório dos valores de custos e ICMS e uma inclusão na ficha 2D automaticamente.
            
        ElseIF cOpcao == '3'
            oCat83:setCdLanto('132421') //este código irá fazer saída da ficha 1C e entrada na ficha 2D, considerando valor total das entradas de ICMS e Custo.
            oCat83:setCodProd(cCodFhc2D) //Produto Destino
            oCat83:setInsumo(cCodEner)//origem
            
        ElseIF cOpcao == '2'
            oCat83:setCdLanto('132521') //este código irá fazer requisição automática da ficha 1C para ficha 2D de trasnportes.
            oCat83:setCodProd(cCodGGF) //Produto Destino
            oCat83:setInsumo(cCodEner)//origem
            oCat83:setQtde((cAliasCLR)->CLR_QTDE) 
        EndIF

        oCat83:setVICMS((cAliasCLR)->CLR_ICMS)
        oCat83:setVCusto((cAliasCLR)->CLR_CUSTO)
        oCat83:setTabMov('CLR')
        
        //Processa a ficha
        AdFichaMov(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        lAtuCab	:= .T.
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    IF lAtuCab
        //Irá atualizar status das fichas que tiveram saídas automaticas pelo ERP.
        AtuCab(dDtDe,dDtAte, 'Saída da Ficha processada automaticamente', '2',.T.,.T.)
    EndIF
    
    
    IF cOpcao == '1'
        ProcLogAtu("MENSAGEM","Fim Lançamento Ficha 1E para 2D - Filial " + FWGETCODFILIAL + " " + Time())
    ElseIF cOpcao == '2'
        ProcLogAtu("MENSAGEM","Fim Lançamento Ficha 1C para 2D - Filial " + FWGETCODFILIAL + " " + Time())
    ElseIF cOpcao == '3'
        ProcLogAtu("MENSAGEM","Fim Lançamento Ficha 1C para 2E - Filial " + FWGETCODFILIAL + " " + Time())
    EndIF
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} EntSaiGGF()
Função que irá processar as saídas automáticas de GGF da ficha 2E e entrada
na ficha destino.


@author Erick G. Dias
@since 15/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function EntSaiGGF(dDtDe, dDtAte, cAliasTmp)
    
    Local cAliasF04	:= ''
    Local oCat83		:= CAT83ESTR():New()
    Local oTabCLR		:= TABCLR():New()
    Local oTabF04		:= TABF04():New()
    Local cCodGGF		:= PADR(aParSX6[MV_GGFCT83],TAMSX3("B1_COD")[1])
    Local cCodLAnc		:= ''
    Local oTabCLQ    	:= TABCLQ():New()
    Local cTipoMov		:= SubStr(aParSX6[MV_CAT8304],1,At(";",aParSX6[MV_CAT8304])-1)
    ProcLogAtu("MENSAGEM","Início lançamento automático GGF - Filial " + FWGETCODFILIAL + " " + Time())
    
    oCat83:setAlsTmp(cAliasTmp)
    oTabF04:setAlsTmp(cAliasTmp)
    oTabCLQ:setAlsTmp(cAliasTmp)
    
    cAliasF04	:=	GetNextAlias()
    cSelect 	:=	"F04.F04_PROD,F04.F04_FICHA, F01.F01_PERRAT"
    cWhere		:=	"F04.F04_FILIAL='"+xFilial("F04")+"' AND "
    cWhere		+=	"F04.F04_PERIOD>='"+DTOS(dDtDe)+"' AND "
    cWhere		+=	"F04.F04_PERIOD<='"+DTOS(dDtAte)+"' AND "
    cWhere		+=  "F04.F04_FICHA IN ('21','23','27') AND" //Irá considerar somente os produtos no rateio que foram elaborados nas fichas 2A, 2C e 2 G.
    
    cJoinF04	:="JOIN "+RetSqlName("F01")+" F01 ON(F01.F01_FILIAL='"+xFilial("F01")+"' AND F01.F01_PRODUT=F04.F04_PROD AND "
    cJoinF04	+="F01.F01_PERIOD='"+strzero(month(dDtDe),2) + str(year(dDtDe),4)+"' AND F01.F01_PERRAT > 0 AND F01.F01_FICHA = '3' AND F01.D_E_L_E_T_=' ') "
    
    cSelect		:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoinF04	:= '%'+cJoinF04+'%'
    
    BeginSql Alias cAliasF04
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:F04% F04
        %Exp:cJoinF04%
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
        
    EndSql
    
    DbSelectArea (cAliasF04)
    (cAliasF04)->(DbGoTop ())
    
    Do While !(cAliasF04)->(Eof ())
        
        If (cAliasF04)->F04_FICHA = '21' // Saída para 2A
            cCodLAnc	:= '252131'
        ElseIf (cAliasF04)->F04_FICHA = '23' //Saída para 2C
            cCodLAnc	:= '252331'
        ElseIf (cAliasF04)->F04_FICHA = '27' //Saída para 2G
            cCodLAnc	:= '252731'
        EndIF
        
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca número de lançamento unívoco
        cIdD3   := AddNota(oTabCLQ, ;
            LastDay(dDtDe), ;
            , ;
            , ;
            , ; //Saida /Entrada
            , ;
            oCat83:getNrLanc(), ;
            '1')
        
        oCat83:setFilMov(cFilAnt)
        oCat83:setPeriodo(dDtDe)
        oCat83:setCodProd((cAliasF04)->F04_PROD) //Produto de Destino
        oCat83:setInsumo(cCodGGF) // Produto GGF movimentado
        oCat83:setCdLanto(cCodLAnc) //este código irá fazer uma baixa na ficha 1E com somatório dos valores de custos e ICMS e uma inclusão na ficha 2D automaticamente.
        oCat83:setQtde(1) //Quantidade para gasto gerais é 1
        oCat83:setIdNf(cIdD3)
        oCat83:setTabMov('CLR')
        oCat83:setTpDoc(cTipoMov) //Passa o tipo de documento informado através do parâmetro MV_CAT8304
        
        //Processa a ficha
        AdFichaMov(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        
        (cAliasF04)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasF04)
    (cAliasF04)->(DbCloseArea())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    FreeObj(oTabCLQ)
    oTabCLQ:= nil
    
    ProcLogAtu("MENSAGEM","Fim lançamento automático GGF - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//Processar ficha 5A, deverá buscar produtos e seus insumos, somando a quantidade de cada insumo, sempre na entrada da ficha 2A, 2C e 2G. Deverpa
//incluir ficha 5A com CLR_PROD no cabecalho e CLR_PRDMOV como insumo.

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcValCAT()
Função que irá processar os valores de custo e ICMS das operações já
gravadas nas fichas, este processamento será iniciado quando já tiver
concluída primera etapa da CAT083,

@param cPeriodo

@author Erick G. Dias
@since 03/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcValCAT(DtIni,DtFim,cAliasTmp,oProcess)
    
    Local lProc			:= .T.
    Local nQtdIni		:= 0
    Local nQtdFim		:= 0
    Local nRet			:= .F.
    Local nStatus1		:= .F.
    Local nStatus1C		:= .F.
    Local nStatus2D		:= .F.
    Local nStatus2E		:= .F.
    Local nStatus2F		:= .F.
    Local nStatus2		:= .F.
    Local nStatus3		:= .F.
    Local nStatus6		:= .F.
    Local lProcMod6		:= .F. 
    
    ProcLogAtu("MENSAGEM","Início Atualização dos valores das fichas - Filial " + FWGETCODFILIAL + " " + Time())
    
    nStatus1		:= ExistMod(DtIni,DtFim, '1')
    nStatus1C		:= ExistMod(DtIni,DtFim, '1C')
    nStatus2D		:= ExistMod(DtIni,DtFim, '2D')
    nStatus2E		:= ExistMod(DtIni,DtFim, '2E')
    nStatus2F		:= ExistMod(DtIni,DtFim, '2F')
    nStatus2		:= ExistMod(DtIni,DtFim, '2')
    nStatus3		:= ExistMod(DtIni,DtFim, '3')
    nStatus6		:= ExistMod(DtIni,DtFim, '6')
    
    //---------------------------------------------------------
    //Irá verificar se existe alguma ficha para ser processada
    //---------------------------------------------------------
    nQtdIni	:= ProcCab(DtIni,DtFim)
    
    If !lAutomato
    	oProcess:Set2Progress(nQtdIni)
    	oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
    EndIf
    
    If nQtdIni > 0
        lProc	:= .T.
    EndIF
    
    While (lProc)
        //---------------------------
        //PROCESSAMENTO DO MÓDULO 1
        //---------------------------
        
        //Verifica se existe alguma ficha pronta para o processamento
        If !lAutomato
        	oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        If nStatus1 .AND. StatusMod(DtIni,DtFim, '1') 
            //Realiza o cálculo de MMPF
            CalcMMPF(DtIni, DtFim, '1')
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIF
            
            //Calcula valor de ICMS e Custo nas saídas do módulo 1 e nas entradas dos respectivo destino
            AtuSaiEnt(DtIni, DtFim)
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
            //Se por algum motivo a ficha pronta para processamento não teve saída no período, ela será concluída
            //Atualiza fichas 1A, 1B, 1D e 1E.
            AtuCab(DtIni,DtFim,'Não Houve Saídas Desta Ficha no Período','1',.T.,.T.)
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf

        EndIF
                
        //---------------------------
        //PROCESSAR ENERGIA ELÉTRICA
        //---------------------------
        If !lAutomato
        	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        IF nStatus1C .AND. StatusMod(DtIni,DtFim, '1C')
        	CalcMMPF(DtIni, DtFim, '1C')
            //Verifica se os todos os produtos de saída da ficha 1C estão devidamente cadastrados na 4A
            //Se não houver saída a ficha nã
            IF Sai1CF01(DtIni,DtFim)
                
                If !lAutomato
                	  oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
                EndIF
                
                //Processa total de icms e custo de entrada da ficha 2E.
                TotEnt2E2F(DtIni,DtFim,'1C')
                
                If !lAutomato
                	  oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
                EndIf
                
                //Atualiza o valor de CUSTO e ICMS na saida da 1C e entrada na ficha de destino
                AtuSaiEnt(DtIni, DtFim,'1C')
                
                If !lAutomato
                	  oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
                EndIf
                
            EndIF
            
        EndIF
        
        //------------------------
        //PROCESSAR GASTOS GERAIS
        //------------------------
        
        //Deverá analisar se todas as entradas da ficha 2E estão prontas para serem processadas.
        //Se estiverem então deverá fazer somatório de custo e ICMS das entradas, e fazer as saídas  automáticas
        //para todos os produtos cadastrados na tabela 4C.
        //Se ainda não estiverem prontas deverá aguardar o processamento.
        If !lAutomato
        	oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        IF nStatus2E .AND. StatusMod(DtIni,DtFim, '2E')
            //Processa total de icms e custo de entrada da ficha 2E.
            TotEnt2E2F(DtIni,DtFim,'2E')
            //Atualiza o valor de CUSTO e ICMS na saida da 2E e entrada na ficha de destino
            AtuSaiEnt(DtIni, DtFim,'2E')
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
            //TODO casos onde não houver cadastro na F1 para 4C
            
        EndIF
        
        //--------------------------------
        //PROCESSAMENTO INSUMO em COMUM
        //--------------------------------
        //Verifica se existe alguma ficha pronta para o processamento
        //Para poder iniciar o processamento da Ficha 2F todas entradas deverão estar com ICMS/CUSTO maior que zero
        //E toddas as saídas da 2F deverão ter o CLR_PROD cadastrado em 4C
        If !lAutomato
        	oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        IF nStatus2F .AND. StatusMod(DtIni,DtFim, '2F') 
            //Todas entradas estão prontas, com cabecalho já indicando para processar.
            //Deve verificar agora se todas as saídas também estão cadastradas em CLT
            IF Sai2FCLT(DtIni,DtFim)
                
                If !lAutomato
                	  oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
                EndIf
                
                //Processa total de icms e custo de entrada da ficha 2E.
                TotEnt2E2F(DtIni,DtFim,'2F')
                
                If !lAutomato
                	  oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
                EndIf
                
                //Calcula valor de ICMS e Custo nas saídas do módulo 2 e nas entradas dos respectivo destino
                AtuSaiEnt(DtIni, DtFim,'2F')
                
                If !lAutomato
                	  oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
                EndIf
                
            EndIF
            
        EndIF
        
        //---------------------------
        //PROCESSAMENTO DO MÓDULO 2
        //---------------------------
        
        //Verifica se existe alguma ficha pronta para o processamento
        If !lAutomato
        	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        IF (nStatus2 .AND. StatusMod(DtIni,DtFim, '2')) .Or. (nStatus2D .AND. StatusMod(DtIni,DtFim, '2D')) 
            //-----------------------------
            //Irá processar ficha técnica 5A para as fichas prontas para processamento
            //-----------------------------
            Atu5A(DtIni, DtFim, "('21','22','23','27')")
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
            //Calcula valor de ICMS e Custo nas saídas do módulo 2 e nas entradas dos respectivo destino
            AtuSaiEnt(DtIni, DtFim)
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
            //Se por algum motivo a ficha pronta para processamento não teve saída no período, ela será concluída
            //Atualiza fichas 2A, 2B, 2C, 2D, 2G
            AtuCab(DtIni,DtFim,'Não Houve Saídas Desta Ficha no Período','6',.T.,.T.)
            
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
        EndIF
        
        //---------------------------
        //PROCESSAMENTO DO MÓDULO 3
        //---------------------------
        
        //Verifica se existe alguma ficha do módulo 3 pronta para ser processada
        
        If !lAutomato
        	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        IF nStatus3 .AND. (StatusMod(DtIni,DtFim, '3')) 
            //Calcula MMPF das fichas priontas
            CalcMMPF(DtIni, DtFim, '3')
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
            //Calcula valor de ICMS e Custo nas saídas do módulo 2 e nas entradas dos respectivo destino
            AtuSaiEnt(DtIni, DtFim)
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
            //---------------------------
            //PROCESSA DEVOLUCOES DE VENDA
            //---------------------------
            //DevVenda(DtIni,DtFim)
            //oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            //Se por algum caso não encontrou a saída da ficha no processamento da AtuSaiEnt, o cabecalho será atualizado através da AtuSaiEnt
            //Atualiza Fichas 3A, 3B e 3C
            AtuCab(DtIni,DtFim,'Não Houve Saídas Desta Ficha no Período','7',.T.,.T.)
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
        EndIF
        
          
        
        //---------------------------
        //PROCESSAMENTO FICHA 5B
        //---------------------------
        
        //Verifica se existe alguma ficha pronta para o processamento
        If !lAutomato
        	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        If nStatus1 .AND. StatusMod(DtIni,DtFim, '5B')
            //Para as movimentações da ficha 5B de perdas durante produção, os valores das saídas é o valor constante no documento
            //fiscal, não é necessário calcular MMPF ou ficha técnica. Apenas verifico se todas as entradas estão com valores
            //de icms ou custo, e atualizo como concluída mesmo se não houver saídas no período.
            AtuCab(DtIni,DtFim,'','8',.T.,.T.)
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
        EndIF
        
        
        //---------------------------
        //PROCESSAMENTO DO MÓDULO 6
        //---------------------------
        //Verifica se existem fichas no módulo 6 para processamento
        If !lAutomato
        	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
        EndIf
        
        IF nStatus6 .AND. StatusMod(DtIni,DtFim, '6')
            //Atualiza valor do crédito acumulado
            AtuMod6(DtIni, DtFim) //Atualiza fichas 6A e 6B
            
            If !lAutomato
            	 oProcess:Inc2Progress('Processando Fichas - ' +Alltrim(STR(nQtdIni-nQtdFim)) + ' de ' + Alltrim(STR(nQtdIni) ))
            EndIf
            
            lProcMod6	:= .T.
        EndIF
        
        //Verifica se ainda resta alguma ficha para ser processada.
        nQtdFim	:= ProcCab(DtIni,DtFim)
        
        //Verifica que a quantidade que iniciou é a mesma que a quantidade final, se for para de processar
        IF nQtdIni == nQtdFim
            lProc    := .F.
        ElseIF nQtdFim == 0
            //Aqui não tem mais nenhuma ficha pendente para ser processada, poderá concluir o processamento
            lProc	:= .F.
        //Verifica se quantidade de fichas a serem processadas é menor da quantidade que iniciou    
        ElseIf  (nQtdFim < nQtdIni) 
            //Se sim significa que foram processadas e atualizadas fichas, deverá permanecer processando
            lProc	:= .T.
            nQtdIni	:= nQtdFim
        Else
            //Se a quantidade de fichas não foi alterada, por algum motivo não foi possível processar as fichas
            //Seja por erro de cadastro de código, de documento/Operação
            //Para não ficar em looping infinito deverá sair do laço.
            lProc	:= .F.
        EndIF
        
    EndDo
        
    IF !lProcMod6 
        StatusMod(DtIni,DtFim, '6', .T.)
        AtuMod6(DtIni, DtFim)
    EndIF
    
    //---------------------------------------------------
    //PROCESSAMENTO DAS FICHAS QUE NÃO FORAM PROCESSADAS.
    //----------------------------------------------------
    IF nQtdFim > 0
        //Irá procurar fichas com status não processadas e irá atualizar com a mensagem de que deverá ser revisto
        //cadastros e operações da ficha e das fichas relacionadas.
        AtuCab(DtIni,DtFim,'Verificar cadastros/entradas desta ficha')
        //Nem todas fichas foram processadas com sucesso.
        nRet	:= .F.
    Else
        //Todas Fichas Processadas com sucesso
        nRet	:= .T.
    EndIF
    
    ProcLogAtu("MENSAGEM","Fim Atualização dos valores das fichas - Filial " + FWGETCODFILIAL + " " + Time())
    
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSaiEnt()

Função que atualiza o valor de ICMS e de CUSTO da saída de uma ficha e também
atualiza o valor de entrada em outra ficha correspondente.

@param cPeriodo

@author Erick G. Dias
@since 03/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AtuSaiEnt(DtIni, DtFim, cOpcao, lForcaProc)
    
    //Deverá buscar a saídas da ficha e produto, atualiza o valor de ICMS e CUSTO
    //Após atualizar deverá buscar a operação na ficha correspondente e atualizar também
    
    Local cAliasCLR     := ''
    Local nCusto        := 0
    Local nICMS         := 0
    Local aIdProc       := {}
    Local nPos          := 0
    Local nPerConj      := 0
    Local nPerRat       := 0
    Local oTabCLT
    DEFAULT cOpcao      := ''
    
    F04->(dbSetOrder(2))
    
    
    cAliasCLR	:=	GetNextAlias()
    cSelect     :=  "CLR.CLR_NRLAN, CLR.CLR_PERIOD, CLR.CLR_QTDE, CLR.CLR_CODORI, CLR.CLR_IDCAB, F04.F04_FATORI, F04.F04_FATORC, CLR.R_E_C_N_O_ as CLRRECNO, CLR.CLR_TPRD, CLR.CLR_NUMSEQ,F04.F04_PROD, CLR.CLR_TPRD, CLR.CLR_TPMOV  "
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "

    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "  
    
    cWhere      +=  "CLR.CLR_TPMOV = 'S' AND " 
    cWhere      += "F04.F04_PROC = '1' AND F04.F04_STATUS = '2' AND "
    
    cJoin  		:= "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  		+= "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "

    If cOpcao == '2E'
        
        oTabCLT     := TABCLT():New()
        cSelect		+= ',F01.F01_PERRAT, F01.F01_PRODUT '
        cJoin		+="JOIN "+RetSqlName("F01")+" F01 ON(F01.F01_FILIAL='"+xFilial("F01")+"' AND F01.F01_PRODUT=CLR.CLR_PROD AND "
        cJoin		+="F01.F01_PERIOD='"+strzero(month(DtIni),2) + str(year(DtIni),4)+"' AND F01.F01_PERRAT > 0 AND F01.F01_FICHA = '3' AND F01.D_E_L_E_T_=' ') "
        
    ElseIF cOpcao == '1C'
        
        oTabCLT     := TABCLT():New()
        cSelect		+= ',F01.F01_PERRAT, F01.F01_PRODUT '
        cJoin		+="JOIN "+RetSqlName("F01")+" F01 ON(F01.F01_FILIAL='"+xFilial("F01")+"' AND F01.F01_PRODUT=CLR.CLR_PROD AND "
        cJoin		+="F01.F01_PERIOD='"+strzero(month(DtIni),2) + str(year(DtIni),4)+"' AND F01.F01_PERRAT > 0 AND F01.F01_FICHA = '1' AND F01.D_E_L_E_T_=' ') "
        
    ElseIF cOpcao == '2F'
        
        oTabCLT     := TABCLT():New()
        cSelect		+= ',CLT.CLT_PEATIC, CLT.CLT_PRDDST, CLT.CLT_INSUMO, CLT.CLT_QTDE '
        cJoin		+="JOIN "+RetSqlName("CLT")+" CLT ON(CLT.CLT_FILIAL='"+xFilial("CLT")+"' AND CLT.CLT_PRDDST=CLR.CLR_PRDMOV AND CLT.CLT_INSUMO=CLR.CLR_PROD AND "
        cJoin  		+= "CLT.CLT_PERIOD >= '" + dTos(DtIni) + "' AND CLT.CLT_PERIOD <= '" + dTos(DtFim) + "' AND CLT.CLT_FICHA = '42' AND  CLT.D_E_L_E_T_=' ')  "
        
    EndIF
    
    cSelect		:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin		:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        nPerConj	:= 0
        nPerRat	:= 0
        
        
        If cOpcao == '2E'
            //Atualiza saída da própria ficha considerando percentual de rateio e total do ICMS e CUSTO gravado no cabecalho da FICHA 2E.
            nCusto		:= (cAliasCLR)->F01_PERRAT * (cAliasCLR)->F04_FATORC /100
            nICMS		:= (cAliasCLR)->F01_PERRAT * (cAliasCLR)->F04_FATORI /100
            nPerRat		:= (cAliasCLR)->F01_PERRAT
            //----------------------
            //Adiciona Fichas 4C
            //----------------------
            AddRateio(oTabCLT,DtIni, (cAliasCLR)->F01_PRODUT, '43', (cAliasCLR)->F01_PERRAT , nCusto ,;
                nICMS, '', 0, 0, 0,0 )
            
        ElseIF cOpcao == '2F'
            
            //o Valor do custo será total do custo de entrada da 2F multiplicado pelo percentual
            nPerConj	:= (cAliasCLR)->CLT_PEATIC
            nCusto		:= (((cAliasCLR)->F04_FATORC * nPerConj)*(cAliasCLR)->CLR_QTDE)/(cAliasCLR)->CLT_QTDE 
            nICMS		:= (((cAliasCLR)->F04_FATORI * nPerConj)*(cAliasCLR)->CLR_QTDE)/(cAliasCLR)->CLT_QTDE


        ElseIF cOpcao == '1C'
            
            //Atualiza saída da própria ficha considerando percentual de rateio e total do ICMS e CUSTO gravado no cabecalho da FICHA 2E.
            nCusto		:= (cAliasCLR)->F01_PERRAT * (cAliasCLR)->F04_FATORC /100
            nICMS		:= (cAliasCLR)->F01_PERRAT * (cAliasCLR)->F04_FATORI /100
            nPerRat		:= (cAliasCLR)->F01_PERRAT
            //----------------------
            //Adiciona Fichas 4A
            //----------------------
            AddRateio(oTabCLT,DtIni, (cAliasCLR)->F01_PRODUT, '41', (cAliasCLR)->F01_PERRAT , nCusto ,;
                nICMS, '', 0, 0, 0,0 )
        Else
            //Atualiza saída da própria ficha
                nCusto	:= (cAliasCLR)->CLR_QTDE * (cAliasCLR)->F04_FATORC
                nICMS	:= (cAliasCLR)->CLR_QTDE * (cAliasCLR)->F04_FATORI   
        EndIF
        
        
        CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
        RecLock('CLR',.F.)
        CLR->CLR_ICMS      := nICMS
        CLR->CLR_UICMS     := CLR->CLR_ICMS/(cAliasCLR)->CLR_QTDE
        CLR->CLR_CUSTO     := nCusto
        CLR->CLR_UCUSTO    := CLR->CLR_CUSTO/(cAliasCLR)->CLR_QTDE
        CLR->CLR_PERCCJ    := nPerConj //Percentual em Conjunto
        CLR->CLR_PERRAT    := nPerRat
        CLR->(MsUnLock())

        IF (cAliasCLR)->CLR_TPRD == 'RE4'
            CLR->(dbSetOrder(6)) // CLR->(dbSetOrder(8))
             //Atualiza a entrada na ficha destino.
            If CLR->(MsSeek(xFilial("CLR") + DTOS((cAliasCLR)->CLR_PERIOD) + (cAliasCLR)->CLR_NUMSEQ + 'RE4' + 'E'))
                    RecLock('CLR',.F.)
                    CLR->CLR_ICMS   := nICMS
                    CLR->CLR_UICMS  := CLR->CLR_ICMS/CLR->CLR_QTDE
                    CLR->CLR_CUSTO  := nCusto
                    CLR->CLR_UCUSTO := CLR->CLR_CUSTO/CLR->CLR_QTDE
                    CLR->(MsUnLock())  
            EndIF
        Else
            CLR->(dbSetOrder(3))//CLR->(dbSetOrder(7))
            //Atualiza a entrada na ficha destino.
            If CLR->(MsSeek(xFilial("CLR") + DTOS((cAliasCLR)->CLR_PERIOD) + str((cAliasCLR)->CLR_NRLAN,9) + Alltrim((cAliasCLR)->CLR_CODORI)+'D'))
                RecLock('CLR',.F.)
                CLR->CLR_ICMS   := nICMS
                CLR->CLR_UICMS  := CLR->CLR_ICMS/CLR->CLR_QTDE
                CLR->CLR_CUSTO  := nCusto
                CLR->CLR_UCUSTO := CLR->CLR_CUSTO/CLR->CLR_QTDE
                CLR->(MsUnLock())
            EndIF
        EndiF 

        //Atualiza Cabecalho
        nPos:= aScan (aIdProc, {|aX| aX[1]==(cAliasCLR)->CLR_IDCAB})
        
        If nPos == 0
            aAdd(aIdProc,{})
            nPos := Len (aIdProc)
            aAdd(aIdProc[nPos],(cAliasCLR)->CLR_IDCAB )
            
            If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
                RecLock('F04',.F.)
                
                IF (cAliasCLR)->F04_FATORC > 0 .OR. (cAliasCLR)->F04_FATORI > 0 .Or. ((cAliasCLR)->CLR_TPRD == 'RE5' .And.  (cAliasCLR)->CLR_QTDE == 0)
                    
                    F04->F04_PROC       :=  '2' // Altera para não processar mais a ficha
                    F04->F04_STATUS     :=  '1' // Indica que a ficha foi concluída.
                    F04->F04_OBSER      := 	''
                Else
                    F04->F04_PROC		:=  '2' // Altera para não processar mais a ficha
                    F04->F04_STATUS		:=  '2' //Não foi concluída
                    F04->F04_OBSER		:= 	'Fator de ICMS e Custo estão zerados.'
                EndIF
                F04->(MsUnLock())
            EndIF
            
        EndIF
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    //Atualiza as linhas da CLR referente a devolução
    AtuEstProd(mv_par01,mv_par02)
    
    If cOpcao $ '2E/2F'
        FreeObj(oTabCLT)
        oTabCLT:= nil
    EndIF
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Atu5A()

Função que irá fazer atualização dos valores da ficha 5A já gravada.
Verificar as saídas das Fichas 2A, 2B e 2G.

@param cPeriodo

@author Erick G. Dias
@since 03/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Atu5A(DtIni, DtFim, cFicha )
    
    Local cAliasCLR	:= ''
    Local oTabCLU		:= TABCLU():New()
    Local aProd5A		:= {}
    Local nQtdInsu	:= 0
    Local nQtdeIProd	:= 0
    Local nCustUnit	:= 0
    Local nTotInsumo	:= 0
    Local nIcmsunit	:= 0
    Local nTotIcms	:= 0
    Local nQtdIEst	:= 0	//Quantidade de Insumo estornado
    Local nQtdPEst	:= 0	//Quantidade de Produto Elaborado estornado
    Local nICMS		:= 0
    Local nCusto		:= 0
    Local lAPPROD		:=  CLU->(ColumnPos("CLU_APPROD"))>0
    Local aInsumo		:= {}
    Local nPos5A		:= 0
    Local nPos		:= 0
    Local DtIniAnt	:= FirstDay(FirstDay(DtIni)-1)
    Local DtFimAnt	:= LastDay(FirstDay(DtFim)-1)
    
    dbSelectArea('CLU')
    CLU->(dbSetOrder(1))
    F04->(dbSetOrder(2))
    cAliasCLR	:=	GetNextAlias()
    
    cSelect 	:=	"SUM((CASE WHEN CLR.CLR_TPMOV ='S' THEN CLR.CLR_QTDE ELSE 0 END)) as CLR_QTDE, SUM((CASE WHEN CLR.CLR_TPMOV ='D' THEN CLR.CLR_QTDE ELSE 0 END)) as QTDEEST,"
    cSelect 	+=  "CLR.CLR_IDCAB, F04.F04_PROD, F04.F04_FICHA "
    cWhere		:=	"F04.F04_FILIAL='"+xFilial("F04")+"' AND "
    cWhere		+=	"F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
    
    cWhere		+=  ""

    cWhere		+=  "F04.F04_PROC = '1' AND F04.F04_STATUS = '2'  AND  "

        
    cWhere		+=  "F04.F04_FICHA IN ('21','22','23','26','27')  AND   "
    
    cJoin  := "LEFT JOIN "+RetSqlName("CLR")+" CLR ON(CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND Substring(CLR.clr_tprd, 1, 2)  <> 'DE'   AND "
    cJoin  += "CLR.CLR_PERIOD >= '" + dTos(DtIni) + "' AND CLR.CLR_PERIOD <= '" + dTos(DtFim) + "' AND  CLR.CLR_FICHA IN " +cFicha + " AND  CLR.D_E_L_E_T_=' ')  "
    
    cGroupBy	:=	 "GROUP BY CLR.CLR_IDCAB, F04.F04_PROD, F04.F04_FICHA "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:F04% F04
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        aAdd(aProd5A,{})
        nPos := Len (aProd5A)
        aAdd(aProd5A[nPos],(cAliasCLR)->F04_PROD )
        aAdd(aProd5A[nPos],'' )
        aAdd(aProd5A[nPos],(cAliasCLR)->CLR_QTDE - (cAliasCLR)->QTDEEST)
        aAdd(aProd5A[nPos],0)
        aAdd(aProd5A[nPos],0)
        aAdd(aProd5A[nPos],(cAliasCLR)->CLR_IDCAB)
        aAdd(aProd5A[nPos],(cAliasCLR)->F04_FICHA)
        
        //Atualia o cabecalho da 2A,2B,2C ou 2G com quantidade produzida
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
            RecLock('F04',.F.)
            
            F04->F04_QTDE	:= (cAliasCLR)->CLR_QTDE - (cAliasCLR)->QTDEEST
            
            F04->(MsUnLock())
        EndIF
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    //Agora procuro todos insumos requisitados nas fichas 2A/2B/2G
    
    cAliasCLR	:=	GetNextAlias()
    cSelect     := "SUM((CASE WHEN CLR_TPMOV IN('E','H') THEN CLR_QTDE ELSE 0 END))-SUM(CASE WHEN CLR_TPMOV IN('J') THEN CLR_QTDE ELSE 0 END)  CLR_QTDE, "
    cSelect   += "SUM((CASE WHEN CLR_TPMOV IN('E','H') THEN CLR_ICMS ELSE 0 END))-SUM(CASE WHEN CLR_TPMOV IN('J')   THEN CLR_ICMS ELSE 0 END)  CLR_ICMS, "  
    cSelect   += "SUM((CASE WHEN CLR_TPMOV IN('E','H') THEN CLR_CUSTO ELSE 0 END))-SUM(CASE WHEN CLR_TPMOV IN('J')  THEN CLR_CUSTO ELSE 0 END)  CLR_CUSTO, "
    cSelect   += "F04.F04_PROD,F04.F04_FICHA,  CLR.CLR_UNID, CLR.CLR_PRDMOV, CLR.CLR_PERIOD, CLR.CLR_IDCAB"
    cWhere		:=	"F04.F04_FILIAL='"+xFilial("F04")+"' AND "
    
    cWhere		+=	"F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
  
    cWhere		+=  "F04.F04_PROC = '1' AND F04.F04_STATUS = '2'  AND "
    
    cWhere    +=  "F04.F04_FICHA IN ('21','22','23','27') AND "    
    
    cJoin  := "JOIN "+RetSqlName("CLR")+" CLR ON(CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "CLR.CLR_PERIOD >= '" + dTos(DtIni) + "' AND CLR.CLR_PERIOD <= '" + dTos(DtFim) + "' AND CLR.CLR_FICHA IN " +cFicha + " AND  "
    
    cJoin  += "CLR.CLR_TPMOV IN ('E','H','J') AND CLR.CLR_TABMOV <> 'CDU' AND  CLR.D_E_L_E_T_=' ') "

    cGroupBy	:=	 "GROUP BY F04.F04_PROD ,F04.F04_FICHA, CLR.CLR_UNID, CLR.CLR_PRDMOV, CLR.CLR_PERIOD, CLR.CLR_IDCAB "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:F04% F04
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
	Do While !(cAliasCLR)->(Eof ())
	
		nPos:= aScan (aInsumo, {|aX| aX[1]==(cAliasCLR)->F04_PROD .AND. aX[2] == (cAliasCLR)->CLR_PRDMOV .AND. aX[6] == (cAliasCLR)->F04_FICHA})
		
		IF nPos == 0
			aAdd(aInsumo,{})
			nPos := Len (aInsumo)
			aAdd(aInsumo[nPos],(cAliasCLR)->F04_PROD 		)//Produto elaborado
			aAdd(aInsumo[nPos],(cAliasCLR)->CLR_PRDMOV 	)//Insumo utilizado
			aAdd(aInsumo[nPos],(cAliasCLR)->CLR_ICMS		)//valor do ICMS
			aAdd(aInsumo[nPos],(cAliasCLR)->CLR_CUSTO		)//Valor do custo
			aAdd(aInsumo[nPos],(cAliasCLR)->CLR_QTDE 		)//Quantidade 
			aAdd(aInsumo[nPos],(cAliasCLR)->F04_FICHA     )//Ficha
		Else
			aInsumo[nPos][3]	+= (cAliasCLR)->CLR_ICMS
			aInsumo[nPos][4]	+= (cAliasCLR)->CLR_CUSTO
			aInsumo[nPos][5]	+= (cAliasCLR)->CLR_QTDE  
		EndIF
				
    
        (cAliasCLR)->(DbSkip ())
    EndDo

    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())

	//buscar valores da CLU
	cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"F04.F04_PROD, F04.F04_FICHA, CLU.CLU_PRDINS, SUM(CLU.CLU_QTDINS) AS CLU_QTDINS, SUM(CLU.CLU_VALICM) AS CLU_VALICM , SUM(CLU.CLU_VALCUS) AS CLU_VALCUS "
    cWhere		:=	"F04.F04_FILIAL='"+xFilial("F04")+"' AND "
    cWhere		+=	"F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
  
    cWhere		+=  "F04.F04_PROC = '1' AND F04.F04_STATUS = '2'  AND  F04.F04_FICHA IN ('21','22','23','27') AND "
     
    cJoin  := "JOIN "+RetSqlName("CLU")+" CLU ON(CLU.CLU_FILIAL='"+xFilial("CLU")+"' AND CLU.CLU_PROD=F04.F04_PROD  AND CLU.CLU_FICHA = F04.F04_FICHA AND "
    
    cJoin  += "CLU.CLU_PERIOD >= '" + dTos(DtIni) + "' AND CLU.CLU_PERIOD <= '" + dTos(DtFim) + "' AND CLU.CLU_APPROD = '2' AND  CLU.D_E_L_E_T_=' ')  "
    
    cGroupBy	:=	 "GROUP BY F04.F04_PROD, F04.F04_FICHA, CLU.CLU_PRDINS "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:F04% F04
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
   DbSelectArea (cAliasCLR)
    
	Do While !(cAliasCLR)->(Eof ())
	
		nPos:= aScan (aInsumo, {|aX| aX[1]==(cAliasCLR)->F04_PROD .AND. aX[2] == (cAliasCLR)->CLU_PRDINS .AND. aX[6] == (cAliasCLR)->F04_FICHA })
		
		IF nPos == 0
			aAdd(aInsumo,{})
			nPos := Len (aInsumo)
			aAdd(aInsumo[nPos],(cAliasCLR)->F04_PROD 		)//Produto elaborado
			aAdd(aInsumo[nPos],(cAliasCLR)->CLU_PRDINS 	)//Insumo utilizado
			aAdd(aInsumo[nPos],(cAliasCLR)->CLU_VALICM	)//valor do ICMS
			aAdd(aInsumo[nPos],(cAliasCLR)->CLU_VALCUS	)//Valor do custo
			aAdd(aInsumo[nPos],(cAliasCLR)->CLU_QTDINS	)//Quantidade
			aAdd(aInsumo[nPos],(cAliasCLR)->F04_FICHA     )//Ficha
		Else
			aInsumo[nPos][3]	+= (cAliasCLR)->CLU_VALICM
			aInsumo[nPos][4]	+= (cAliasCLR)->CLU_VALCUS
			aInsumo[nPos][5]	+= (cAliasCLR)->CLU_QTDINS
		EndIF
				
    
        (cAliasCLR)->(DbSkip ())
    EndDo

    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())

	//Caso for o primeiro mês de entrega do arquivo não terá ficha técnica para discriminar o saldo do período anterior, por este motivo irei até
	//tabela de inventário CLV para considerar também os saldos iniciais.
	If mv_par04 == 1
	
		cAliasCLR	:=	GetNextAlias()
	    cSelect 	:=	"F04.F04_PROD, F04_FICHA, CLV.CLV_PRDINS, SUM(CLV.CLV_QUANT) AS CLV_QUANT, SUM(CLV.CLV_VALICM) AS CLV_VALICM , SUM(CLV.CLV_VALCUS) AS CLV_VALCUS "
	    cWhere		:=	"F04.F04_FILIAL='"+xFilial("F04")+"' AND "
	    cWhere		+=	"F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
	    cWhere		+=	"F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
	  
	    cWhere		+=  "F04.F04_PROC = '1' AND F04.F04_STATUS = '2'  AND  F04.F04_FICHA IN ('21','22','23','27') AND "
	     
	    cJoin  := "JOIN "+RetSqlName("CLV")+" CLV ON(CLV.CLV_FILIAL='"+xFilial("CLV")+"' AND CLV.CLV_PROD=F04.F04_PROD AND "
	    cJoin  += "CLV.CLV_PERIOD >= '" + dTos(DtIniAnt) + "' AND CLV.CLV_PERIOD <= '" + dTos(DtFimAnt) + "' AND  CLV.D_E_L_E_T_=' ')  "
	    
	    cGroupBy	:=	 "GROUP BY F04.F04_PROD, F04_FICHA, CLV.CLV_PRDINS "
	    
	    cSelect	:= '%'+cSelect+'%'
	    cWhere		:= '%'+cWhere+'%'
	    cJoin	:= '%'+cJoin+'%'
	    cGroupBy	:= '%'+cGroupBy+'%'
	    
	    BeginSql Alias cAliasCLR
	        COLUMN CLR_PERIOD AS DATE
	        SELECT
	        %Exp:cSelect%
	        
	        FROM
	        %Table:F04% F04
	        %Exp:cJoin%
	        WHERE
	        %Exp:cWhere%
	        F04.%NotDel%
	        %Exp:cGroupBy%
	        
	    EndSql
	    
	   DbSelectArea (cAliasCLR)
	    
		Do While !(cAliasCLR)->(Eof ())
		
			nPos:= aScan (aInsumo, {|aX| aX[1]==(cAliasCLR)->F04_PROD .AND. aX[2] == (cAliasCLR)->CLV_PRDINS .AND. aX[6] == (cAliasCLR)->F04_FICHA})
			
			IF nPos == 0
				aAdd(aInsumo,{})
				nPos := Len (aInsumo)
				aAdd(aInsumo[nPos],(cAliasCLR)->F04_PROD 		)//Produto elaborado
				aAdd(aInsumo[nPos],(cAliasCLR)->CLV_PRDINS 	)//Insumo utilizado
				aAdd(aInsumo[nPos],(cAliasCLR)->CLV_VALICM	)//valor do ICMS
				aAdd(aInsumo[nPos],(cAliasCLR)->CLV_VALCUS	)//Valor do custo
				aAdd(aInsumo[nPos],(cAliasCLR)->CLV_QUANT	)//Quantidade
				aAdd(aInsumo[nPos],(cAliasCLR)->F04_FICHA     )//Ficha
			Else
				aInsumo[nPos][3]	+= (cAliasCLR)->CLV_VALICM
				aInsumo[nPos][4]	+= (cAliasCLR)->CLV_VALCUS
				aInsumo[nPos][5]	+= (cAliasCLR)->CLV_QUANT
			EndIF
					
	    
	        (cAliasCLR)->(DbSkip ())
	    EndDo
	
	    DbSelectArea (cAliasCLR)
	    (cAliasCLR)->(DbCloseArea())

	
	EndIF
    
    For nPos 	:= 1 to Len(aInsumo)
        //Deverá buscar linha correspondente
                
        nPos5A:= aScan (aProd5A, {|aX| aX[1]==aInsumo[nPos][1] .And. aX[7] == aInsumo[nPos][6]}) //Busca o produto elaborado
                
        nQtdInsu		:= 0
        nQtdeIProd	:= 0
        nCustUnit		:= 0
        nTotInsumo	:= 0
        nIcmsunit		:= 0
        nTotIcms		:= 0
        nICMS			:= 0
        nCusto		:= 0
        nQtdIEst		:= 0
        
        //Se encontrar produto elaborado então irá atualizar o valor
        IF nPos5A >0          
	                               
            nQtdInsu	:= aInsumo[nPos][5] //Quantidade de Insumo            
            nICMS		:= aInsumo[nPos][3] //Icms do Insumo
            nCusto	:= aInsumo[nPos][4] //Custo do Insumo
            
            nQtdeIProd	:=  nQtdInsu/aProd5A[nPos5A][3] //Quantidade de Insumo / Quantidade produzida.
            nCustUnit	:=  nCusto / nQtdInsu // Valor do custo do Insumo dividido pela quantidade de Insumo
            nTotInsumo	:=  nQtdeIProd * nCustUnit //Quantidade de Insumo por unidade de produto multiplicado pelo custo unitário.
            nIcmsunit	:=  nICMS / nQtdInsu //Valor do ICMS do Insumo dividido pela quantidade de Insumo
            nTotIcms	:=  nQtdeIProd * nIcmsunit	//Quantidade de Insumo por unidade de produto multiplicado pelo ICMS unitário.
            
            aProd5A[nPos5A][4]	:= nTotInsumo
            aProd5A[nPos5A][5]	:= nTotIcms
                
            AddFicha5A(oTabCLU, DtIni, aInsumo[nPos][1], aInsumo[nPos][2], aProd5A[nPos5A][2],;
                aProd5A[nPos5A][3], nQtdInsu, nQtdeIProd, nTotInsumo, nCusto,;
                nTotIcms, nICMS,0,Iif(aProd5A[nPos5A][3] > 0 ,'1','2'),.T., aProd5A[nPos5A][7])               
            
            //Atualiza Ficha Cabecalho
            //Deve ir no cabecalho e atualizar o valor de MMPF de ICMS e Custo
            If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ aProd5A[nPos5A][6]))
                RecLock('F04',.F.)
                
                    F04->F04_FATORI	+= nTotIcms
                    F04->F04_FATORC	+= nTotInsumo
                
                F04->(MsUnLock())
            EndIF
            
        EndIF
        
    Next nPos5A
   
    FreeObj(oTabCLU)
    oTabCLU:= nil
    
Return aProd5A


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuMod6()

Função que irá atualizar o valor do crédito acumulado nas fichas do módulo 6.

@param cPeriodo

@author Erick G. Dias
@since 04/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AtuMod6(DtIni, DtFim)
    
    Local nTotICMS	:= 0
    Local nCrdAcum	:= 0
    Local nIcmsDev	:= 0
    
    CLR->(dbSetOrder(3))//CLR->(dbSetOrder(7))
    F04->(dbSetOrder(2))
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"CLR.CLR_PRDMOV, CLR.CLR_FICHA, CLR.CLR_ICMS, CLR.CLR_VCROUT, CLR.CLR_VCRDSP, CLR.CLR_VCRCOM, CLR.CLR_ICMCMP, CLR.CLR_CROUST, CLR.CLR_ICMDEB, CLR.CLR_IDCAB, CLR.CLR_PERIOD, CLR.CLR_NRLAN, CLR.CLR_CODORI, CLR.CLR_COMOPE,CLR.CLR_DESPAC, CLR.CLR_CUSTO,CLR.CLR_QTDE, CLR.R_E_C_N_O_ as CLRRECNO"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_TPMOV = 'E' AND CLR.CLR_FICHA IN ('61','62','63','64','65','66','67','68') AND "
    cWhere		+=	"F04.F04_PROC = '1' AND F04.F04_STATUS = '2'  AND "
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
    EndSql
    
    Do While !(cAliasCLR)->(Eof ())
        
        nTotICMS	:= 0
        nCrdAcum	:= 0
        nIcmsDev	:= 0
        
        //ABAIXO IRÁ ATUALIZAR OS VALORES DAS FICHAS 6.
        CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
        RecLock('CLR',.F.)
        
        If (cAliasCLR)->CLR_FICHA $ '61/62' // 6A e 6B
            nTotICMS := (cAliasCLR)->(CLR_ICMS + CLR_VCROUT + CLR_VCRDSP)
            nCrdAcum	:= nTotICMS -  (cAliasCLR)->CLR_ICMDEB
        ElseIf (cAliasCLR)->CLR_FICHA == '63' //6C
            //CONOUT()
            If (cAliasCLR)->CLR_COMOPE == '1'
                CLR->CLR_ICMCMP	:= (cAliasCLR)->CLR_ICMS //Atribui o valor do ICMS na coluna do ICMS COmprovado
            EndIF
            nCrdAcum := (cAliasCLR)->(CLR_VCROUT + CLR_VCRDSP + CLR_VCRCOM) + CLR->CLR_ICMCMP
        ElseIf (cAliasCLR)->CLR_FICHA == '64' //6D
            
            CLR->CLR_ICMCMP	:=(cAliasCLR)->CLR_ICMS //Atribui o valor do ICMS na coluna do ICMS COmprovado
            
            nCrdAcum := (cAliasCLR)->(CLR_VCROUT + CLR_VCRDSP) + CLR->CLR_ICMCMP//CLR_ICMCMP)
            
        ElseIf (cAliasCLR)->CLR_FICHA == '65' //6E
            nCrdAcum := (cAliasCLR)->(CLR_ICMS + CLR_VCROUT + CLR_VCRDSP)
            
        ElseIf (cAliasCLR)->CLR_FICHA == '66' //6F
            nTotICMS 	:= (cAliasCLR)->(CLR_ICMS + CLR_VCROUT + CLR_VCRDSP)
            nIcmsDev	:= (cAliasCLR)->CLR_ICMDEB - nTotICMS
            
        ElseIf (cAliasCLR)->CLR_FICHA == '67' //6G
            
            nCrdAcum	:=(cAliasCLR)->CLR_CROUST
            nIcmsDev := (cAliasCLR)->(CLR_ICMDEB - CLR_VCROUT)
            
        ElseIf (cAliasCLR)->CLR_FICHA == '68' //6H
            nCrdAcum	:=(cAliasCLR)->(CLR_ICMS - CLR_ICMDEB)
            nIcmsDev := (cAliasCLR)->(CLR_ICMDEB - CLR_ICMS)
        EndIF
        
        CLR->CLR_UICMS  := (cAliasCLR)->CLR_ICMS/(cAliasCLR)->CLR_QTDE
        CLR->CLR_UCUSTO  := (cAliasCLR)->CLR_CUSTO/(cAliasCLR)->CLR_QTDE
        CLR->CLR_TOTICM	:=	nTotICMS
        CLR->CLR_CREDAC	:= nCrdAcum
        CLR->CLR_ICMSDE	:= nIcmsDev
        CLR->(MsUnLock())
        
        
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
        //If F04->(MsSeek("02      "+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
            RecLock('F04',.F.)
            F04->F04_PROC       :=  '2' // Altera para não processar mais a ficha
            F04->F04_STATUS     :=  '1' // Indica que a ficha foi concluída.
            F04->(MsUnLock())
        EndIF
        
        //Atualiza o valor do crédito acumulado na saída (origem)
        If nCrdAcum > 0 .AND. CLR->(MsSeek(xFilial("CLR") + DTOS((cAliasCLR)->CLR_PERIOD) + str((cAliasCLR)->CLR_NRLAN,9) + Alltrim((cAliasCLR)->CLR_CODORI)+'O'))
        //If nCrdAcum > 0 .AND. CLR->(MsSeek("02      " + DTOS((cAliasCLR)->CLR_PERIOD) + str((cAliasCLR)->CLR_NRLAN,9) + Alltrim((cAliasCLR)->CLR_CODORI)+'O'))
            RecLock('CLR',.F.)
            CLR->CLR_CREDAC	:=	nCrdAcum
            CLR->(MsUnLock())
        EndIF
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSldFin()
Função que irá processar os valores de saldos finais na tabela CDU.
Fichas sem saldo inicial = 13,14,15,24,25,26,27,61,62,63,64,65,66,67,68.

@author Flavio Luiz Vicco
@since 04/06/2015
@version 11.80d
/*/
//-------------------------------------------------------------------
Function ProcSldFin(dDtIni,dDtAte)
    
    Local cAlias  := ""
    Local dDtPrx  := lastday(dDtAte)+1
    Local nSldQtd := 0
    Local nSldICM := 0
    Local nSldCus := 0
    Local nLim    := aParSX6[MV_LIMSLDF]
    Local nDif    := 0
    
    
    ProcLogAtu("MENSAGEM","Início Atualização dos saldos das fichas - Filial " + FWGETCODFILIAL + " " + Time())
    DbSelectArea("CDU")
    
    cAlias := GetNextAlias()
    
    BeginSql Alias cAlias
        SELECT
        CLR_PERIOD, CLR_FICHA, F04_PROD AS PRODUTO,
        SUM(CASE WHEN CLR.CLR_TPMOV IN ( 'E', 'G', 'Z','I' ) THEN CLR_QTDE  ELSE 0 END) AS QTDEINIE,
        SUM(CASE WHEN CLR.CLR_TPMOV IN ( 'E', 'G', 'Z','I' ) THEN CLR_ICMS  ELSE 0 END) AS ICMSINIE,
        SUM(CASE WHEN CLR.CLR_TPMOV IN ( 'E', 'G', 'Z','I' ) THEN CLR_CUSTO ELSE 0 END) AS CUSTINIE,
        SUM(CASE WHEN CLR.CLR_TPMOV IN ( 'S', 'F','J' ) THEN CLR_QTDE  ELSE 0 END) AS QTDEINIS,
        SUM(CASE WHEN CLR.CLR_TPMOV IN ( 'S', 'F','J' ) THEN CLR_ICMS  ELSE 0 END) AS ICMSINIS,
        SUM(CASE WHEN CLR.CLR_TPMOV IN ( 'S', 'F','J' ) THEN CLR_CUSTO ELSE 0 END) AS CUSTINIS
        FROM
        %Table:CLR% CLR
        INNER JOIN
        %TABLE:F04% F04
        ON (F04.F04_ID = CLR.CLR_IDCAB
        AND F04.F04_FICHA = CLR.CLR_FICHA
        AND F04.F04_FILIAL = %XFILIAL:F04%
        AND F04.%NOTDEL%
        AND F04.F04_PERIOD >= %Exp:dTos(dDtIni)%
        AND F04.F04_PERIOD <= %Exp:dTos(dDtAte)%)
        WHERE 
        CLR.CLR_FILIAL  = %xFilial:CLR% AND
        CLR.CLR_PERIOD >= %Exp:dTos(dDtIni)% AND
        CLR.CLR_PERIOD <= %Exp:dTos(dDtAte)% AND
        CLR.CLR_FICHA NOT IN ('13','14','15','24','25', '26','27','61','62','63','64','65','66','67','68') AND
        CLR.%NotDel%
        GROUP BY
        CLR_PERIOD, CLR_FICHA, F04_PROD
    EndSql
    
    /*O conceito de variação percentual é usado para descrever a relação entre um valor ou 
      quantidade anterior e um valor ou quantidade posterior.
      De modo específico, a variação percentual expressa a diferença entre ambas as quantidades,
      na forma de uma porcentagem relativa ao primeiro valor. Em casos genéricos, nos quais V1 
      representa um valor anterior ou inicial e V2 representa o posterior ou final, a variação 
      percentual pode ser encontrada através da equação ((V2-V1)/V1 × 100)
   */

    Do While !(cAlias)->(Eof())
        nSldQtd := 0
        //Atualiza quantidade somente se não for do módulo 2
        IF (cAlias)->CLR_FICHA$'21|22|23|26'
        
        
            nSldICM := (cAlias)->ICMSINIE-(cAlias)->ICMSINIS
            
            //Verificando se posso zerar o ICMS
            nDif    := (((cAlias)->ICMSINIS-(cAlias)->ICMSINIE)/(cAlias)->ICMSINIE) * 100 
            // Se a diferença encontrada for menor que o limite definido significa que pode ser zerado.
            IF ABS(nDif) <= nLim 
                   nSldICM:= 0
            EndIf
            
            nSldCus := (cAlias)->CUSTINIE-(cAlias)->CUSTINIS

            //Verificando se posso zerar o custo
            nDif    := (((cAlias)->CUSTINIS-(cAlias)->CUSTINIE)/(cAlias)->CUSTINIE) * 100
            // Se a diferença encontrada for menor que o limite definido significa que pode ser zerado.
            IF ABS(nDif) <= nLim 
                    nSldCus:= 0
            EndIf  
        Else

            nSldQtd := (cAlias)->QTDEINIE-(cAlias)->QTDEINIS //Atualiza quantidade somente se não for do módulo 2
                 
            //Verificando se posso zerar a quantidade   
            nDif    := (((cAlias)->QTDEINIS-(cAlias)->QTDEINIE)/(cAlias)->QTDEINIE)* 100
            // Se a diferença encontrada for menor que o limite definido significa que pode ser zerado.
            IF ABS(nDif) <= nLim  
                 nSldQtd:= 0
            EndIf
           
            nSldICM := (cAlias)->ICMSINIE-(cAlias)->ICMSINIS
           
            //Verificando se posso zerar o ICMS
            nDif    := (((cAlias)->ICMSINIS-(cAlias)->ICMSINIE)/(cAlias)->ICMSINIE) * 100
            // Se a diferença encontrada for menor que o limite definido significa que pode ser zerado.
            IF ABS(nDif) <= nLim 
                 nSldICM:= 0
            EndIf

            nSldCus := (cAlias)->CUSTINIE-(cAlias)->CUSTINIS  

           //Verificando se posso zerar o custo
           nDif    := (((cAlias)->CUSTINIS-(cAlias)->CUSTINIE)/(cAlias)->CUSTINIE) * 100
           // Se a diferença encontrada for menor que o limite definido significa que pode ser zerado.
           IF ABS(nDif) <= nLim 
                nSldCus:= 0
           EndIf
        EndIf    

        dbSelectArea("CDU")
        CDU->(dbSetOrder(1)) //CDU_FILIAL+CDU_PERIOD+CDU_FICHA+CDU_PRODUT
        //Gravacao saldos final periodo atual.
        If CDU->(dbseek(xFilial("CDU")+Left(dTos(dDtAte),6)+(cAlias)->CLR_FICHA+(cAlias)->PRODUTO))
            RecLock("CDU",.F.)
        Else
            RecLock("CDU",.T.)
            CDU_FILIAL := xFilial("CDU")
            CDU_PERIOD := Left(dTos(dDtAte),6)
            CDU_FICHA  := (cAlias)->CLR_FICHA
            CDU_PRODUT := (cAlias)->PRODUTO
        EndIf
        
        CDU_QTDPER := nSldQtd
        CDU_QTDFIM := nSldQtd
        CDU_VALICM := nSldICM
        CDU_VALCUS := nSldCus
        CDU->(MsUnLock())
        //Gravacao saldos inicio periodo seguinte.
        If CDU->(dbseek(xFilial("CDU")+Left(dTos(dDtPrx),6)+(cAlias)->CLR_FICHA+(cAlias)->PRODUTO))
            RecLock("CDU",.F.)
        Else
            RecLock("CDU",.T.)
            CDU_FILIAL := xFilial("CDU")
            CDU_PERIOD := Left(dTos(dDtPrx),6)
            CDU_FICHA  := (cAlias)->CLR_FICHA
            CDU_PRODUT := (cAlias)->PRODUTO
        EndIf
        CDU_QTDINI := nSldQtd
        CDU_ICMINI := nSldICM
        CDU_CUSINI := nSldCus
        CDU->(MsUnLock())
        
        (cAlias)->(DbSkip())
    EndDo
    
    DbSelectArea(cAlias)
    (cAlias)->(DbCloseArea())
    
    
    ProcLogAtu("MENSAGEM","Fim Atualização dos saldos das fichas - Filial " + FWGETCODFILIAL + " " + Time())
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TotEnt2E2F()

Função que irá buscar o valor total de ICMS e de Custo das entradas na FICHA 2E
de Gastos Gerais.

@author Erick G Dias
@since 04/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function TotEnt2E2F(DtIni,DtFim,cOpcao)
    
    Local cAliasCLR	:= ''
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM((CASE WHEN CLR.clr_tpmov ='E' THEN CLR.CLR_CUSTO ELSE 0 END)) as CLR_CUSTO, "
    cSelect	+= "SUM((CASE WHEN CLR.clr_tpmov ='E' THEN CLR.CLR_ICMS ELSE 0 END)) as CLR_ICMS,"
    cSelect	+= "SUM((CASE WHEN CLR.clr_tpmov ='E' THEN CLR.clr_qtde ELSE 0 END)) as CLR_QTDE, " //Quantidade de entrada
    cSelect 	+=	"SUM((CASE WHEN CLR.clr_tpmov ='H' THEN CLR.clr_qtde ELSE 0 END)) as QTDEEST,"  //Quantidade que entrou porém foi estornada
    cSelect 	+= "CLR.CLR_IDCAB"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    
    If cOpcao == '2E'
        cWhere		+=  "CLR.CLR_FICHA = '25' AND CLR.CLR_TPMOV = 'E' AND"
    ElseIF cOpcao == '2F'
        cWhere		+=  "CLR.CLR_FICHA = '26' AND CLR.CLR_TPMOV = 'E' AND"
    ElseIF cOpcao == '1C'
        cWhere		+=  "CLR.CLR_FICHA = '13' AND CLR.CLR_TPMOV = 'E' AND"
    EndIF
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cGroupBy	:=	 "GROUP BY CLR.CLR_IDCAB"
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    cGroupBy	:= '%'+cGroupBy+'%
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        //Deve ir no cabecalho e atualizar o valor do somatório do custo e ICMS de entrada para utilizar nas saídas
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
            RecLock('F04',.F.)
            //subtrair valores que fora estornados
            F04->F04_FATORI	:= (cAliasCLR)->CLR_ICMS * (  (   (cAliasCLR)->CLR_QTDE-(cAliasCLR)->QTDEEST   )  /   (cAliasCLR)->CLR_QTDE   )
            F04->F04_FATORC	:= (cAliasCLR)->CLR_CUSTO  * (   (   (cAliasCLR)->CLR_QTDE-(cAliasCLR)->QTDEEST   )  /   (cAliasCLR)->CLR_QTDE   )
            F04->(MsUnLock())    
        EndIF
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Proc5G()

Função que irá fazer gravação dos valores da ficha 5G.

@param cPeriodo

@author Flavio Luiz Vicco
@since 04/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Proc5G(DtIni, DtFim, lFimPer)
    
    Local cAliasCLU := ""
    Local oTabCLV   := TABCLV():New()
    Local nQtdInsu  := 0
    Local nCusto := 0
    Local nIcms := 0
    //Datas ref. periodo anterior
    Local cDtIni    := ''//DToS(FirstDay(DtIni-1))
    Local cDtFim    := ''//DToS(DtIni-1)
    Local cPeriod   := ''
    
    Default lFimPer = .F.
    
    IF lFimPer
        cDtIni    := DToS(FirstDay(DtIni))
        cDtFim    := DToS(DtFim)
        cPeriod   := AnoMes(stod(cDtIni))
    Else
        cDtIni    := DToS(FirstDay(DtIni-1))
        cDtFim    := DToS(DtIni-1)
        cPeriod   := AnoMes(stod(cDtIni))
    EndIf 
    
    dbSelectArea("CLV")
    CLV->(dbSetOrder(1))
    cAliasCLU := GetNextAlias()
    //Procuro todos insumos requisitados nas fichas 2A/2B/2C
    /*
    cSelect   := "SUM(CLR.CLR_QTDE) AS CLR_QTDE, SUM(CLR.CLR_CUSTO) AS CLR_CUSTO, SUM(CLR.CLR_ICMS) AS CLR_ICMS, CLR.CLR_PROD, CLR.CLR_UNID, CLR.CLR_PRDMOV, CLR.CLR_PERIOD"
    cWhere    := "CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere    += "CLR.CLR_PERIOD>='"+cDtIni+"' AND "
    cWhere    += "CLR.CLR_PERIOD<='"+cDtFim+"' AND "
    cWhere    += "CLR.CLR_FICHA IN ('21','22','23') AND CLR.CLR_TPMOV = 'E' AND CLR.CLR_TABMOV <> 'CDU' AND CLR.CLR_PROD <> '' AND CLR.CLR_PRDMOV <> '' AND "
    
    cGroupBy  := "GROUP BY CLR.CLR_PROD, CLR.CLR_UNID, CLR.CLR_PRDMOV, CLR.CLR_PERIOD "
    cSelect   := '%'+cSelect+'%'
    cWhere    := '%'+cWhere+'%'
    
    cGroupBy  := '%'+cGroupBy+'%'*/
    
    BeginSql Alias cAliasCLU
    
        COLUMN CLU_PERIOD AS DATE
        SELECT   CLU.CLU_PROD, 
         CLU.CLU_PRDINS, 
         CLU.CLU_PERIOD, 
         Sum(CLU.CLU_QTDINS)  AS CLU_QTDINS, 
         Sum(CLU.CLU_VALCUS) AS CLU_VALCUS, 
         Sum(CLU.CLU_VALICM)  AS CLU_VALICM 
            FROM     %TABLE:CLU% CLU 
            JOIN     %TABLE:CDU% CDU 
            ON       ( 
                              CDU.CDU_VALICM > 0 
                     AND      CDU.CDU_VALCUS > 0 
                     AND      CDU_FICHA IN ( '21', '22', '23' ) 
                     AND      CDU_PERIOD = %EXP:cPeriod% 
                     AND      CDU.%NOTDEL% 
                     AND      CDU.CDU_FILIAL = %XFILIAL:CDU%
                     AND      CDU.CDU_PRODUT = CLU.CLU_PROD) 
            WHERE    CLU.CLU_FILIAL = %XFILIAL:CLU%
            AND      CLU.CLU_PERIOD >= %EXP:cDtIni%    
            AND      CLU.CLU_PERIOD <= %EXP:cDtFim% 
            AND      CLU.%NOTDEL% 
            GROUP BY CLU.CLU_PROD, 
                     CLU.CLU_PRDINS, 
                     CLU.CLU_PERIOD
    EndSql
    
    DbSelectArea(cAliasCLU)
    
    Do While !(cAliasCLU)->(Eof())
        
        nQtdInsu  := (cAliasCLU)->CLU_QTDINS  //Quantidade de Insumo
        nCusto := (cAliasCLU)->CLU_VALCUS /// nQtdInsu //Valor do custo do Insumo dividido pela quantidade de Insumo
        nIcms := (cAliasCLU)->CLU_VALICM  // nQtdInsu //Valor do ICMS  do Insumo dividido pela quantidade de Insumo
        
        AddFicha5G(oTabCLV, DtIni, (cAliasCLU)->CLU_PROD, (cAliasCLU)->CLU_PRDINS, nQtdInsu, nCusto, nIcms)
        
        (cAliasCLU)->(DbSkip())
    EndDo
    
    DbSelectArea (cAliasCLU)
    (cAliasCLU)->(DbCloseArea())
    
    FreeObj(oTabCLV)
    oTabCLV:= nil
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCdu()
Função que irá pverificar se ficou algum saldo negativo na CDU.

@author Graziele Mendonça Paro
@since 08/09/2015
@version 11.80d
/*/
//-------------------------------------------------------------------
Static Function ProcCdu(dDtIni,dDtAte)
    
    Local cAlias  := ""
    Local cPeriodo  := AnoMes(dDtAte)
    Local lRet    := .T.
    
    ProcLogAtu("MENSAGEM","Início da verificação dos saldos das fichas - Filial " + FWGETCODFILIAL + " " + Time())
    DbSelectArea("CDU")
    
    cAlias := GetNextAlias()
    
    BeginSql Alias cAlias
        SELECT CDU.CDU_PRODUT,
        CDU.CDU_FICHA,
        CDU.CDU_VALICM,
        CDU.CDU_QTDFIM,
        CDU.CDU_VALCUS,
        F04.F04_PROD,
        F04.F04_FICHA,
        F04.F04_STATUS,
        F04.F04_PROC,
        F04.R_E_C_N_O_ F04RECNO
        FROM   %Table:CDU% CDU
        INNER JOIN %Table:F04% F04
        ON( F04.F04_PROD = CDU.CDU_PRODUT
        AND F04.F04_FICHA = CDU.CDU_FICHA
        AND F04.%NOTDEL%
        AND F04.F04_FILIAL = %xFilial:F04%
        AND F04.F04_PERIOD >= %Exp:(dDtIni)%
        AND F04.F04_PERIOD <= %Exp:(dDtIni)% )
        WHERE  CDU.CDU_PERIOD = %Exp:(cPeriodo)%
        AND CDU.%NOTDEL%
        AND CDU.CDU_FILIAL =%xFilial:CDU%
        AND (CDU.CDU_VALICM < 0 OR CDU.CDU_QTDFIM < 0 OR CDU.CDU_VALCUS < 0)
        AND F04.F04_FICHA <> '52'        
        ORDER BY CDU.CDU_PERIOD
    EndSql
    
    Do While !(cAlias)->(Eof())
        lRet    := .F.
        dbSelectArea("F04")
        F04->(dbGoTo((cAlias)->F04RECNO))
        RecLock('F04',.F.)
        F04->F04_PROC   := '2'
        F04->F04_STATUS :=  '2'
        F04->F04_OBSER  := 'Saldo Final Negativo'
        F04->(MsUnLock())
        (cAlias)->(DbSkip())
    EndDo
    
    DbSelectArea(cAlias)
    (cAlias)->(DbCloseArea())
    
    F04->(DbCloseArea())
    
    ProcLogAtu("MENSAGEM","Fim da Verificação dos saldos das fichas - Filial " + FWGETCODFILIAL + " " + Time())
    
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} StatusMod()

Função que irá verificar quais fichas estão ainda incompletas

@author Erick G. Dias
@since 11/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function StatusMod(DtIni,DtFim, cMod)
    
    Local cAliasCLR	:= ''
    Local lRet			:= .F.
    
    F04->(dbSetOrder(2))
    
    cAliasCLR := GetNextAlias()
    cSelect   := "CLR.CLR_IDCAB, F04.F04_PROD, COUNT( CASE WHEN CLR.CLR_ICMS = 0 AND CLR.CLR_CUSTO = 0 AND CLR_TPRD <> 'RE5' "
    
     /*Se for esses códigos, preciso concluir a Ficha, pois são lançamentos manuais mo estoque e que nunca terão custo e ICMS, pois o
	Protheus não possui a funcionalidade "de ajuste de ICMS e Custo" ao ajustar o Estoque*/
    If cMod$"1|1C|2E|3"
    	cSelect   +=  "AND CLR.CLR_CODLAN NOT IN('701116', '701316', '702516','703116', '703216')"
    EndIf	
    
    cSelect   += " Then 1 END ) as PENDENTE"
    cWhere    := "CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere    += "CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere    += "CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere    += "CLR.CLR_TPMOV IN('E') AND F04.F04_STATUS = '2' AND "
    IF cMod == '1'
        //Irá procurar fichas do módulo 1
        cWhere    += "CLR.CLR_FICHA IN ('11','12','14','15')  AND  "
    ElseIF cMod == '2'
        //Irá procurar fichas do módulo 2
        cWhere    += "CLR.CLR_FICHA IN ('21','22','23','27','28')  AND  "
        
    ElseIF cMod == '1C'
        //Irá procurar entradas da ficha 1C
        cWhere    += "CLR.CLR_FICHA IN ('13')  AND "
        
    ElseIF cMod == '2E'
        //Irá procurar entradas da ficha 2E
        cWhere    += "CLR.CLR_FICHA IN ('25')  AND "
        
    ElseIF cMod == '2F'
        //Irá procurar entradas da ficha 2E
        cWhere    += "CLR.CLR_FICHA IN ('26')  AND "
        
    ElseIF cMod == '3'
        cWhere    += "CLR.CLR_FICHA IN ('31','32','33')  AND "
    ElseIF cMod == '6'
        cWhere    += "CLR.CLR_FICHA IN ('61','62','63','64','65','66','67','68') AND "
    ElseIF cMod == '5B'
        cWhere    += "CLR.CLR_FICHA IN ('52') AND "
    EndIF
    
    //Join Com F04
    cJoinCLS  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoinCLS  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    IF cMod == '2F'
        cJoinCLS	+="JOIN "+RetSqlName("CLT")+" CLT ON(CLT.CLT_FILIAL='"+xFilial("CLT")+"' AND CLT.clt_prddst = CLR.CLR_PROD  AND "
        cJoinCLS  += "CLT.CLT_PERIOD >= '" + dTos(DtIni) + "' AND CLT.CLT_PERIOD <= '" + dTos(DtFim) + "' AND CLT.CLT_FICHA = '42' AND  CLT.D_E_L_E_T_=' ')  "
    EndIF
    
    cGroupBy  := "GROUP BY CLR.CLR_IDCAB, F04.F04_PROD Order by PENDENTE "
    cSelect   := '%'+cSelect+'%'
    cWhere    := '%'+cWhere+'%'
    cJoinCLS  := '%'+cJoinCLS+'%'
    cGroupBy  := '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        
        SELECT
        %Exp:cSelect%
        FROM
        %Table:CLR% CLR
        %Exp:cJoinCLS%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
    EndSql
    
    DbSelectArea(cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof())

        IF (cAliasCLR)->PENDENTE == 0
            //Significa que não possui nenhuma linha na ficha pendente, todos estão prontas para processamento
            
            //Utilizar o ID para processar as linhas.
            
            If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
                RecLock('F04',.F.)
                F04->F04_PROC	:=  '1' // Indica que ficha está pronta para iniciar processamento.
                F04->(MsUnLock())
                lRet	:= .T.
            EndIF
            
        Else
            //Significa que existe ao menos uma linha que não está pronta, e como está ordenado por PENDENTE, então não terá mais nenhuma
            //linha pronta, então por este motivo irá sair do loop.
            Exit
        EndIF
        
        (cAliasCLR)->(DbSkip())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return lRet


//Função que diz se deverá ou não continuar processando as fichas dos cabecalhos
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCab()

Função que verifica se ainda existe algum cabecalho que deverá ser processado.
Se todos estiverem concluídos retorna .F., se ainda existir algum retorna .T.

@author Erick G. Dias
@since 12/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function ProcCab(DtIni,DtFim)
    
    Local cAliasF04	:= ''
    Local cSelect		:= ''
    Local cWhere		:= ''
    Local nRet			:= 0
    
    cAliasF04 := GetNextAlias()
    cSelect   := "COUNT(*) As QTDE"
    cWhere    := "F04.F04_FILIAL='"+xFilial("F04")+"' AND "
    cWhere    += "F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere    += "F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere    += "F04.F04_STATUS = '2'AND "
    
    cSelect   := '%'+cSelect+'%'
    cWhere    := '%'+cWhere+'%'
    
    BeginSql Alias cAliasF04
        
        SELECT
        %Exp:cSelect%
        FROM
        %Table:F04% F04
        
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
    EndSql
    
    DbSelectArea(cAliasF04)
    
    Do While !(cAliasF04)->(Eof())
        
        nRet	:= (cAliasF04)->QTDE
        
        (cAliasF04)->(DbSkip())
    EndDo
    
    DbSelectArea (cAliasF04)
    (cAliasF04)->(DbCloseArea())
    
    
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCab()

Função que atualiza status do cabecalho como concluída, pois por alguum motivo não
encontrou a saída porém precisa ser atualizada.

@author Erick G. Dias
@since 12/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function AtuCab(DtIni,DtFim, cObser, cOpcao,lConcluida,lProc)
    
    
    Local cAliasF04		:= ''
    Local cSelect		:= ''
    Local cWhere		:= ''
    Default cOpcao		:= ''
    Default lConcluida	:= .F.
    DEFAULT lProc		:= .F.
    
    cAliasF04 := GetNextAlias()
    cSelect   := "F04.F04_ID"
    cWhere    := "F04.F04_FILIAL='"+xFilial("F04")+"' AND "
    cWhere    += "F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere    += "F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere    += "F04.F04_STATUS = '2' AND F04.F04_PROC = '1' AND "
    
    IF cOpcao == '1' //Considera cabecalho com flag de que deveria ter iniciado o processamento
        cWhere    += "F04.F04_FICHA IN ('11','12','14','15') AND  "
    ElseIF cOpcao == '2'
        cWhere    += "F04.F04_FICHA IN ('15') AND  "
    ElseIF cOpcao == '3'
        cWhere    += "F04.F04_FICHA IN ('14') AND  "
    ElseIF cOpcao == '4'
        cWhere    += "F04.F04_FICHA IN ('26') AND  "
    ElseIF cOpcao == '5'
        cWhere    += "F04.F04_FICHA IN ('13') AND  "
    ElseIF cOpcao == '6'
        cWhere    += "F04.F04_FICHA IN ('21','22','23','24','25','26','27') AND  "
    ElseIF cOpcao == '7'
        cWhere    += "F04.F04_FICHA IN ('31','32','33') AND   "
    ElseIF cOpcao == '8'
        cWhere    += "F04.F04_FICHA IN ('52') AND   "
    EndIF
    
    cSelect   := '%'+cSelect+'%'
    cWhere    := '%'+cWhere+'%'
    
    BeginSql Alias cAliasF04
        
        SELECT
        %Exp:cSelect%
        FROM
        %Table:F04% F04
        
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
    EndSql
    
    DbSelectArea(cAliasF04)
    
    Do While !(cAliasF04)->(Eof())
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasF04)->F04_ID))
            RecLock('F04',.F.)
            If lConcluida
                F04->F04_STATUS	:=  '1' // Indica que a ficha foi concluída.
            EndIF
            IF lProc
                F04->F04_PROC		:=  '2' // Altera para não processar mais a ficha
            EndIF
            F04->F04_OBSER	:=  cObser // Grava observação na ficha
            F04->(MsUnLock())
        EndIF
        
        (cAliasF04)->(DbSkip())
    EndDo
    
    DbSelectArea (cAliasF04)
    (cAliasF04)->(DbCloseArea())
    
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ExitFicha()

Função que verifica se alguma linha foi gravada em alguma ficha, retorna o número de lançamento
e código da ficha de destino

@author Erick G. Dias
@since 16/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ExitFicha(DtIni, cProd, cPrdMov, cTpMov, cCodLan,cFicha)
    
    Local 	aRet	:= {}
    Local 	nPos	:= 0
    
    CLR->(dbSetOrder(4))//CLR->(dbSetOrder(5))
    
    //Verifica se já existe alguma linha com movimentação
    If CLR->(MsSeek(xFilial("CLR")+ DTOS(DtIni)+ cProd + cPrdMov + cCodLan + cTpMov + cFicha ))
    	
        aAdd(aRet,{})
        nPos := Len (aRet)
        aAdd(aRet[nPos],CLR->CLR_NRLAN )
        aAdd(aRet[nPos],CLR->CLR_CODORI )
        
    EndIF
    
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Proc4B()

Função que irá processar ficha 4B para poder posteriormente processar as saídas
da ficha 2F.

@author Erick G. Dias
@since 16/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Proc4B(DtIni,DtFim)
    
    Local nTotValPrj	:= 0 //Valor total projetado das saídas
    Local nValPrj		:= 0 //Valor Por ficha 4B
    Local nPerc		:= 0
    Local cAliasCLR	:= ''
    Local cPercentual:= ''
    Local oTabCLT       := TABCLT():New()
    Local aTotPRj		:= {}
    Local nPos			:= 0
    
    ProcLogAtu("MENSAGEM","Início Processamento ficha 4B - Filial " + FWGETCODFILIAL + " " + Time())
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM(CLR.CLR_QTDE) AS CLR_QTDE, CLR.CLR_PROD, F04.F04_PROD, F01.F01_PRCM, CLR.CLR_IDCAB"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_FICHA = '26' AND CLR.CLR_TPMOV = 'S' AND "
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND    "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cJoin  += "JOIN "+RetSqlName("F01")+" F01 ON(F01.F01_FILIAL='"+xFilial("F01")+"' AND F01.F01_PRODUT=CLR.CLR_PROD AND "
    cJoin  += "F01.F01_PERIOD='"+strzero(month(DtIni),2) + str(year(DtIni),4)+"' AND F01.F01_PRCM > 0 AND F01.F01_FICHA = '2'  AND F01.D_E_L_E_T_=' ') "
    
    cGroupBy	:=	 "GROUP BY  CLR.CLR_IDCAB, F04.F04_PROD, F01.F01_PRCM ,CLR.CLR_PROD"
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    cGroupBy	:= '%'+cGroupBy+'%
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        //----------------
        //GRAVA FICHA 4B
        //----------------
        nValPrj	:= (cAliasCLR)->CLR_QTDE *(cAliasCLR)->F01_PRCM
        
        AddRateio(oTabCLT, DtIni,(cAliasCLR)->F04_PROD, '42', 0, 0,;
            0, (cAliasCLR)->CLR_PROD, (cAliasCLR)->CLR_QTDE, ;
            (cAliasCLR)->F01_PRCM, nValPrj , ;
            0 )
        
        //Guarda abaixo o valor totalizando para poder fazer a proporção posteriormente
        nPos:= aScan (aTotPRj, {|aX| Alltrim(aX[1])==Alltrim((cAliasCLR)->F04_PROD)})
        If nPos == 0
            aAdd(aTotPRj,{})
            nPos := Len (aTotPRj)
            aAdd(aTotPRj[nPos],Alltrim((cAliasCLR)->F04_PROD) )
            aAdd(aTotPRj[nPos],nValPrj )
        Else
            aTotPRj[nPos][2] += nValPrj
        EndIF
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    //-------------------------------------------
    //Irá atualizar a tabela CLT com o percentual
    //-------------------------------------------
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"CLT.CLT_PRDDST, CLT.CLT_VLPRJS, CLT.R_E_C_N_O_ as CLTRECNO "
    cWhere		:=	"CLT.CLT_FILIAL='"+xFilial("CLT")+"' AND "
    cWhere		+=	"CLT.CLT_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLT.CLT_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLT.CLT_FICHA = '42'AND"
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLT% CLT
        WHERE
        %Exp:cWhere%
        CLT.%NotDel%
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        nTotValPrj	:= 0
        nPos:= aScan (aTotPRj, {|aX| Alltrim(aX[1])==Alltrim((cAliasCLR)->CLT_PRDDST)})
        If nPos > 0
            nTotValPrj	:= aTotPRj[nPos][2]
        EndIF
        
        //Agora deverá atualizar a ficha 4B, pois somente agora temos o nTotValPrj atualizado.
        nPerc	:= ((cAliasCLR)->CLT_VLPRJS / nTotValPrj) 
        CLT->(dbGoTo((cAliasCLR)->CLTRECNO))
        RecLock('CLT',.F.)
        CLT->CLT_PEATIC	:=	nPerc //Atualiza percentual na ficha 4B
        CLT->(MsUnLock())
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    //Verifica se os percentuais resultaram em 100%
    
    cPercentual   :=  GetNextAlias()
    BeginSql Alias cPercentual
        SELECT CLT.CLT_PRDDST,SUM(CLT.CLT_PEATIC) AS PERCENTUAL
        FROM
        %Table:CLT% CLT
        WHERE
        %Exp:cWhere%
        CLT.%NotDel%
        GROUP BY CLT.CLT_PRDDST
    EndSql
    
    DbSelectArea (cPercentual)
    
    Do While !(cPercentual)->(Eof ())
        IF (cPercentual)->PERCENTUAL <> 1
            //CLT_FILIAL+DTOS(CLT_PERIOD)+CLT_FICHA+CLT_PRDDST
            CLT->(dbSetOrder(1))
            IF CLT->(MsSeek(xFilial("CLT")+ dTos(mv_par01)+ "42" + (cPercentual)->CLT_PRDDST))
                RecLock('CLT',.F.)
                IF (cPercentual)->PERCENTUAL < 1
                    CLT->CLT_PEATIC +=  (1 - (cPercentual)->PERCENTUAL) 
                Elseif (cPercentual)->PERCENTUAL > 1
                    CLT->CLT_PEATIC -=  ((cPercentual)->PERCENTUAL - 1)
                EndIf    
                CLT->(MsUnLock())
            EndIf
        EndIf    
    
    (cPercentual)->(DbSkip ())
    EndDo
 
    FreeObj(oTabCLT)
    oTabCLT:= nil
    
    ProcLogAtu("MENSAGEM","Fim Processamento ficha 4B - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Sai2FCLT()

Função que verifica se todas as saídas da ficha 2F estão devidamente
cadastradas na CLT, é necessário que todos os produtos da saída estejam cadastrados
na tabela F01 para poder gravar CLT(4B)

@author Erick G. Dias
@since 16/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Sai2FCLT(DtIni,DtFim)
    
    Local lRet			:= .F.
    Local cAliasCLR	:= ''
    
    
    F04->(dbSetOrder(2))
    cAliasCLR	:=	GetNextAlias()
    
    cSelect   := "COUNT (CLT.CLT_FICHA) as QTDECLT, COUNT(CLR.CLR_FICHA) as QTDECLR, CLR.CLR_IDCAB "
    
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_FICHA = '26' AND CLR.CLR_TPMOV = 'S' AND F04.F04_PROC = '1' AND F04.F04_STATUS = '2' AND "
    
    cJoin  := "LEFT JOIN "+RetSqlName("CLT")+" CLT ON(CLT.CLT_FILIAL='"+xFilial("CLT")+"' AND CLT.CLT_INSUMO = CLR.CLR_PROD AND "
    cJoin  += "CLT.CLT_PERIOD >= '" + dTos(DtIni) + "' AND CLT.CLT_PERIOD <= '" + dTos(DtFim) + "' AND CLT.CLT_FICHA = '42' AND  CLT.D_E_L_E_T_=' ')  "
    
    cJoin  += "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND    "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cGroupBy	:=	 "GROUP BY CLR.CLR_IDCAB "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        //Se a quantidade de produtos cadastrados na 4C for maior ou igual a quantidade da saída destes produtos na CLR, significa que está pronta para processar
        //Se a quantidade da CLT for menor que CLR, então falta cadastrar algum produto na 4C, e não tem como processar a ficha
        IF (cAliasCLR)->QTDECLT < (cAliasCLR)->QTDECLR
            
            If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
                RecLock('F04',.F.)
                F04->F04_PROC	:=  '2' // Indica que ficha não está pronta para iniciar processamento.
                F04->(MsUnLock())
            EndIF
            
        ElseIF (cAliasCLR)->QTDECLR  >0
            //Indica que ao menos uma ficha poderá ser processada.
            lRet	:= .T.
        EndIF
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Sai1CF01()

Função que verifica se todas as saídas da ficha 1CF estão devidamente
cadastradas na F01, é necessário que todos os produtos da saída estejam cadastrados
na tabela F01 para poder gravar F01(4A)

@author Erick G. Dias
@since 16/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Sai1CF01(DtIni,DtFim)
    
    Local lRet          := .F.
    Local cAliasCLR := ''
    
    
    F04->(dbSetOrder(2))
    cAliasCLR   :=  GetNextAlias()
    
    cSelect   := "COUNT (F01.F01_FICHA) as QTDEF01, COUNT(CLR.CLR_FICHA) as QTDECLR, CLR.CLR_IDCAB "
    
    cWhere      :=  "CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere      +=  "CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere      +=  "CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere      +=  "CLR.CLR_FICHA = '13' AND CLR.CLR_TPMOV = 'S' AND F04.F04_PROC = '1' AND F04.F04_STATUS = '2' AND "
    
    /* 	Os códigos de lançamento 137017,137663, e 137665 não podem ser considerados, pois na prática não estarão cadastrados na tabela F01
     Se tratam de lançamentos manuais no estoque referente a Perda de Eneria Eletrica.
     
     137017 - Estorno de Valor/Quantidade/ICMS a maior - Ficha 1C
     137663 - Baixa de energia elétrica por perda anormal - Ficha 1C
     137665 - Baixa de Energia Elétrica consumida na estocagem e comercialização de mercadorias de revenda ou produtos acabados
    */
    
    cWhere      +=  "CLR.CLR_CODLAN NOT IN('137017','137663','137665') AND "
    cJoin  := "LEFT JOIN "+RetSqlName("F01")+" F01 ON(F01.F01_FILIAL='"+xFilial("F01")+"' AND F01.F01_PRODUT = CLR.CLR_PROD AND "
    cJoin  += "F01.F01_PERIOD='"+strzero(month(DtIni),2) + str(year(DtIni),4)+"' AND F01.F01_FICHA = '1' AND  F01.D_E_L_E_T_=' ')  "
    
    cJoin  += "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND    "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cGroupBy    :=   "GROUP BY CLR.CLR_IDCAB "

    cSelect := '%'+cSelect+'%'
    cWhere      := '%'+cWhere+'%'
    cJoin   := '%'+cJoin+'%'
    cGroupBy    := '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        //Se a quantidade de produtos cadastrados na 4A for maior ou igual a quantidade da saída destes produtos na CLR, significa que está pronta para processar
        //Se a quantidade da F01 for menor que CLR, então falta cadastrar algum produto na 4A, e não tem como processar a ficha
        IF (cAliasCLR)->QTDEF01 < (cAliasCLR)->QTDECLR
            
            If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
                RecLock('F04',.F.)
                F04->F04_PROC   :=  '2' // Indica que ficha não está pronta para iniciar processamento.
                F04->(MsUnLock())
            EndIF
            
        ElseIF (cAliasCLR)->QTDECLR  >0
            //Indica que ao menos uma ficha poderá ser processada.
            lRet    := .T.
        EndIF
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCache()
@description Função para fazer verificação de ColumnPos, getnewpar , Existbloc
e aliasindic, para manter em cache e não fazer estas verificações
mais de uma vez no processamento.
@author Erick G. Dias
@since 18/06/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcCache()
    
    //Verificação de parâmetros - SX6
    aParSX6	:= ProcSX6()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSX6()
@description Função que irá fazer GetNewPar nos parâmetros
Quando incluir novo parâmetro na lista abaixo, não esquece de
atualizar a lista de DEFINE dos parâmetros
@author Erick G. Dias
@since 18/06/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcSX6()
    Local aRet	:= {}
    Local nCont	:= 0
    
    Local aParam 	:= {	{'MV_GGFCT83'			,	 'GGFCAT083'	   		},;		//01
    {'MV_ENECT83'   		,   'ENECAT083'      },;	//02
    {'MV_COMCT83'   		,   'COMCAT083'      },;	//03
    {'MV_2DCT83'   		,   '2DCAT083'       },;	//04
    {'MV_UTENC83'   		,   ''        		},;	//05
    {'MV_CAT8301'   		,   ''        		},;	//06
    {'MV_CAT8302'   		,   ''        		},;	//07
    {'MV_CAT8303'   		,   ''        		},;	//08
    {'MV_CAT8304'   		,   ''        		},;	//09
    {'MV_CAT8305'        ,   ''               },;//10
    {'MV_RTCAT83'        ,   .F.              },;//11
    {'MV_FORPROC'        ,   .F.              },;//12
    {'MV_ELCAT83'        ,   ''               },;// 13
    {'MV_1BCT83'         ,   '1BCAT083'       },; // 14
    {'MV_LIMSLDF'        ,   0.001          }} // 15
    
    
    //Verifica se parâmetro existe.
    For nCont:=1 to Len(aParam)
        aAdd(aRet , GetNewPar((aParam[nCont,1]),aParam[nCont,2])  )
    Next nX
    
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1D6C()
@description Função que realiza gravação do valor do crédito de serviço de
comunicação da ficha 1D para a ficha 6C, de acordo com a proporcionalidade
de cada exportação em relação ao total de exportação

@author Erick G. Dias
@since 18/06/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Proc1D6C(DtIni,DtFim)
    Local nICMS1D		:= 0
    Local nCUSTO1D	:= 0
    Local nTot6c		:= 0
    local nPer6C		:= 0
    local nServ6C		:= 0
    Local cIdCab		:= ''
    
    ProcLogAtu("MENSAGEM","Início Lançamento automatico ficha 1D para 6C - Filial " + FWGETCODFILIAL + " " + Time())
    
    F04->(dbSetOrder(2))
    //---------------------------------------------------------------------------------------
    //PRIMEIRA QUERY PARA OBTER O VALOR TOTAL DE icms DE AQUISIÇÃO DE SERVIÇO DE COMUNICAÇÃO
    //---------------------------------------------------------------------------------------
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM(CLR.CLR_ICMS) AS CLR_ICMS,SUM(CLR.CLR_CUSTO) AS CLR_CUSTO, CLR.CLR_IDCAB"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_FICHA = '14' AND CLR.CLR_TPMOV = 'E' AND "
    
    cGroupBy	:=	 "GROUP BY CLR.CLR_IDCAB "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        nICMS1D		:= (cAliasCLR)->CLR_ICMS
        nCUSTO1D	:= (cAliasCLR)->CLR_CUSTO
        cIdCab		:= (cAliasCLR)->CLR_IDCAB
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    
    //---------------------------------------------------------------------------
    //ATUALIZA O CABECALHO DA FICHA 1D COM SOMATÓRIO DO VALOR DO CUSTO E DO ICMS
    //---------------------------------------------------------------------------
    If !Empty(Alltrim(cIdCab))
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ cIdCab))
            RecLock('F04',.F.)
            
            F04->F04_FATORI	:= nICMS1D
            F04->F04_FATORC	:= nCUSTO1D
            
            F04->(MsUnLock())
        EndIF
    EndIF
    
    
    If nICMS1D > 0
        
        //---------------------------------------------------------------------------------------
        //SEGUNDA QUERY PARA OBTER O VALOR TOTAL DA SAÍDA DE EXPORTAÇÕES NA FICHA 6C
        //---------------------------------------------------------------------------------------
        cAliasCLR	:=	GetNextAlias()
        cSelect 	:=	"SUM(CLR.CLR_SAIDA) AS CLR_SAIDA"
        cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
        cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
        cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
        cWhere		+=  "CLR.CLR_FICHA = '63' AND CLR.CLR_TPMOV = 'E' AND "
        
        cSelect	:= '%'+cSelect+'%'
        cWhere		:= '%'+cWhere+'%'
        
        BeginSql Alias cAliasCLR
            SELECT
            %Exp:cSelect%
            
            FROM
            %Table:CLR% CLR
            WHERE
            %Exp:cWhere%
            CLR.%NotDel%
            
        EndSql
        
        DbSelectArea (cAliasCLR)
        
        Do While !(cAliasCLR)->(Eof ())
            
            
            nTot6C	:= (cAliasCLR)->CLR_SAIDA
            
            (cAliasCLR)->(DbSkip ())
        EndDo
        
        DbSelectArea (cAliasCLR)
        (cAliasCLR)->(DbCloseArea())
        
        IF nTot6C > 0
            //---------------------------------------------------------------------------------------
            //TERCEIRA QUERY TRAZENDO TODAS AS SAÍDAS DA FICHA 6C PARA QUE POSSAM SER ATUALIZADAS.
            //---------------------------------------------------------------------------------------
            
            cAliasCLR	:=	GetNextAlias()
            cSelect 	:=	"CLR.CLR_SAIDA, CLR.R_E_C_N_O_ as CLRRECNO "
            cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
            cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
            cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
            cWhere		+=  "CLR.CLR_FICHA = '63' AND CLR.CLR_TPMOV = 'E' AND "
            
            cSelect	:= '%'+cSelect+'%'
            cWhere		:= '%'+cWhere+'%'
            
            BeginSql Alias cAliasCLR
                SELECT
                %Exp:cSelect%
                
                FROM
                %Table:CLR% CLR
                WHERE
                %Exp:cWhere%
                CLR.%NotDel%
                
            EndSql
            
            DbSelectArea (cAliasCLR)
            
            Do While !(cAliasCLR)->(Eof ())
                
                //O valor do crédito de serviço de comunicação é obtido
                //Percentual = VAlor da saída da 6C / Somatótio das saídas da 6C
                //Valor do serviço = Percentual * Somatório do ICMS da 1D
                nPer6C		:= (cAliasCLR)->CLR_SAIDA / nTot6C
                nServ6C		:= nPer6C * nICMS1D
                
                If nServ6C > 0
                    CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
                    RecLock('CLR',.F.)
                    CLR->CLR_VCRCOM		:=	nServ6C //Atualiza na ficha 6C o valor do crédito de comunicação
                    CLR->(MsUnLock())
                EndIF
                
                (cAliasCLR)->(DbSkip ())
            EndDo
            
            DbSelectArea (cAliasCLR)
            (cAliasCLR)->(DbCloseArea())
            
        EndIF
        
    EndIF
    
    ProcLogAtu("MENSAGEM","Fim Lançamento automatico ficha 1D para 6C - Filial " + FWGETCODFILIAL + " " + Time())
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Atu6A6B()
@description Função que irá verificar as movimentações das fichas 6A e 6
que ficaram com valor de crédito acumulado negativo.
Estas movimnetações não dão direito ao crédito acumulado.
e deverão ser transferidas para ficha 2F.

@author Erick G. Dias
@since 18/06/2015
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function Atu6A6B(DtIni,DtFim,cAliasTmp)
    Local oTabF04
    Local cIdCab		:= ''
    Local nTotICMS	:= 0
    Local nIcmsDev	:= 0
    Local cCodLan		:= ''
    
    ProcLogAtu("MENSAGEM","Início Atualização das fichas 6A e 6B - Filial " + FWGETCODFILIAL + " " + Time())
    
    //CLR->(dbSetOrder(6))//CLR->(dbSetOrder(7))
    CLR->(dbSetOrder(3)) //  CLR->(dbSetOrder(4))
    //---------------------------------------------------------------------------------------
    //PRIMEIRA QUERY PARA OBTER O VALOR TOTAL DE icms DE AQUISIÇÃO DE SERVIÇO DE COMUNICAÇÃO
    //---------------------------------------------------------------------------------------
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"CLR.R_E_C_N_O_ as CLRRECNO, CLR.CLR_FICHA"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_FICHA IN ('61','62','64', '65') AND CLR.CLR_TPMOV = 'E' AND CLR.CLR_CREDAC <= 0 AND "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    
    IF !(cAliasCLR)->(Eof ())
        //Significa que houve ao menos uma ocorrência de valor negativo nas fichas 6A e/ou 6B.
        //Deverá incluir cabecalho da ficha 6F
        oTabF04		:= TABF04():New()
        oTabF04:setAlsTmp(cAliasTmp)
        cIdCab	:= AddCab(oTabF04, DtIni, '66','66',.T.) //Inclui no cabecalho ficha 6F
        
        FreeObj(oTabF04)
        oTabF04:= nil
        
    EndIF
    
    Do While !(cAliasCLR)->(Eof ())
        
        nTotICMS	:= 0
        nIcmsDev	:= 0
        cCodLan	:= ''
        //Deverá Trocar o ID do campo CLR_IDCAB, CLR_FICHA e CLR_FICHA, zerando o campo CLR_CREDAC
        
        CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
        RecLock('CLR',.F.)
        cCodLan	:= SUBSTR(CLR->CLR_CODLAN,1,4) + '76'
        CLR->CLR_CODLAN	:= cCodLan
        CLR->CLR_FICHA	:=	'66'//Altera para gravar valor na ficha 6F
        CLR->CLR_IDCAB	:= cIdCab //Passa o novo idcab da ficha 6F
        CLR->(MsUnLock())
        
        //Deverá alterar o codlan da saída da ficha original
        If CLR->(MsSeek(xFilial("CLR") + DTOS(CLR->CLR_PERIOD) + str(CLR->CLR_NRLAN,9) + CLR->CLR_CODORI))
            RecLock('CLR',.F.)
            CLR->CLR_CODLAN		:=	cCodLan
            CLR->CLR_CODORI		:=	'66'
            CLR->(MsUnLock())
        EndIF
        
        CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
        nTotICMS 	:= CLR->(CLR_ICMS + CLR_VCROUT + CLR_VCRDSP)
        nIcmsDev	:= CLR->CLR_ICMDEB - nTotICMS
        RecLock('CLR',.F.)
        CLR->CLR_FICHA	:=	'66'//Altera para gravar valor na ficha 6F
        CLR->CLR_CREDAC	:= 0 //Zera o campo para não ficar mais negativo
        CLR->CLR_TOTICM	:=	nTotICMS //Total do ICMS
        CLR->CLR_ICMSDE	:= nIcmsDev //Total do ICMS Devido
        
        CLR->(MsUnLock())
        
        (cAliasCLR)->(DbSkip ())
        
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    
    //-----------------------------------------------------------------------------------------------------------------------------------
    //VERIFICA SE DEPOIS DE TROCAR FICHAS PARA 2F SE AINDA EXISTE RELAÇÃO DA F04 DAS FICHAS 6A E 6B COM ALGUMA OCORRÊNCIA NA CLR.
    //-----------------------------------------------------------------------------------------------------------------------------------
    
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"COUNT(*) AS QTDE, F04.R_E_C_N_O_ AS F04RECNO "
    
    cWhere		:=	"F04.F04_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "F04.F04_FICHA IN ('61','62') AND"
    
    cGroupBy	:=	 "GROUP BY F04.R_E_C_N_O_  "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cGroupBy	:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:F04% F04
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        //Se não houver mais nenhuma CLR com CLR_IDCAB da F04_ID então o cabecalho será deletado.
        
        If (cAliasCLR)->QTDE == 0
            F04->(dbGoTo((cAliasCLR)->F04RECNO))
            RecLock('F04',.F.)
            F04->(dbDelete())
            F04->(MsUnLock())
            F04->(FKCommit())
        EndIF
        
        (cAliasCLR)->(DbSkip ())
        
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    ProcLogAtu("MENSAGEM","Fim Atualização das fichas 6A e 6B - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA008Fil()
@description Função para fazer tratamento da seleção das filiais através da
matfilcalc, irá retornar um array com informações de quais filiais
deverão ser processadas

@author Erick G. Dias
@since 18/06/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA008Fil(lSelFil)
    
    Local aFil			:= {}
    Local aAreaSM0	:= {}
    Local aSM0			:= {}
    Local nFil			:= 0
    
    IF lSelFil .And. !lAutomato //Seleciona Filial == SIM
        aFil:= MatFilCalc( .T. )  
    Else //Seleciona filial == não
        //Adiciona filial logada para realizar o processamento
        AADD(aFil,{.T.,SM0->M0_CODFIL})
    EndiF
    
    DbSelectArea("SM0")
    aAreaSM0 := SM0->(GetArea())
    
    SM0->(DbGoTop())
    If SM0->(MsSeek(cEmpAnt))
        Do While !SM0->(Eof())  .AND. SM0->M0_CODIGO == cEmpAnt
            nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL)})
            If nFil > 0 .And. aFil[nFil][1]
                Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC,.T.})
            EndIf
            SM0->(dbSkip())
        Enddo
    EndIf
    RestArea (aAreaSM0)
    cFilAnt := FWGETCODFILIAL
    
Return aSM0

//-------------------------------------------------------------------
/*/{Protheus.doc} DevVenda()
@description Função para fazer tratamento das devoluções de venda dentro do periodo

@author Graziele Mendonça Paro
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function DevVenda(DtIni,DtFim)
    
    Local nQtdeDev	:= 0
    Local nQtdeOri	:= 0
    Local nPerDev		:= 0
    Local cIdNfOri	:= ''
    Local cFichaOri   := ''
    Local nQtde		:= 0
    Local nIcms		:= 0
    Local nCusto		:= 0
    Local nCusto3		:= 0
    Local nICMS3		:= 0
    Local nQtde3		:= 0
    Local nCredac3  := 0
    Local nSaida3   := 0
    Local cEnqLeg3  := ''
    Local nValBc3   := 0
    Local nAliq3    := 0
    Local nIcmsDeb3 := 0
    Local cCodOriM3 := ""
    
    CLQ->(dbSetOrder(2))
    CLR->(dbSetOrder(5))//CLR->(dbSetOrder(6))
    //---------------------------------------------------------------------------------------
    //Query para trazer as devoluções de venda do período
    //---------------------------------------------------------------------------------------
    cAliasCLR   :=  GetNextAlias()
    cSelect     :=  "CLR.R_E_C_N_O_ as CLRRECNO, CLR.CLR_CODORI, CLR.CLR_FICHA, CLR.CLR_QTDE, CLR.CLR_IDNF, CLQ.CLQ_SERORI, CLQ.CLQ_DOCORI, CLQ.CLQ_ITEORI"
    cWhere      :=  "CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere      +=  "CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere      +=  "CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere      +=  "CLR.CLR_TPMOV IN('G','Z') AND "
    
    cJoin	:=  "JOIN "+RetSqlName("CLQ")+" CLQ ON(CLQ.CLQ_FILIAL='"+xFilial("CLQ")+"' AND CLQ.CLQ_IDNF= CLR.CLR_IDNF "
    cJoin	+=  "AND CLQ.CLQ_DATA >= '" + dTos(DtIni) + "' AND CLQ.CLQ_DATA <= '" + dTos(DtFim) + "'  AND CLQ.D_E_L_E_T_=' ') "
    
    cWhere		+=	" F04.F04_PROC = '2' AND F04.F04_STATUS = '1'  AND "
    
    cJoin  += "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin   +=  "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "'  AND F04.D_E_L_E_T_=' ') "
    
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        nQtdeDev	:= (cAliasCLR)->CLR_QTDE //Quantidade devolvida
        cIdNfOri	:= ''
        nQtde		:= 0
        nIcms		:= 0
        nCusto		:= 0
        nCusto3	:= 0
        nICMS3		:= 0
        nQtde3		:= 0
        nPerDev	:= 0
        nVlOutros	:= 0
        nValSaida	:= 0
        nBaseItem	:= 0
        nICmsNGE	:= 0
        nCrdOuto	:= 0
        nValIpi	:= 0
        nperOuto	:= 0
        nCredac3  := 0
        nSaida3   := 0
        cEnqLeg3  := ''
        nValBc3   := 0
        nAliq3    := 0
        nIcmsDeb3 := 0
        cCodOriM3 := ""
        
        //Irá buscar a nota original para conseguir chegar na CLR/CLR original
        
        cAliasCLQ     :=    GetNextAlias()
        
        BeginSql Alias cAliasCLQ
            
            SELECT CLQ.CLQ_FILIAL,
                CLQ.CLQ_IDNF,
                CLQ.CLQ_NRDOC,
                CLQ.CLQ_SERIE,
                CLQ.CLQ_ITEM,
                CLQ.CLQ_CFOP,
                CLQ.CLQ_TPMOV,
                CLR.CLR_FICHA,
                CLR.CLR_ORIDES
            FROM       %TABLE:CLR% CLR
            JOIN %TABLE:CLQ% CLQ ON ( CLQ.CLQ_IDNF = CLR.CLR_IDNF
                AND CLQ.CLQ_FILIAL=%XFILIAL:CLQ%
                AND CLQ.%NOTDEL%
                AND CLQ.CLQ_NRDOC = %EXP:(cAliasCLR)->CLQ_DOCORI%
                AND CLQ.CLQ_SERIE = %EXP:(cAliasCLR)->CLQ_SERORI%
                AND CLQ.CLQ_ITEM  = %EXP:(cAliasCLR)->CLQ_ITEORI%
                AND CLQ.CLQ_DATA >= %EXP:DtIni%
                AND CLQ.CLQ_DATA <= %EXP:DtFim%)
            WHERE CLR.CLR_ORIDES = 'D'
                AND CLR.CLR_TPMOV = 'E'
                AND CLR.%NOTDEL%
                AND CLR.CLR_PERIOD >= %EXP:DtIni%
                AND CLR.CLR_PERIOD <= %EXP:DtFim% 
            ORDER BY
            CLQ.CLQ_FILIAL,
            CLQ.CLQ_IDNF
            
        EndSql
        DbSelectArea (cAliasCLQ)
        
        
        Do While !(cAliasCLQ)->(Eof ())
            cIdNfOri    := (cAliasCLQ)->CLQ_IDNF
            cFichaOri   := (cAliasCLQ)->CLR_FICHA
            
            (cAliasCLQ)->(DbSkip())
        EndDo
        (cAliasCLQ)->(DbCloseArea())
        
        
        If !Empty(cIdNfOri)
            
            //Posiciona CLR Original
            If CLR->(MsSeek(xFilial("CLR")+ DTOS(DtIni)+'S'+cIdNfOri ))
                
                nQtdeOri	:= CLR->CLR_QTDE
                
                IF nQtdeDev == nQtdeOri
                    //Devolução Integral
                    nPerDev	:= 1
                Else
                    //Devolução Parcial
                    nPerDev	:= nQtdeDev / nQtdeOri
                EndIF
                
                nQtde		:= CLR->CLR_QTDE - (CLR->CLR_QTDE * nPerDev )
                nIcms		:= CLR->CLR_ICMS - (CLR->CLR_ICMS * nPerDev )
                nCusto		:= CLR->CLR_CUSTO - (CLR->CLR_CUSTO * nPerDev )
                nVlOutros	:= CLR->CLR_OUTROS - (CLR->CLR_OUTROS * nPerDev )
                nValSaida	:= CLR->CLR_SAIDA -  (CLR->CLR_SAIDA * nPerDev )
                nBaseItem	:= CLR->CLR_VALBC -  (CLR->CLR_VALBC * nPerDev )
                nICmsNGE	:= CLR->CLR_ICMDEB - (CLR->CLR_ICMDEB * nPerDev )
                nCrdOuto	:= CLR->CLR_VCROUT - (CLR->CLR_VCROUT * nPerDev )
                nValIpi	:= CLR->CLR_IPI -    (CLR->CLR_IPI * nPerDev )
                nperOuto	:= CLR->CLR_PCROUT - (CLR->CLR_PCROUT * nPerDev )
                
                nCusto3      := (CLR->CLR_CUSTO * nPerDev)
                nICMS3       := (CLR->CLR_ICMS * nPerDev)
                nQtde3       := (CLR->CLR_QTDE * nPerDev)
                nCredac3     := (CLR->CLR_CREDAC * nPerDev)
                nSaida3      := (CLR->CLR_SAIDA * nPerDev)
                cEnqLeg3     := (CLR->CLR_ENQLEG)
                nValBc3      := (CLR->CLR_VALBC * nPerDev)
                nAliq3       := (CLR->CLR_ALIQ)
                nIcmsDeb3    := (CLR->CLR_ICMDEB * nPerDev)
                cCodOriM3    := cFichaOri
                
                //Aqui deverá atualizar a entrada de devolução no módulo 3
                CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
                RecLock('CLR',.F.)
                CLR->CLR_QTDE    :=	nQtde3
                CLR->CLR_CUSTO   :=  nCusto3
                CLR->CLR_ICMS    :=	nICMS3
                CLR->CLR_CREDAC  :=  nCredac3
                CLR->CLR_SAIDA   :=  nSaida3
                CLR->CLR_ENQLEG  :=  cEnqLeg3
                CLR->CLR_VALBC   :=  nValBc3
                CLR->CLR_ALIQ    :=  nAliq3
                CLR->CLR_ICMDEB  :=  nIcmsDeb3
                CLR->CLR_CODORI  :=  cCodOriM3
                CLR->(MsUnLock())
            EndIF
        EndIF
        
        (cAliasCLR)->(DbSkip ())
        
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Atu1C2E()
@description Função que atualiza os percentuais de rateio na saída da energia eltérica para o GGF

@author Graziele Mendonça Paro
@since 06/10/2016
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function Atu1C2E(DtIni,DtFim)
Local cAliasCLR := ''


        cAliasCLR     :=    GetNextAlias()
        
        BeginSql Alias cAliasCLR
            
            SELECT COUNT(0) CONTADOR, CLR.CLR_PROD
            FROM   %TABLE:CLR% CLR
            INNER JOIN %TABLE:F04% F04 ON (F04.F04_ID = CLR.CLR_IDCAB
                AND F04.F04_FICHA = CLR.CLR_FICHA
                AND F04.F04_FILIAL = %XFILIAL:F04%
                AND F04.%NOTDEL%
                AND F04.F04_PERIOD >= %EXP:DtIni%
                AND F04.F04_PERIOD <= %EXP:DtFim%)
            WHERE  CLR.CLR_FILIAL=%XFILIAL:CLR%
                AND CLR.CLR_FICHA = '13'
                AND CLR.CLR_CODORI = '25'
                AND CLR.CLR_TPMOV = 'S'
                AND CLR.%NOTDEL%
                AND CLR.CLR_PERIOD >= %EXP:DtIni%
                AND CLR.CLR_PERIOD <= %EXP:DtFim%
            GROUP BY CLR.CLR_PROD
            
        EndSql
        DbSelectArea (cAliasCLR)
        
        
        Do While !(cAliasCLR)->(Eof ())
                //CLR_FILIAL+CLR_FILMOV+DTOS(CLR_PERIOD)+CLR_FICHA+CLR_PROD
                CLR->(dbSetOrder(1))
                IF CLR->(MsSeek(xFilial("CLR")+ xFilial("CLR") + dTos(mv_par01) + "13" + (cAliasCLR)->CLR_PROD)) .And. (cAliasCLR)->CONTADOR > 0
                    IF CLR->CLR_CODORI = '25' .And. CLR->CLR_TPMOV = 'S'
                        RecLock('CLR',.F.)
                        CLR->CLR_PERRAT := 100/(cAliasCLR)->CONTADOR
                        CLR->(MsUnLock())
                EndIf
            EndIf      
        (cAliasCLR)->(DbSkip ())
        EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} StatusMod()

Função que irá verificar quais fichas est]ao ainda incompletas

@author Erick G. Dias
@since 11/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function ExistMod(DtIni,DtFim, cMod )
    
    Local cAliasCLR	:= ''
    Local lRet			:= .F.
    
    
    cAliasCLR := GetNextAlias()
    cSelect   := "COUNT(*) as QTDE"
    cWhere    := "CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere    += "CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere    += "CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    
    IF cMod == '1'
        //Irá procurar fichas do módulo 1
        cWhere    += "CLR.CLR_FICHA IN ('11','12','14','15')  AND "
    ElseIF cMod == '2'
        //Irá procurar fichas do módulo 2
        cWhere    += "CLR.CLR_FICHA IN ('21','22','23','27','28')  AND "
        
    ElseIF cMod == '1C'
        //Irá procurar entradas da ficha 1C
        cWhere    += "CLR.CLR_FICHA IN ('13')  AND "
        
    ElseIF cMod == '2E'
        //Irá procurar entradas da ficha 2E
        cWhere    += "CLR.CLR_FICHA IN ('25')  AND "
        
    ElseIF cMod == '2F'
        //Irá procurar entradas da ficha 2E
        cWhere    += "CLR.CLR_FICHA IN ('26')  AND "
        
    ElseIF cMod == '3'
        cWhere    += "CLR.CLR_FICHA IN ('31','32','33')  AND "
    ElseIF cMod == '6'
        cWhere    += "CLR.CLR_FICHA IN ('61','62','63','64','65','66','67','68') AND "
    EndIF
    
    //Join Com F04
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cSelect   := '%'+cSelect+'%'
    cWhere    := '%'+cWhere+'%'
    cJoin  := '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        
        SELECT
        %Exp:cSelect%
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
    EndSql
    
    DbSelectArea(cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof())
        
        IF (cAliasCLR)->QTDE > 0
            //Significa que possi ficha gravada
            lRet	:= .T.
        Else
            //Significa que não possui nenhuma ficha
            lRet	:= .F.
        EndIF
        
        (cAliasCLR)->(DbSkip())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuEstProd()

Função que irá atualizar os valores de custo e ICMS dos estornos realizados
durante o processo de produção. As movimentações já estarão gravadas na tabelas,
esta função apenas atualiza os valores considerando fator de ICMS e CUSTO gravados
na tabela decabecalho.

@author Erick G. Dias
@since 16/07/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AtuEstProd(DtIni,DtFim)
    
    Local cAliasCLR	:= ''
    Local nCusto		:= 0
    Local nICMS		:= 0
    
    ProcLogAtu("MENSAGEM","Início Atualização dos valores de Devoluções na Produção - Filial " + FWGETCODFILIAL + " " + Time())
    
    F04->(dbSetOrder(2))
    CLR->(dbSetOrder(3))//CLR->(dbSetOrder(7))
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"CLR.CLR_NRLAN, CLR.CLR_PERIOD, CLR.CLR_QTDE, CLR.CLR_CODORI, CLR.CLR_IDCAB, F04.F04_FATORI, F04.F04_FATORC, CLR.CLR_PROD, CLR.CLR_PRDMOV, CLR.R_E_C_N_O_ as CLRRECNO  "
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere      +=  "CLR.CLR_ORIDES = 'D' AND CLR.CLR_TPMOV = 'I' AND " 
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin		:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        //Atualiza os valores de estornos considerando o valor de cada saída da ficha
        nICMS   := (cAliasCLR)->F04_FATORI * (cAliasCLR)->CLR_QTDE
        nCusto  := (cAliasCLR)->F04_FATORC * (cAliasCLR)->CLR_QTDE
        
        //Se ambos os valores estão zero, verifico se não esta na tabela CLU com o campo CLU_APPROD igual a 2
        //Pois se estiver é pq estou devolvendo algo requisitado em outro periodo, que não teve mov. no periodo atual.
        IF nICMS == 0 .And. nCusto == 0
        
            DbSelectArea ('CLU')
            CLU->(dbSetOrder(1))
            //CLU_FILIAL+DTOS(CLU_PERIOD)+CLU_PROD+CLU_PRDINS
            
            IF CLU->(MsSeek(xFilial("CLU") + DTOS((cAliasCLR)->CLR_PERIOD)+ (cAliasCLR)->CLR_PROD+ (cAliasCLR)->CLR_PRDMOV)) 
                IF CLU->CLU_APPROD = '2'
                    nICMS   := (CLU->CLU_VALICM/CLU->CLU_QTDINS) * (cAliasCLR)->CLR_QTDE
                    nCusto  := (CLU->CLU_VALCUS/CLU->CLU_QTDINS) * (cAliasCLR)->CLR_QTDE
                EndIf    
            EndIf
             
            IF nICMS <> 0 .Or. nCusto <> 0
            
                DbSelectArea ('F04')
                //F04_FILIAL+DTOS(F04_PERIOD)+F04_ID
                IF F04->(MsSeek(xFilial("F04") + DTOS((cAliasCLR)->CLR_PERIOD) + (cAliasCLR)->CLR_IDCAB))
                    RecLock('F04',.F.)
                    F04->F04_FATORC:= (CLU->CLU_VALCUS/CLU->CLU_QTDINS)
                    F04->F04_FATORI:= (CLU->CLU_VALICM/CLU->CLU_QTDINS)
                    F04->F04_PROC       :=  '2' // Altera para não processar mais a ficha
                    F04->F04_STATUS     :=  '1' // Indica que a ficha foi concluída.
                    F04_OBSER           := "Valor da tabela CLU"
    
                EndIf
            EndIf
        EndIf
        
        CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
        RecLock('CLR',.F.)
        CLR->CLR_ICMS      := nICMS
        CLR->CLR_UICMS     := nICMS/(cAliasCLR)->CLR_QTDE
        CLR->CLR_CUSTO     := nCusto
        CLR->CLR_UCUSTO    := nCusto/(cAliasCLR)->CLR_QTDE
        CLR->(MsUnLock())
        
        //Atualiza a entrada na ficha destino.
        If CLR->(MsSeek(xFilial("CLR") + DTOS((cAliasCLR)->CLR_PERIOD) + str((cAliasCLR)->CLR_NRLAN,9) + Alltrim((cAliasCLR)->CLR_CODORI)+'O'))  
            RecLock('CLR',.F.)
            CLR->CLR_ICMS      := nICMS
            CLR->CLR_UICMS     := nICMS/(cAliasCLR)->CLR_QTDE
            CLR->CLR_CUSTO     := nCusto
            CLR->CLR_UCUSTO    := nCusto/(cAliasCLR)->CLR_QTDE
            CLR->(MsUnLock())
        EndIF
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    ProcLogAtu("MENSAGEM","Fim Atualização dos valores de Devoluções de Insumos - Produção - Filial " + FWGETCODFILIAL + " " + Time())
    
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} Tot2D()

Função que irá totalizar o valor de CUSTO e ICMS de entrada da ficha 2D.

@author Erick G. Dias
@since 24/07/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Tot2D(DtIni,DtFim)
    
    F04->(dbSetOrder(2))
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM(CLR.CLR_ICMS) as CLR_ICMS, SUM(CLR.CLR_CUSTO) as CLR_CUSTO, CLR.CLR_IDCAB  "
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_TPMOV IN ('E') AND CLR.CLR_ORIDES = 'O' AND CLR.CLR_FICHA = '24' AND "
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cGroupBy	:=	 "GROUP BY CLR.CLR_IDCAB"
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin		:= '%'+cJoin+'%'
    cGroupBy		:= '%'+cGroupBy+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        //Irá gravar no cabecalho da ficha 2D o total de ICMS e Custo das entradas.
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->CLR_IDCAB))
            RecLock('F04',.F.)
            
            F04->F04_FATORI	:= (cAliasCLR)->CLR_ICMS
            F04->F04_FATORC	:= (cAliasCLR)->CLR_CUSTO
            
            F04->(MsUnLock())
        EndIF
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Tot2D()

Função que irá atualizar o valor de custo e ICMS da ficha 6H, com base nos valores
de custos e ICMS da ficha 2D.

@author Erick G. Dias
@since 24/07/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcVal6H(DtIni,DtFim)
    
    Local nTotSai6H	:= 0
    Local nIndice		:= 0
    Local nTotICMS2D	:= 0
    Local nTotCust2D	:= 0
    Local cIdCab6H	:= ''
    
    //------------------------------------------------------------
    // 1 - Somar o total de todas as prestações de serviço na ficha 6H.
    //-------------------------------------------------------------
    F04->(dbSetOrder(2))
    
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM(CLR.CLR_SAIDA) as CLR_SAIDA"
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_TPMOV IN ('E') AND CLR.CLR_FICHA = '68' AND "
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin		:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        %Exp:cGroupBy%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        nTotSai6H	:= (cAliasCLR)->CLR_SAIDA
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    
    //------------------------------------------------
    // 2 - Buscar o valor total de ICMS e Custo da ficha 2D
    //------------------------------------------------
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"SUM(F04.F04_FATORI) as F04_FATORI, SUM(F04.F04_FATORC) as F04_FATORC "
    cWhere		:=	"F04.F04_FILIAL='"+xFilial("F04")+"' AND "
    cWhere		+=	"F04.F04_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"F04.F04_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "F04.F04_FICHA = '24'AND "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin		:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:F04% F04
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        F04.%NotDel%
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        nTotICMS2D	:= (cAliasCLR)->F04_FATORI
        nTotCust2D	:= (cAliasCLR)->F04_FATORC
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    //-------------------------------------------------------------
    // 3 - Percorrer todas as linhas da focha 6H e atualizar os valores.
    //--------------------------------------------------------------
    cAliasCLR	:=	GetNextAlias()
    
    cSelect 	:= "CLR.CLR_SAIDA, CLR.CLR_IDCAB, CLR.R_E_C_N_O_ as CLRRECNO "
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_TPMOV IN ('E') AND CLR.CLR_FICHA = '68' AND "
    
    cJoin  := "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin		:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        COLUMN CLR_PERIOD AS DATE
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        
    EndSql
    
    DbSelectArea (cAliasCLR)
    
    Do While !(cAliasCLR)->(Eof ())
        
        //Indice obtido considerando o valor da operação com relação ao total das operações
        nIndice	:= (cAliasCLR)->CLR_SAIDA / nTotSai6H
        
        CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
        RecLock('CLR',.F.)
        CLR->CLR_INDRAT	 := nIndice //Coluna 19 6H
        CLR->CLR_ICMS      := nTotICMS2D * nIndice //Coluna 20 6H
        CLR->CLR_UICMS     := CLR->CLR_ICMS/(cAliasCLR)->CLR_QTDE
        CLR->CLR_CUSTO     := nTotCust2D * nIndice //Coluna 21 6H
        CLR->CLR_UCUSTO    := CLR->CLR_CUSTO/(cAliasCLR)->CLR_QTDE
        CLR->CLR_CREDAC	 := CLR->CLR_ICMS  - CLR->CLR_ICMDEB //Coluna 22 ficha 6H
        CLR->CLR_ICMSDE	 :=  CLR->CLR_ICMDEB - CLR->CLR_ICMS //Coluna 23 ficha 6H
        
        CLR->(MsUnLock())
        
        cIdCab6H	:= (cAliasCLR)->CLR_IDCAB
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
    //Atualiza o cabecalho dizendo que as fichas foram processadas
    //Somente terá uma ficha 6H, por este motivo utilizo cIdCab6H, que é preenchida dentro de um laço, porém como é o mesmo ID acabei utilizando
    //esta variavel mesmo para não fazer outra query e buscar o ID da 6H.
    If !Empty(cIdCab6H) .AND. F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ cIdCab6H))
        RecLock('F04',.F.)
        F04->F04_PROC		:=  '2' // Altera para não processar mais a ficha
        F04->F04_STATUS	:=  '1' // Indica que a ficha foi concluída.
        F04->(MsUnLock())
    EndIF
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Atu2F()

Esta função irá fazer atualização das fichas 2F geradas pela procsd3.
o propósito é atualizar as movimentações das fichas 2F geradas do
co-produto para a ficha 2F do insumo em conjunto correspondente.
Esse processamento será realizado trocando o ID do cabecalho da movimentação
da ficha 2F do co-produto.

@author Erick G. Dias
@since 06/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Atu2F(DtIni,DtFim)
    
    Local cAliasCLR	:= ''
    Local cSelect		:= ''
    Local cJoin		:= ''
    Local cWhere		:= ''
    Local cId2FComum	:= ''
    
    F04->(dbSetOrder(1))
    
    //---------------------------------------------
    //Query para trazer todas as saídas da ficha 2F
    //---------------------------------------------
    cAliasCLR	:=	GetNextAlias()
    cSelect 	:=	"CLR.R_E_C_N_O_ as CLRRECNO, F04.R_E_C_N_O_ as F04RECNO, F01.F01_PRODUT "
    cWhere		:=	"CLR.CLR_FILIAL='"+xFilial("CLR")+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD>='"+DTOS(DtIni)+"' AND "
    cWhere		+=	"CLR.CLR_PERIOD<='"+DTOS(DtFim)+"' AND "
    cWhere		+=  "CLR.CLR_TPMOV = 'S' AND CLR.CLR_FICHA = '26' AND "
    
    cJoin  += "JOIN "+RetSqlName("F04")+" F04 ON(F04.F04_FILIAL='"+xFilial("F04")+"' AND CLR.CLR_IDCAB=F04.F04_ID AND "
    cJoin  += "F04.F04_PERIOD >= '" + dTos(DtIni) + "' AND F04.F04_PERIOD <= '" + dTos(DtFim) + "' AND  F04.D_E_L_E_T_=' ')  "
    
    cJoin	+="JOIN "+RetSqlName("F01")+" F01 ON(F01.F01_FILIAL='"+xFilial("F01")+"' AND F01.F01_PRODUT=CLR.CLR_PROD AND "
    cJoin	+="F01.F01_PERIOD='"+strzero(month(DtIni),2) + str(year(DtIni),4)+"' AND F01.F01_PRCM > 0 AND F01.F01_FICHA = '2' AND F01.D_E_L_E_T_=' ') "
    
    cSelect	:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoin	:= '%'+cJoin+'%'
    
    BeginSql Alias cAliasCLR
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:CLR% CLR
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        CLR.%NotDel%
        
    EndSql
    
    Do While !(cAliasCLR)->(Eof ())
        //1-buscar na tabela F04 o id da ficha 2F onde o produto do cabecalho é igual F01_PRODUT
        If F04->(MsSeek(xFilial("F04")+ DTOS(DtIni)+ (cAliasCLR)->F01_PRODUT+'26'))
            
            //2-Alterar linha de saída da 2F trocando o CLR_IDCAB
            CLR->(dbGoTo((cAliasCLR)->CLRRECNO))
            RecLock('CLR',.F.)
            CLR->CLR_IDCAB      := F04->F04_ID
            CLR->(MsUnLock())
            
        EndIF
        
        //3-Deletar no final
        
        (cAliasCLR)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasCLR)
    (cAliasCLR)->(DbCloseArea())
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSBC()
Função que irá buscar da tabela SBC movimentações para a gravação das fichas
considerando o código de lançamento como critério para ser processada, irá preencher
objeto de estrutura da cat83 e irá chamar as funções para gravação das
respectivas fichas.

@param dDtIni,Date,Date inicial do Processamento
@param dDtAte,Date,Date Final do Processamento

@author Erick G. Dias
@since 08/08/15
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcSBC(dDtIni, dDtAte,cAliasTmp,oProcess)
    
    Local oCat83        := CAT83ESTR():New()
    Local oTabCLR       := TABCLR():New()
    Local oTabCLQ       := TABCLQ():New()
    Local oTabF04		:= TABF04():New()
    Local cAliasSBC 	:= ''
    Local cIdBC         := ''
    Local nTot			:= 0
    Local nProc			:= 0
    Local cTipoMov  := SubStr(aParSX6[MV_CAT8305],1,At(";",aParSX6[MV_CAT8305])-1)
    
    
    /* Códigos que não podem ser utilizados pelos usuários, pois não existe forma de tratar no Protheus.
    
    115291 – Não existe no Protheus uma forma de tirar o produto da ficha 11 e ir pra ficha 52 informando o produto que perdeu e o produto que gerou. Isso só é possível no Protheus através da rotina MATA685  e nesta rotina é possível somente com a utilização de uma OP.

	275291 – Não atendemos a ficha 2G

	315291 – Não existe no Protheus uma forma de tirar o produto da ficha 3A e ir pra ficha 52 informando o produto que perdeu e o produto que gerou. Isso só é possível no Protheus através da rotina MATA685  e nesta rotina é possível somente com a utilização de uma OP, e se já gerou a 3A significa que a OP já foi finalizada no Protheus.

	325291 – Não existe no Protheus uma forma de tirar o produto da ficha 3B e ir pra ficha 52 informando o produto que perdeu e o produto que gerou. Isso só é possível no Protheus através da rotina MATA685  e nesta rotina é possível somente com a utilização de uma OP,  e a ficha 3B é de REVENDA, logo não tem OP envolvida.

	335291 – Não existe no Protheus uma forma de tirar o produto da ficha 3C e ir pra ficha 52 informando o produto que perdeu e o produto que gerou. Isso só é possível no Protheus através da rotina MATA685  e nesta rotina é possível somente com a utilização de uma OP, e se já gerou a 3C significa que a OP já foi finalizada no Protheus.
    
    */
    
    
    
    ProcLogAtu("MENSAGEM","Início Perdas Produção - Filial " + FWGETCODFILIAL + " " + Time())
    
    nTot	:= QtdeSBC(dDtIni, dDtAte)
    
    If !lAutomato
    	oProcess:Set2Progress(nTot)
    	oProcess:Inc1Progress(FWGETCODFILIAL + ' - Buscando movimentações SBC')
    	oProcess:Inc2Progress(FWGETCODFILIAL + ' - Buscando movimentações SBC')
    EndIf
    
    cAliasSBC	:= QrySBC(.F., dDtIni, dDtAte)
    oTabF04:setAlsTmp(cAliasTmp)
    DbSelectArea (cAliasSBC)
    (cAliasSBC)->(DbGoTop ())
    oTabCLQ:setAlsTmp(cAliasTmp)
    oCat83:setAlsTmp(cAliasTmp) //Passa alias da tabela principal para estrutura da cat
    Do While !(cAliasSBC)->(Eof ())
        nProc++
        
        If !lAutomato
        	oProcess:Inc2Progress('Processando Perdas Produção  - Filial ' +Alltrim(STR(nProc)) + ' de ' + Alltrim(STR(nTot) ))
        EndIf
        
        //Adiciona nota fiscal e retorna ID
        cIdBC   := AddNota(oTabCLQ, ;
            (cAliasSBC)->BC_DATA, ;
            , ;
            , ;
            , ; //Saida /Entrada
            , ;
            (cAliasSBC)->C2_NUM, ;
            (cAliasSBC)->C2_ITEM)
        
        //Popula objeto oCat83 para que possa ser processada a Ficha
        oCat83:setNrLanc(FSA108Seq('00',cAliasTmp))//Busca sequencial unívoco
        oCat83:setFilMov(cFilAnt)
        oCat83:setPeriodo(dDtIni)
  		//oCat83:setCodProd((cAliasSBC)->C2_PRODUTO) //Produto Destino
  	    //oCat83:setInsumo((cAliasSBC)->BC_PRODUTO) //Produto que perdeu
  	    
  	    /*
  	    Quando for 11 não considero o produto da OP
  	    */
  	    IF 	SubStr((cAliasSBC)->BC_CODLAN,2,1) =='11'
  	    	oCat83:setCodProd((cAliasSBC)->BC_PRODUTO) //Produto Destino
  	    	oCat83:setInsumo((cAliasSBC)->BC_PRODUTO) //Produto que perdeu
  	    ElseIf  SubStr((cAliasSBC)->BC_CODLAN,2,1)$'21|22|23' 	 
  	    	oCat83:setCodProd((cAliasSBC)->C2_PRODUTO) //Produto Destino
  	        oCat83:setInsumo((cAliasSBC)->BC_PRODUTO) //Produto que perdeu
  	    EndIf
  	    

  	    //oCat83:setCodProd((cAliasSBC)->BC_PRODUTO) //Produto Destino
  	    //oCat83:setInsumo((cAliasSBC)->BC_PRODUTO) //Produto que perdeu
        oCat83:setCodRes((cAliasSBC)->BC_CODDEST) //Produto resultante da perda     
        
        oCat83:setNumSeq((cAliasSBC)->BC_NUMSEQ)
        oCat83:setCdLanto((cAliasSBC)->BC_CODLAN)
        oCat83:setQtde((cAliasSBC)->BC_QUANT)
        oCat83:setArmazem((cAliasSBC)->BC_LOCORIG)
        oCat83:setTpDoc(cTipoMov)
        oCat83:setIdNf(cIdBC)
        oCat83:setUnidade((cAliasSBC)->C2_UM)
        
        oCat83:setTabMov('SBC')
        
        //Processa a ficha
        AdFichaMov(oCat83,oTabCLR,oTabF04)
        oCat83:Clear()
        
        (cAliasSBC)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAliasSBC)
    (cAliasSBC)->(DbCloseArea ())
    
    FreeObj(oCat83)
    oCat83:= nil
    
    FreeObj(oTabCLR)
    oTabCLR:= nil
    
    FreeObj(oTabCLQ)
    oTabCLQ:= nil
    
    FreeObj(oTabF04)
    oTabF04:= nil
    
    ProcLogAtu("MENSAGEM","Início Perdas Produção - Filial " + FWGETCODFILIAL + " " + Time())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRateio()
Função para obter o valor dos rateios.

@author Graziele Paro
@since 11/08/2015
@version 11.80
/*/
Static Function ProcRateio(cAliasMod)
    Local nTotal    := 0
    Local nPos      := 0
    Local aMod      := {}
    Local cPeriod   := Month2Str(MV_PAR01)+Year2Str(MV_PAR01)
    Local oTabF01   := TABF01():New()
    
    DbSelectArea (cAliasMod)
    (cAliasMod)->(DbGoTop ())
    
    Do While !(cAliasMod)->(Eof ())
        aAdd(aMod, {})
        nPos    :=  Len (aMod)
        If nPos <> 0
            aAdd(aMod[nPos], nPos)
            aAdd(aMod[nPos], cPeriod)
            aAdd(aMod[nPos], "3")
            aAdd(aMod[nPos], (cAliasMod)->C2_PRODUTO)
            aAdd(aMod[nPos], (cAliasMod)->D3_COD)
            aAdd(aMod[nPos], (cAliasMod)->QUANTIDADE)
            aAdd(aMod[nPos], 0)
        EndIf
        nTotal += (cAliasMod)->QUANTIDADE
        (cAliasMod)->(DbSkip())
    EndDo
    
    For nPos:= 1 to Len(aMod)
        aMod[nPos][7]   := aMod[nPos][6]/nTotal
        AddF01(oTabF01, aMod[nPos][2], aMod[nPos][3],aMod[nPos][4], aMod[nPos][7])
    Next nPos
    
    DbSelectArea (cAliasMod)
    (cAliasMod)->(DbCloseArea ())
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddF01()
Função para gravar dos rateios na tabela F01.

@author Graziele Paro
@since 11/08/2015
@version 11.80
/*/
Static Function AddF01(oTabF01, dPeriod, cFicha, cProdut,nPerRat)
    
    DEFAULT dPeriod := ''
    DEFAULT cFicha  := ''
    DEFAULT cProdut := ''
    DEFAULT nPerRat := ''
    
    oTabF01:setParam('F01_PERIOD'   ,dPeriod)
    oTabF01:setParam('F01_FICHA'    ,cFicha)
    oTabF01:setParam('F01_PRODUT'   ,cProdut)
    oTabF01:setParam('F01_PERRAT'   ,nPerRat)
    
Return oTabF01:Save()

//-------------------------------------------------------------------
/*/{Protheus.doc} Copia5A()


@param dDtIni,Date,Date inicial do Processamento
@param dDtAte,Date,Date Final do Processamento

@author Erick G. Dias
@since 08/08/15
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function Copia5A(DtIni, DtFim) 

Local oTabCLU		:= TABCLU():New()
Local DtIniAnt	:= FirstDay(FirstDay(DtIni)-1)
Local DtFimAnt	:= LastDay(FirstDay(DtFim)-1)

If CLU->(ColumnPos("CLU_APPROD"))>0
	    
	cAliasCLU	:=	GetNextAlias()
	cSelect 	:=	"CLU.CLU_VALCUS, CLU.CLU_UNTICM, CLU.CLU_VALICM, CLU.CLU_PERDA, CLU.CLU_GANHO, CLU.CLU_PERIOD, CLU.CLU_PROD, CLU.CLU_PRDINS,CLU.CLU_FICHA, "
	cSelect 	+= "CLU.CLU_UNID, CLU.CLU_QUANT, CLU.CLU_QTDINS, CLU.CLU_QTDUNT, CLU.CLU_UNTCUS"
	cWhere		:=	"CLU.CLU_FILIAL='"+xFilial("CLU")+"' AND "
	cWhere		+=	"CLU.CLU_PERIOD>='"+DTOS(DtIniAnt)+"' AND "
	cWhere		+=	"CLU.CLU_PERIOD<='"+DTOS(DtFimAnt)+"' AND "
	cWhere		+=	"CLU.CLU_APPROD = '2' AND "
	
	cSelect	:= '%'+cSelect+'%'
	cWhere		:= '%'+cWhere+'%'
	    
	BeginSql Alias cAliasCLU
	    COLUMN CLU_PERIOD AS DATE
	    SELECT
	    %Exp:cSelect%
	    
	    FROM
	    %Table:CLU% CLU
	    WHERE
	    %Exp:cWhere%
	    CLU.%NotDel%
	    
	EndSql
	
	DbSelectArea (cAliasCLU)
	
	Do While !(cAliasCLU)->(Eof ())
	    
		AddFicha5A(oTabCLU, DtIni, (cAliasCLU)->CLU_PROD, (cAliasCLU)->CLU_PRDINS, (cAliasCLU)->CLU_UNID,;
				(cAliasCLU)->CLU_QUANT, (cAliasCLU)->CLU_QTDINS, (cAliasCLU)->CLU_QTDUNT, (cAliasCLU)->CLU_UNTCUS, (cAliasCLU)->CLU_VALCUS,;
				(cAliasCLU)->CLU_UNTICM, (cAliasCLU)->CLU_VALICM,(cAliasCLU)->CLU_PERDA,'2',.T.,(cAliasCLU)->CLU_FICHA )
	    
	    (cAliasCLU)->(DbSkip ())
	EndDo
	
	DbSelectArea (cAliasCLU)
	(cAliasCLU)->(DbCloseArea())  
EndIF
 
FreeObj( oTabCLU )
oTabCLU:= Nil   
  
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetEnqLeg()

Funcao para retornar o codigo do enquadramento legal da operacao. 
Caso nao seja informado no TES, consulta o parametro MV_ELCAT83 para
obter o codigo de acordo com a UF passada por parametro. 

@param cCodLeg - Enquadramento legal da tabela SF4. 
@param cUF - UF da operacao.

@author joao.pellegrini
@since 18/07/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function RetEnqLeg(cCodLeg, cUF)

Local nPosUF := 0
Local cRet := ""

// Se nao for informado cCodLeg (F4_CODLEG) verifica se a UF consta 
// no parametro MV_ELCAT83 p/ obter o enquadramento.
If Empty(cCodLeg)

	nPosUF := At(cUF, aParSX6[MV_ELCAT83])
	
	// SubStr com tamanho "4" pois o valid do campo CCV_CODLEG nao permite
	// que o tamanho seja inferior a 4 caracteres.
	If nPosUF > 0
		cRet := Substr(aParSX6[MV_ELCAT83], nPosUF + 2, 4)  
	EndIf

Else

	cRet := cCodLeg

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aReturn         Array com os parametros

@author  Graziele Mendonça Paro
@since   29.11.2016
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;           //Tipo R para relatorio P para processo
            "FSA108",;      //Pergunte do relatorio, caso nao use passar ParamDef
            ,;              //Alias
            ,;              //Array de ordens
            }               //Titulo

Return aParam

