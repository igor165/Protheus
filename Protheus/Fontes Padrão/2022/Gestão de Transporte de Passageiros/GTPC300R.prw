#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

Static cFldGrid := ""

Static aFldGrid := {}
Static aInputs  := {}

Static oTabFinVia

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPC300R
Rotina responsável por mostrar as viagens de turismo que estão pendentes de
pagamento.

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPC300R()
    
    Local oModel    := Nil
    Local oMdlGC300 := GC300GetMVC("M")

    Local cIssue     := ""
    Local cHowToFix  := ""

    If ( Valtype(oMdlGC300) == "O" .And. oMdlGC300:IsActive() )

        oModel := FWLoadModel("GTPC300R")
        oModel:SetOperation(MODEL_OPERATION_UPDATE) //MODEL_OPERATION_UPDATE
        oModel:Activate()
    
        FWExecView("Viagens com Pendências", "VIEWDEF.GTPC300R", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. },,,,,,,oModel)  //MODEL_OPERATION_UPDATE
    
    Else

        cIssue      := "O monitor operacional não foi ativado"
        
        cHowToFix   := "Selecione antes, a opção de '+ Monitor' (menu lateral) "
        cHowToFix   += "e preencha os parâmetros conforme desejado, "
        cHowToFix   += "para executar a ativação do monitor."

        FwAlertHelp(cIssue,cHowToFix)
    EndIf

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelDef
Definição do modelo de dados GTPC300R

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel
    Local oStrHead  := FWFormModelStruct():New()
    Local oStrItem  := FWFormModelStruct():New() //GC300StrMaster()

    Local bLoad     := {|oSub| LoadData(oSub)}

    ModelStruct(@oStrHead,@oStrItem)
    
    SetFieldsToTemp(oStrItem)
    oModel := MPFormModel():New("GTPC300R")

    oModel:AddFields("HEADER", /*cOwner*/, oStrHead,,,bLoad)
    oModel:AddGrid("GRID", "HEADER", oStrItem,,,,,bLoad)

    oModel:SetDescription("Viagens Turismo (extraordinárias) com pendências financeiras")
    oModel:GetModel("HEADER"):SetDescription("Dados para filtro")
    oModel:GetModel("GRID"):SetDescription("Viagens pendentes")
    oModel:SetPrimaryKey({})

    oModel:GetModel("GRID"):SetMaxLine(99999)
    oModel:GetModel('GRID'):SetNoDeleteLine(.T.)
    oModel:GetModel('GRID'):SetNoInsertLine(.T.)

Return(oModel)

//------------------------------------------------------------------------------
/* /{Protheus.doc} ViewDef
Definição da apresentação (view) para o modelo de dados GTPC300R

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView		:= nil
    Local oModel	:= FwLoadModel("GTPC300R")
    Local oStrHead	:= FwFormViewStruct():New()
    Local oStrItem	:= FwFormViewStruct():New() 

    Local bAction   := {|oView| CursorWait(), RunFilter(oView), CursorArrow() }
    // Cria o objeto de View
    oView := FWFormView():New()

    ViewStruct(oStrHead, oStrItem)

    // Define qual o Modelo de dados a ser utilizado
    oView:SetModel(oModel)

    oView:SetDescription("Viagens Turismo (extraordinárias) com pendências financeiras") // "Viagens Extras"

    oView:AddField('VIEW_HEADER',   oStrHead,   'HEADER')
    oView:AddGrid('VIEW_GRID',      oStrItem,   'GRID')

    oView:CreateHorizontalBox('CABEC', 35)
    oView:CreateHorizontalBox('ITEM', 65)

    oView:SetOwnerView('VIEW_HEADER','CABEC')
    oView:SetOwnerView('VIEW_GRID','ITEM')

    oView:EnableTitleView("VIEW_HEADER","Dados para filtro")	//"Dados da Viagem"
    oView:EnableTitleView("VIEW_GRID","Viagens pendentes")		//"Itinerário"

    oView:SetViewAction("ASKONCANCELSHOW",{||.F.})
    oView:ShowUpdateMsg(.F.)

    oView:AddUserButton("Executar Filtro", "", bAction ,,VK_F5)
    // oView:AddUserButton("Imprimir Viagens", 'PRINT', {|oView| PrintViag(oView) } )
    oView:SetViewProperty("VIEW_GRID", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| SetDbClk(oGrid,cField,nLineGrid,nLineModel)}})
    
    oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
    oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)
Return(oView)
   

//------------------------------------------------------------------------------
/* /{Protheus.doc} LoadData
função que irá efetuar a carga dos dados no bloco de carga do modelo de dados

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function LoadData(oSubMdl)
    
    Local aRet  := {}
    Local aIndex:= {{"INDEX1",{'GYN_FILIAL','GYN_DTINI','GYN_HRINI'}}}    

    Local cQry      := ""
    Local cAliasTab := ""
    
    If ( oSubMdl:GetId() == "HEADER" )
        
        LoadInputs(oSubMdl,cAliasTab,aRet)

    Else
    
        cQry := GCR300QryFin(,,.t.)
    
        GTPNewTempTable(cQry,,aIndex,aFldGrid,@oTabFinVia,.t.)
        
        cAliasTab   := oTabFinVia:GetAlias()        
        
        (cAliasTab)->(DbGoTop())

        While ( (cAliasTab)->(!Eof()) )
                    
            LoadInputs(oSubMdl,cAliasTab,aRet)
            
            (cAliasTab)->(DbSkip())
            
        EndDo
    
    EndIf

Return(aRet)

//------------------------------------------------------------------------------
/* /{Protheus.doc} LoadInputs
Função responsável por carregar os dados de cada campo dos submodelos

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------

Static Function LoadInputs(oSubMdl,cAliasTab,aRet)
    
    Local xValue

    Local aStrAux   := {}
    Local aCampos   := {}    
    
    Local nI        := 0
    
    Default oSubMdl := FwModelActive():GetModel("HEADER")

    aStrAux := aClone(oSubMdl:GetStruct():GetFields())

    If ( oSubMdl:GetId() == "HEADER" )
    
        For nI	:= 1 To Len(aStrAux)
            
            If ( Len(aInputs) > 0  )
                
                Do Case
                    //aInputs[1] - {Cliente de, Loja de}
                    Case ( aStrAux[nI,3] $ "CLIENTEDE/LOJADE" )    
                        
                        If ( aStrAux[nI,3] == "CLIENTEDE" )
                            xValue := aInputs[1,1]  
                        Else
                            xValue := aInputs[1,2]
                        EndIf
                    //aInputs[2] - {Cliente ate, Loja ate}
                    Case ( aStrAux[nI,3] $ "CLIENTATE/LOJAATE" )
                        
                        If ( aStrAux[nI,3] == "CLIENTATE" )
                            xValue := aInputs[2,1]  
                        Else
                            xValue := aInputs[2,2]  
                        EndIf
                    //aInputs[3] - {Data de, Data ate}        
                    Case ( aStrAux[nI,3] $ "DATAINI/DATAFIM" )
                        
                        If ( aStrAux[nI,3] == "DATAINI" )
                            xValue := aInputs[3,1]  
                        Else
                            xValue := aInputs[3,2]  
                        EndIf
                    //aInputs[4] - {Local Origem, Local Destino}
                    Case ( aStrAux[nI,3] $ "LOCORI/LOCDES" )
                        
                        If ( aStrAux[nI,3] == "LOCORI" )
                            xValue := aInputs[4,1]  
                        Else
                            xValue := aInputs[4,2]  
                        EndIf

                End Case      
                                
            Else
                xValue := Iif(aStrAux[nI][4] == 'C',Space(aStrAux[nI][5]),GTPCastType(,aStrAux[nI][4]) )
            EndIf
            
            aAdd(aCampos,xValue)
         
        Next
        
        Aadd(aRet,aClone(aCampos))
        Aadd(aRet,0)

    Else
                    
        For nI := 1 to Len(aStrAux)

            If ( (cAliasTab)->(FieldPos(aStrAux[nI,3])) > 0 )
                aAdd(aCampos,(cAliasTab)->&(aStrAux[nI,3]))
            Else
                aAdd(aCampos,GTPCastType(,aStrAux[nI,4]))
            EndIf

        Next nI
        
        aAdd(aRet,{(cAliasTab)->(Recno()),aClone(aCampos)})
        aCampos := {}            
     
    EndIf

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} GCR300QryFin
Função responsável por retornar a query que executará o filtro de viagens com
pendências financeiras.

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GCR300QryFin(cCliente,cLoja,lConsulta,lFiltered)
	
	Local cQuery 		:= ""
	Local cFields       := ""

    Local lHasTabMonitor:= .t.
    
    Local oModel        := FwModelActive()
    Local oSubHead      := Nil
    Local oTable        := GC300TabMaster()
    
	Default cCliente 	:= ""
	Default cLoja		:= ""
	Default lConsulta	:= .F.
	Default lFiltered	:= FwIsInCallStack("RUNFILTER")

    lHasTabMonitor := Valtype(oTable) == "O" 

	If ( lConsulta )

        cFields	:= GC300FldsMaster() + ", "
        
        If ( lHasTabMonitor )
        
            cFields	+= "E1_SALDO SALDO, " + chr(13)
            cFields	+= "( " + chr(13)
            cFields	+= "    CASE " + chr(13)
            cFields	+= "        WHEN " + chr(13)
            cFields += "            VIAG_MONITOR.GYN_CODIGO = '' OR VIAG_MONITOR.GYN_CODIGO IS NULL  " + chr(13)
            cFields	+= "        THEN " + chr(13)
            cFields += "            '2' " + chr(13)     //NÃO LISTADO
            cFields	+= "        ELSE " + chr(13)
            cFields += "            '1' " + chr(13)
            cFields	+= "    END) LISTADO, " + chr(13)    //É LISTADO
            cFields	+= "( " + chr(13)
            cFields	+= "    CASE " + chr(13)
            cFields	+= "        WHEN " + chr(13)
            cFields += "            VIAG_MONITOR.GYN_CODIGO = '' OR VIAG_MONITOR.GYN_CODIGO IS NULL  " + chr(13)
            cFields	+= "        THEN " + chr(13)
            cFields += "            'BR_VERMELHO' " + chr(13)     //NÃO LISTADO
            cFields	+= "        ELSE " + chr(13)
            cFields += "            'BR_VERDE' " + chr(13)
            cFields	+= "    END) LEG_LISTA " + chr(13)    //É LISTADO

        Else
            cFields	+= " '2' LISTADO, " + chr(13)        //NÃO LISTADO
            cFields	+= " 'BR_VERMELHO' LEG_LISTA " + chr(13)        //NÃO LISTADO
        EndIf

        cFldGrid := cFields

    Else    
        cFields		:= "SUM(E1_SALDO) SALDO " + chr(13)
	EndIf

	cQuery := "SELECT " + chr(13)
	cQuery += " " + cFields + chr(13)
	cQuery += "FROM " + chr(13)
	cQuery +="	" + RetSQLName("GYN") + " GYN " + chr(13) 
	cQuery +="INNER JOIN " + chr(13)
	cQuery +="	" + RetSQLNamer("SC6") + " SC6 " + chr(13)
	cQuery +="ON " + chr(13)
	cQuery +="	SC6.D_E_L_E_T_ = ' ' "
	cQuery +="	AND SC6.C6_FILIAL = '" + XFilial("SC6") + "' " + chr(13)
	cQuery +="	AND SC6.C6_NUM = GYN.GYN_CODPED " + chr(13)
	
    If ( !lConsulta .And. (!Empty(cCliente) .And. !Empty(cLoja)) )
        cQuery += "	AND SC6.C6_CLI = '" + cCliente + "' " + chr(13)
	    cQuery += "	AND SC6.C6_LOJA = '" + cLoja + "' " + chr(13)
	EndIf

    cQuery += "INNER JOIN " + chr(13)
    cQuery += "   " + RetSQLName("GI1") + " GI1ORI "
    cQuery += "ON " + chr(13)
    cQuery += " GI1ORI.GI1_FILIAL = '" + xFilial("GI1") + "' " + chr(13)
    cQuery += " AND GI1ORI.D_E_L_E_T_ = ' ' " + chr(13)
    cQuery += "	AND GI1ORI.GI1_COD = GYN.GYN_LOCORI " + chr(13)
    cQuery += "INNER JOIN " + chr(13)
    cQuery += "   " + RetSQLName("GI1") + " GI1DES "
    cQuery += "ON " + chr(13)
    cQuery += " GI1DES.GI1_FILIAL = '" + xFilial("GI1") + "' " + chr(13)
    cQuery += " AND GI1DES.D_E_L_E_T_ = ' ' " + chr(13)
    cQuery += " AND GI1DES.GI1_COD = GYN.GYN_LOCDES " + chr(13)
    cQuery +="INNER JOIN " + chr(13)
	cQuery +="	" + RetSQLName("SE1") + " SE1 " + chr(13)
    cQuery +="ON " + chr(13)
	cQuery +="	SE1.E1_FILIAL = SC6.C6_FILIAL " + chr(13)
	cQuery +="	AND SE1.E1_NUM = SC6.C6_NOTA " + chr(13)
	cQuery +="	AND SE1.E1_PREFIXO = SC6.C6_SERIE " + chr(13)
	cQuery +="	AND SE1.E1_CLIENTE = SC6.C6_CLI " + chr(13)
	cQuery +="	AND SE1.E1_LOJA = SC6.C6_LOJA " + chr(13)
	cQuery +="	AND SE1.E1_VENCREA <= GYN.GYN_DTINI " + chr(13)
	cQuery +="	AND SC6.D_E_L_E_T_ = ' ' " + chr(13)
	
    If ( lHasTabMonitor .And. lConsulta )
        
        cQuery +="LEFT JOIN " + chr(13)
        cQuery +="	" + oTable:GetRealName() + " VIAG_MONITOR " + chr(13)
        cQuery +="ON " + chr(13)
        cQuery +="  GYN.GYN_FILIAL = VIAG_MONITOR.GYN_FILIAL " + chr(13)
        cQuery +="  AND GYN.GYN_CODIGO = VIAG_MONITOR.GYN_CODIGO " + chr(13)

	EndIf

    cQuery +="WHERE " + chr(13)
	cQuery +="	GYN.GYN_FILIAL = '" + XFilial("GYN")+ "' " + chr(13)
	cQuery +="	AND GYN.GYN_TIPO = '2' " + chr(13)                      //Viagens extraordinárias
	cQuery +="	AND GYN.GYN_SRVEXT = 'ES' " + chr(13)                   //Viagens de serviços tipo EXTRA
	cQuery +="	AND GYN.GYN_CONF = '2' " + chr(13)                      //Viagens ainda não confirmadas
	cQuery +="	AND GYN.GYN_FINAL != '1' " + chr(13)                    //Viagens sem estar finalizadas
	cQuery +="	AND GYN.D_E_L_E_T_= '' " + chr(13)
    
    If ( lFiltered .And. lConsulta .And. ( Valtype(oModel) == "O" .and. oModel:IsActive() ) )
	    
        oSubHead := oModel:GetModel("HEADER")
       
        If ( !Empty(aInputs[2,1]) )

            cQuery += "	AND SC6.C6_CLI BETWEEN '" + aInputs[1,1] + "' AND '" + aInputs[2,1] + "'" + chr(13)
            cQuery += "	AND SC6.C6_LOJA BETWEEN '" + aInputs[1,2] + "' AND '" + aInputs[2,2] + "'" + chr(13)
        
        EndIf

        If ( !Empty(aInputs[3,1]) .And. !Empty(aInputs[3,2]) )
        
            cQuery += "	AND ( " + chr(13)
            cQuery += "			( GYN.GYN_DTINI >= '" + DtoS(aInputs[3,1]) + "'  " + chr(13) 
            cQuery += "			    AND GYN.GYN_DTFIM <= '" + DtoS(aInputs[3,2]) + "' ) " + chr(13) 
            cQuery += "			OR" + chr(13)
            cQuery += "			( GYN.GYN_DTINI >= '" + DtoS(aInputs[3,1]) + "' AND ('" + DtoS(aInputs[3,2]) + "' BETWEEN GYN.GYN_DTINI AND GYN.GYN_DTFIM)) " + chr(13)
            cQuery += "		) " + chr(13)

        EndIf

        IF !Empty(aInputs[4,1])
            cQuery += "	AND GYN.GYN_LOCORI = '" + aInputs[4,1] + "' " + chr(13)
        Endif

        IF !Empty(aInputs[4,2])
            cQuery += "	AND GYN.GYN_LOCDES = '" + aInputs[4,2] + "' " + chr(13)
        Endif
    EndIf

Return(cQuery)

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetFieldsToTemp
Função responsável por criar a estrutura dos campos que irão compor a tabela
temporária das viagens com pendências financeiras

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetFieldsToTemp(oStrItem)
   
    Local aFldStrItem   := {}

    Local nI    := 0

    If ( Len(aFldGrid) == 0 )
    
        aFldStrItem := aClone(oStrItem:GetFields())

        For nI := 1 to Len(aFldStrItem)

            aAdd(aFldGrid,{;
                aFldStrItem[nI,3],; //Nome do campo
                aFldStrItem[nI,4],; //Tipo do campo
                aFldStrItem[nI,5],; //Tamanho do campo
                aFldStrItem[nI,6];  //Decimal do campo
            })        
        
        Next nI

    EndIf

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelStruct
Montagem da estrutura do modelo de dados GTPC300R

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelStruct(oStrHead,oStrItem)

    Local oStrAuxGrd    := GC300StrMaster()
    
    Local aFields       := aClone(oStrAuxGrd:GetFields())

    Local nI            := 0

    Local bFldVld	    := {|oMdl,cField,uNewValue,uOldValue|;
                            FieldValid(oMdl,cField,uNewValue,uOldValue) }
    Local bFldTrig      := {|oMdl,cField,uVal|; 
                            FieldTrigger(oMdl,cField,uVal)}
    // Local bInit     := {|oSubMdl| SetLegenda(oSubMdl)}                        
    
    oStrHead:AddField(	"Cliente de",;	        // 	[01]  C   Titulo do campo   // "Monitor"
				 		"Cliente de",;	        // 	[02]  C   ToolTip do campo  // "Monitor"
				 		"CLIENTEDE",;	        // 	[03]  C   Id do Field
				 		"C",;		            // 	[04]  C   Tipo do campo
				 		TamSx3("A1_COD")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			            // 	[06]  N   Decimal do campo
				 		Nil,;		            // 	[07]  B   Code-block de validação do campo
				 		Nil,;		            // 	[08]  B   Code-block de validação When do campo
				 		Nil,;		            //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		            //	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		            //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		            //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		            // 	[14]  L   Indica se o campo é virtual  
    
    oStrHead:AddField(	"Loja de",;	            // 	[01]  C   Titulo do campo   // "Monitor"
				 		"Loja de",;	            // 	[02]  C   ToolTip do campo  // "Monitor"
				 		"LOJADE",;	            // 	[03]  C   Id do Field
				 		"C",;		            // 	[04]  C   Tipo do campo
				 		TamSx3("A1_LOJA")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			            // 	[06]  N   Decimal do campo
				 		Nil,;		            // 	[07]  B   Code-block de validação do campo
				 		Nil,;		            // 	[08]  B   Code-block de validação When do campo
				 		Nil,;		            //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		            //	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		            //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		            //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		            // 	[14]  L   Indica se o campo é virtual  
   
    oStrHead:AddField(	"Nome de",;	            // 	[01]  C   Titulo do campo   // "Monitor"
				 		"Nome de",;	            // 	[02]  C   ToolTip do campo  // "Monitor"
				 		"CLINOMDE",;	        // 	[03]  C   Id do Field
				 		"C",;		            // 	[04]  C   Tipo do campo
				 		TamSx3("A1_NOME")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			            // 	[06]  N   Decimal do campo
				 		Nil,;		            // 	[07]  B   Code-block de validação do campo
				 		Nil,;		            // 	[08]  B   Code-block de validação When do campo
				 		Nil,;		            //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		            //	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		            //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		            //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		            // 	[14]  L   Indica se o campo é virtual  
       
    oStrHead:AddField(	"Cliente até",;	        // 	[01]  C   Titulo do campo   // "Monitor"
				 		"Cliente até",;	        // 	[02]  C   ToolTip do campo  // "Monitor"
				 		"CLIENTATE",;	        // 	[03]  C   Id do Field
				 		"C",;		            // 	[04]  C   Tipo do campo
				 		TamSx3("A1_COD")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			            // 	[06]  N   Decimal do campo
				 		Nil,;		            // 	[07]  B   Code-block de validação do campo
				 		Nil,;		            // 	[08]  B   Code-block de validação When do campo
				 		Nil,;		            //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		            //	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		            //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		            //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		            // 	[14]  L   Indica se o campo é virtual  
    
    oStrHead:AddField(	"Loja até",;	        // 	[01]  C   Titulo do campo   // "Monitor"
				 		"Loja até",;	        // 	[02]  C   ToolTip do campo  // "Monitor"
				 		"LOJAATE",;	            // 	[03]  C   Id do Field
				 		"C",;		            // 	[04]  C   Tipo do campo
				 		TamSx3("A1_LOJA")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			            // 	[06]  N   Decimal do campo
				 		Nil,;		            // 	[07]  B   Code-block de validação do campo
				 		Nil,;		            // 	[08]  B   Code-block de validação When do campo
				 		Nil,;		            //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		            //	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		            //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		            //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		            // 	[14]  L   Indica se o campo é virtual  

    oStrHead:AddField(	"Nome até",;	        // 	[01]  C   Titulo do campo   // "Monitor"
				 		"Nome até",;	        // 	[02]  C   ToolTip do campo  // "Monitor"
				 		"CLINOMATE",;	        // 	[03]  C   Id do Field
				 		"C",;		            // 	[04]  C   Tipo do campo
				 		TamSx3("A1_NOME")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			            // 	[06]  N   Decimal do campo
				 		Nil,;		            // 	[07]  B   Code-block de validação do campo
				 		Nil,;		            // 	[08]  B   Code-block de validação When do campo
				 		Nil,;		            //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		            //	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		            //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		            //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		            // 	[14]  L   Indica se o campo é virtual  
    
    oStrHead:AddField(  "Data De",;             // 	[01]  C   Titulo do campo   // "Monitor"
                        "Data De",;             // 	[02]  C   ToolTip do campo  // "Monitor"
                        "DATAINI",;             // 	[03]  C   Id do Field
                        "D",;                   // 	[04]  C   Tipo do campo
                        8,;                     // 	[05]  N   Tamanho do campo
                        0,;                     // 	[06]  N   Decimal do campo
                        bFldVld,;               // 	[07]  B   Code-block de validação do campo
                        Nil,;                   // 	[08]  B   Code-block de validação When do campo
                        {},;                    //	[09]  A   Lista de valores permitido do campo
                        .T.,;                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                   //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.) 			        // 	[14]  L   Indica se o campo é virtual
	
    oStrHead:AddField(  "Data Até",;            // 	[01]  C   Titulo do campo   // "Monitor"
                        "Data Até",;            // 	[02]  C   ToolTip do campo  // "Monitor"
                        "DATAFIM",;             // 	[03]  C   Id do Field
                        "D",;                   // 	[04]  C   Tipo do campo
                        8,;                     // 	[05]  N   Tamanho do campo
                        0,;                     // 	[06]  N   Decimal do campo
                        bFldVld,;               // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;              // 	[08]  B   Code-block de validação When do campo
                        {},;                    //	[09]  A   Lista de valores permitido do campo
                        .T.,;                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                   //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                    // 	[14]  L   Indica se o campo é virtual
    
    oStrHead:AddField(  "Loc. Origem",;             // 	[01]  C   Titulo do campo // "Monitor"  
                        "Loc. Origem",;             // 	[02]  C   ToolTip do campo // "Monitor"
                        "LOCORI",;                  // 	[03]  C   Id do Field
                        "C",;                       // 	[04]  C   Tipo do campo
                        TamSx3('G55_LOCORI')[1],;   // 	[05]  N   Tamanho do campo
                        0,;                         // 	[06]  N   Decimal do campo
                        bFldVld,;                   // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                        {},;                        //	[09]  A   Lista de valores permitido do campo
                        .T.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                       //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.) 	                    // 	[14]  L   Indica se o campo é virtual
    
    oStrHead:AddField(  "Descr. Origem",;           // 	[01]  C   Titulo do campo   // "Monitor"  
                        "Descr. Origem",;           // 	[02]  C   ToolTip do campo  // "Monitor"
                        "DESCORI",;                 // 	[03]  C   Id do Field
                        "C",;                       // 	[04]  C   Tipo do campo
                        TamSx3('G55_DESORI')[1],;   // 	[05]  N   Tamanho do campo
                        0,;                         // 	[06]  N   Decimal do campo
                        {|| .T.},;                  // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                        {},;                        //	[09]  A   Lista de valores permitido do campo
                        .F.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                       //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                        // 	[14]  L   Indica se o campo é virtual
    
    oStrHead:AddField(  "Loc. Destino",;            // 	[01]  C   Titulo do campo   // "Monitor"  
                        "Loc. Destino",;            // 	[02]  C   ToolTip do campo  // "Monitor"
                        "LOCDES",;                  // 	[03]  C   Id do Field
                        "C",;                       // 	[04]  C   Tipo do campo
                        TamSx3('G55_LOCDES')[1],;   // 	[05]  N   Tamanho do campo
                        0,;                         // 	[06]  N   Decimal do campo
                        bFldVld,;                   // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                        {},;                        //	[09]  A   Lista de valores permitido do campo
                        .T.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                       //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                        // 	[14]  L   Indica se o campo é virtual
    
    oStrHead:AddField(  "Descr. Destino",;          // 	[01]  C   Titulo do campo   // "Monitor"  
                        "Descr. Destino",;          // 	[02]  C   ToolTip do campo  // "Monitor"
                        "DESCDES",;                 // 	[03]  C   Id do Field
                        "C",;                       // 	[04]  C   Tipo do campo
                        TamSx3('G55_DESDES')[1],;   // 	[05]  N   Tamanho do campo
                        0,;                         // 	[06]  N   Decimal do campo
                        {|| .T.},;                  // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                        {},;                        //	[09]  A   Lista de valores permitido do campo
                        .F.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                       //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                        // 	[14]  L   Indica se o campo é virtual

    oStrHead:SetProperty("*", MODEL_FIELD_OBRIGAT , .F.)

    oStrHead:AddTrigger("LOCORI","LOCORI",{ || .T. }, bFldTrig)
    oStrHead:AddTrigger("LOCDES","LOCDES",{ || .T. }, bFldTrig)
    oStrHead:AddTrigger("CLIENTEDE","CLIENTEDE",{ || .T. }, bFldTrig)
    oStrHead:AddTrigger("LOJADE","LOJADE",{ || .T. }, bFldTrig)
    oStrHead:AddTrigger("CLIENTATE","CLIENTATE",{ || .T. }, bFldTrig)
    oStrHead:AddTrigger("LOJAATE","LOJAATE",{ || .T. }, bFldTrig)

    For nI := 1 to Len(aFields)
    
        oStrItem:AddField(  aFields[nI,01],;	//Descrição (Label) do campo  
                            aFields[nI,02],;	//Descrição Tooltip do campo
                            aFields[nI,03],;	//Identificador do campo
                            aFields[nI,04],;	//Tipo de dado
                            aFields[nI,05],;	//Tamanho
                            aFields[nI,06],;	//Decimal
                            aFields[nI,07],;	//Valid do campo
                            aFields[nI,08],;	//When do campo
                            aFields[nI,09],;	//Lista de Opções (Combo)
                            aFields[nI,10],;	//Indica se campo é obrigatório
                            aFields[nI,11],;	//inicializador Padrão
                            aFields[nI,12],;	//Indica se o campo é chave
                            aFields[nI,13],;	//Indica se o campo pode receber um valor em uma operação update
                            aFields[nI,14])		//Indica se o campo é virtual
    
    Next nI

    oStrItem:AddField(  "Listado?",;	//Descrição (Label) do campo  
						"Listado?",;	//Descrição Tooltip do campo
						"LISTADO",;		//Identificador do campo
						"C",;			//Tipo de dado
						1,;			    //Tamanho
						0,;				//Decimal
						nil,;			//Valid do campo
						nil,;			//When do campo
						{},;			//Lista de Opções (Combo)
						.f.,;			//Indica se campo é obrigatório
						Nil,;			//inicializador Padrão
						.f.,;			//Indica se o campo é chave
						.f.,;			//Indica se o campo pode receber um valor em uma operação update
						.f.)			//Indica se o campo é virtual

    oStrItem:AddField(  " ",;			//Descrição (Label) do campo  
						"Listado?",;	//Descrição Tooltip do campo
						"LEG_LISTA",;	//Identificador do campo
						"C",;			//Tipo de dado
						15,;			//Tamanho
						0,;				//Decimal
						nil,;			//Valid do campo
						nil,;			//When do campo
						{},;			//Lista de Opções (Combo)
						.f.,;			//Indica se campo é obrigatório
						Nil,;			//inicializador Padrão
						.f.,;			//Indica se o campo é chave
						.f.,;			//Indica se o campo pode receber um valor em uma operação update
						.f.)			//Indica se o campo é virtual
    
    oStrItem:AddField(  "Saldo Tit.",;			//Descrição (Label) do campo  
						"Saldo em Títulos",;	//Descrição Tooltip do campo
						"SALDO",;		        //Identificador do campo
						"N",;			        //Tipo de dado
						TamSX3("E1_SALDO")[1],;	//Tamanho
						TamSX3("E1_SALDO")[2],;	//Decimal
						nil,;			        //Valid do campo
						nil,;			        //When do campo
						{},;			        //Lista de Opções (Combo)
						.f.,;			        //Indica se campo é obrigatório
						Nil,;			        //inicializador Padrão
						.f.,;			        //Indica se o campo é chave
						.f.,;			        //Indica se o campo pode receber um valor em uma operação update
						.f.)			        //Indica se o campo é virtual

    // oStrItem:SetProperty('LEG_LISTA', MODEL_FIELD_INIT, bInit )
                        
    
Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} ViewStruct
Montagem da estrutura da apresentação (view) para o modelo de dados GTPC300R

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewStruct(oStrHead, oStrItem)

    Local oStrAuxGrd    := GC300StrMaster(.t.)

    Local aFields       := aClone(oStrAuxGrd:GetFields())

    Local nI            := 0

    Local cFldDetrat    := ""
    
    cFldDetrat += "GYN_CONF/"
    cFldDetrat += "GYN_LEGEND/"
    cFldDetrat += "GYN_STSLEG/"
    cFldDetrat += "GYN_CANCEL/"
    cFldDetrat += "GYN_SRVEXT/""
    cFldDetrat += "GYN_DSVEXT/""
    cFldDetrat += "GYN_MONIT/"
    cFldDetrat += "GYN_FINAL/"
    cFldDetrat += "GYN_FILPRO/"
    cFldDetrat += "GYN_OPORTU/"
    cFldDetrat += "GYN_CODGY0/"
    cFldDetrat += "GYN_APUCON/""

    oStrHead:AddField(  "CLIENTEDE",;   // [01] C Nome do Campo                                       
                        "01",;   	    // [02] C Ordem
                        "Cliente de",;  // [03] C Titulo do campo       //"Cód.ECF"
                        "Cliente de",;  // [04] C Descrição do campo    //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help        //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "SA1",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
    
    oStrHead:AddField(  "LOJADE",;      // [01] C Nome do Campo                                       
                        "02",;   	    // [02] C Ordem
                        "Loja de",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Loja de",;     // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
                        
    oStrHead:AddField(  "CLINOMDE",;    // [01] C Nome do Campo                                       
                        "03",;   	    // [02] C Ordem
                        "Nome de",;     // [03] C Titulo do campo       //"Cód.ECF"
                        "Nome de",;     // [04] C Descrição do campo    //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help        //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual

    oStrHead:AddField(  "CLIENTATE",;   // [01] C Nome do Campo                                       
                        "04",;   	    // [02] C Ordem
                        "Cliente até",;  // [03] C Titulo do campo //"Cód.ECF"
                        "Cliente até",;  // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "SA1",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
    
    oStrHead:AddField(  "LOJAATE",;     // [01] C Nome do Campo                                       
                        "05",;   	    // [02] C Ordem
                        "Loja até",;    // [03] C Titulo do campo //"Cód.ECF"
                        "Loja até",;    // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
                                                
    oStrHead:AddField(  "CLINOMATE",;    // [01] C Nome do Campo                                       
                        "06",;   	     // [02] C Ordem
                        "Nome até",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Nome até",;     // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
    
    oStrHead:AddField(  "DATAINI",;    // [01] C Nome do Campo                                       
                        "07",;   	     // [02] C Ordem
                        "Data de",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Data de",;     // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
    
    oStrHead:AddField(  "DATAFIM",;    // [01] C Nome do Campo                                       
                        "08",;   	     // [02] C Ordem
                        "Data de",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Data de",;     // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual

    oStrHead:AddField(  "LOCORI",;          // [01] C Nome do Campo                                       
                        "09",;   	        // [02] C Ordem
                        "Loc. Origem",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Loc. Origem",;     // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;             // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	        // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	        // [07] C Picture
                        NIL,;   	        // [08] B Bloco de Picture Var
                        "GI1",;	            // [09] C Consulta F3
                        .T.,;    	        // [10] L Indica se o campo é editável
                        NIL,;               // [11] C Pasta do campo
                        NIL,;    	        // [12] C Agrupamento do campo
                        Nil,;  	            // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	        // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	        // [15] C Inicializador de Browse
                        .F.)    	        // [16] L Indica se o campo é virtual
    
    oStrHead:AddField(  "DESCORI",;         // [01] C Nome do Campo                                       
                        "10",;   	        // [02] C Ordem
                        "Descr. Origem",;   // [03] C Titulo do campo //"Cód.ECF"
                        "Descr. Origem",;   // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;             // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	        // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	        // [07] C Picture
                        NIL,;   	        // [08] B Bloco de Picture Var
                        "",;	            // [09] C Consulta F3
                        .T.,;    	        // [10] L Indica se o campo é editável
                        NIL,;               // [11] C Pasta do campo
                        NIL,;    	        // [12] C Agrupamento do campo
                        Nil,;  	            // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	        // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	        // [15] C Inicializador de Browse
                        .F.)    	        // [16] L Indica se o campo é virtual

    oStrHead:AddField(  "LOCDES",;    // [01] C Nome do Campo                                       
                        "11",;   	     // [02] C Ordem
                        "Loc. Destino",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Loc. Destino",;     // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "GI1",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
    
    oStrHead:AddField(  "DESCDES",;    // [01] C Nome do Campo                                       
                        "12",;   	     // [02] C Ordem
                        "Descr. Destino",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Descr. Destino",;     // [04] C Descrição do campo //"Cód.ECF"
                        {""}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual

	oStrItem:AddField( 	"LEG_LISTA",; 	// [01] C Nome do Campo
						"01",; 			// [02] C Ordem
						" ",;           // [03] C Titulo do campo
						"Listado?",; 	// [04] C Descrição do campo//"Legenda"
						{"A viagem está listada no Monitor Operacional?","Verde: sim","Vermelho: Não"},;	// [05] A Array com Help//"Somatória dos Lançamentos de Receita"//"Cor do Status da Viagem"
						"GET",; 		// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@BMP",;		// [07] C Picture
						NIL,; 			// [08] B Bloco de Picture Var
						"",; 			// [09] C Consulta F3
						.F.,; 			// [10] L Indica se o campo é editável
						NIL, ; 			// [11] C Pasta do campo
						NIL,; 			// [12] C Agrupamento do campo
						{},; 			// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 			// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 		// [15] C Inicializador de Browse
						.f.) 			// [16] L Indica se o campo é virtual                                
	

    For nI := 1 to Len(aFields)
         
        If ( !(aFields[nI,1] $ cFldDetrat) )
            
            oStrItem:AddField( 	aFields[nI,01],; // [01] C Nome do Campo
                                aFields[nI,02],; // [02] C Ordem
                                aFields[nI,03],; // [03] C Titulo do campo
                                aFields[nI,04],; // [04] C Descrição do campo//"Legenda"
                                aFields[nI,05],; // [05] A Array com Help//"Somatória dos Lançamentos de Receita"//"Cor do Status da Viagem"
                                aFields[nI,06],; // [06] C Tipo do campo - GET, COMBO OU CHECK
                                aFields[nI,07],; // [07] C Picture
                                aFields[nI,08],; // [08] B Bloco de Picture Var
                                aFields[nI,09],; // [09] C Consulta F3
                                aFields[nI,10],; // [10] L Indica se o campo é editável
                                aFields[nI,11],; // [11] C Pasta do campo
                                aFields[nI,12],; // [12] C Agrupamento do campo
                                aFields[nI,13],; // [13] A Lista de valores permitido do campo (Combo)
                                aFields[nI,14],; // [14] N Tamanho Maximo da maior opção do combo
                                aFields[nI,15],; // [15] C Inicializador de Browse
                                aFields[nI,16])  // [16] L Indica se o campo é virtual                                

        EndIf
    
    Next nI
    
    oStrItem:AddField( 	"SALDO",; 	                            // [01] C Nome do Campo
						cValToChar(nI),; 			                        // [02] C Ordem
						"Saldo Tit.",;                          // [03] C Titulo do campo
						"Saldo Títulos",; 	                    // [04] C Descrição do campo//"Legenda"
						{   "Valor em aberto de 1 ou mais",;
                            "títulos financeiros",;
                            "a receber do cliente"},;	        // [05] A Array com Help//"Somatória dos Lançamentos de Receita"//"Cor do Status da Viagem"
						"GET",; 		                        // [06] C Tipo do campo - GET, COMBO OU CHECK
						GetSx3Cache("E1_SALDO","X3_PICTURE"),;	// [07] C Picture
						NIL,; 			                        // [08] B Bloco de Picture Var
						"",; 			                        // [09] C Consulta F3
						.F.,; 			                        // [10] L Indica se o campo é editável
						NIL, ; 			                        // [11] C Pasta do campo
						NIL,; 			                        // [12] C Agrupamento do campo
						{},; 			                        // [13] A Lista de valores permitido do campo (Combo)
						NIL,; 			                        // [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 		                        // [15] C Inicializador de Browse
						.f.) 			                        // [16] L Indica se o campo é virtual                                
    
    oStrHead:SetProperty("DESCORI", MVC_VIEW_CANCHANGE, .F.)
    oStrHead:SetProperty("DESCDES", MVC_VIEW_CANCHANGE, .F.)    
    oStrHead:SetProperty("CLINOMDE", MVC_VIEW_CANCHANGE, .F.)
    oStrHead:SetProperty("CLINOMATE", MVC_VIEW_CANCHANGE, .F.)    

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldValid
Função responsável pela validação dos campos do cabeçalho do modelo de dados

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
    
    Local lRet		:= .T.
    
    Local oModel	:= oMdl:GetModel()
    
    Local cMdlId	:= oMdl:GetId()
    Local cMsgErro	:= ""
    Local cMsgSol	:= ""

    Do Case
    	Case ( Empty(uNewValue) )
    		lRet := .T.
        Case ( cField == "DATAFIM" )

            If ( uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI') )
                
                lRet     := .F.

                cMsgErro := "Data final não pode ser menor que a data inicial"
                cMsgSol  := "Altere a data final"

            Endif

        Case ( cField == 'LOCORI' )

            If ( uNewValue == oMdl:GetValue('LOCDES') )

                lRet     := .F.

                cMsgErro := "Localidade de origem e destino não podem ser iguais"
                cMsgSol  := "Altere a localidade"

            Endif

            If ( lRet .And. !Empty(uNewValue) )
                //GI1_FILIAL, GI1_COD, R_E_C_N_O_, D_E_L_E_T_
                lRet := GI1->(DbSeek(xFilial("GI1")+uNewValue))
            
                If ( !lRet )

                    cMsgErro := "Localidade de origem (partida) não cadastrada."
                
                    cMsgSol := "Verifique se o código digitado está correto ou 
                    cMsgSol += "se há necessidade de efetuar o cadastro da localidade."
                
                EndIf
            
            EndIf

        Case ( cField == 'LOCDES' )

            If ( uNewValue == oMdl:GetValue('LOCORI') )
                
                lRet     := .F.
                
                cMsgErro := "Localidade de origem e destino não podem ser iguais"
                cMsgSol  := "Altere a localidade"

            Endif    	
            
            If ( lRet .And. !Empty(uNewValue) )
                //GI1_FILIAL, GI1_COD, R_E_C_N_O_, D_E_L_E_T_

                lRet := GI1->(DbSeek(xFilial("GI1")+uNewValue))

                If ( !lRet )

                    cMsgErro := "Localidade de destino (ou chegada) não cadastrada."
                
                    cMsgSol := "Verifique se o código digitado está correto ou 
                    cMsgSol += "se há necessidade de efetuar o cadastro da localidade."
                
                EndIf

            EndIf
    	
    EndCase

    If ( !lRet .and. !Empty(cMsgErro) )
    	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
    Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldTrigger
Função responsável pelos gatilhos utilizados pelos campos do cabeçalho do modelo de dados

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
 Static Function FieldTrigger(oMdl,cField,uVal)
    
    Local cNomeCli  := ""
    
    If ( cField $ "LOCORI/LOCDES" )
        If ( !Empty(uVal) )
            cDescLocal := Posicione("GI1",1,xFilial("GI1")+uVal,"GI1_DESCRI")
        Else
            cDescLocal := ""
        EndIf    
    EndIf

    Do Case
        
        Case ( cField == 'LOCORI' )
            
            oMdl:LoadValue('DESCORI',cDescLocal )

        Case ( cField == 'LOCDES' )
            
            oMdl:LoadValue('DESCDES', cDescLocal)	
            
        Case ( cField $ 'CLIENTEDE|LOJADE' )

            If ( cField == "CLIENTEDE" .And. !Empty(oMdl:GetValue("LOJADE")) )
                cNomeCli := Posicione("SA1",1,xFilial("SA1")+uVal+oMdl:GetValue("LOJADE"),"A1_NOME")
            ElseIf ( cField == "LOJADE" .And. !Empty(oMdl:GetValue("CLIENTEDE")) )
                cNomeCli := Posicione("SA1",1,xFilial("SA1")+oMdl:GetValue("CLIENTEDE")+uVal,"A1_NOME")
            EndIf  

            oMdl:LoadValue('CLINOMDE', cNomeCli )
            
        Case ( cField $ 'CLIENTATE|LOJAATE' )

            If ( cField == "CLIENTATE" .And. !Empty(oMdl:GetValue("LOJAATE")) )
                
                If ( Replicate("Z",6) $ uVal )    
                    cNomeCli := Replicate("Z",TamSx3("A1_NOME")[1])
                Else
                    cNomeCli := Posicione("SA1",1,xFilial("SA1")+uVal+oMdl:GetValue("LOJAATE"),"A1_NOME")
                EndIf

            ElseIf ( cField == "LOJAATE" .And. !Empty(oMdl:GetValue("CLIENTATE")) )
                
                If ( Replicate("Z",6) $ oMdl:GetValue("CLIENTATE") )    
                    cNomeCli := Replicate("Z",TamSx3("A1_NOME")[1])
                Else
                    cNomeCli := Posicione("SA1",1,xFilial("SA1")+oMdl:GetValue("CLIENTATE")+uVal,"A1_NOME")
                EndIf

            EndIf  

            oMdl:LoadValue('CLINOMATE', cNomeCli )	
    EndCase

Return uVal

//------------------------------------------------------------------------------
/* /{Protheus.doc} RunFilter
Função responsável pela execução do filtro

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function RunFilter(oView)

    Local oHead     := oView:GetModel("HEADER")
    Local oModel    := oView:GetModel()
    
    aInputs   := {  { oHead:GetValue("CLIENTEDE"),oHead:GetValue("LOJADE") },;
                    { oHead:GetValue("CLIENTATE"),oHead:GetValue("LOJAATE") },;
                    { oHead:GetValue("DATAINI"),oHead:GetValue("DATAFIM") },;
                    { oHead:GetValue("LOCORI"),oHead:GetValue("LOCDES") }}

    If ( oModel:IsActive() )

        oModel:DeActivate()
        oModel:Activate()
    
        oView:Refresh()
    
    EndIf

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetLegenda
Função responsável pela criação da legenda para o campo LEG_LISTA

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetLegenda(oSub)

    Local cLegenda  := ""

    If ( oSub:GetValue("LISTADO") == "1" )
        cLegenda := "BR_VERDE"
    Else
        cLegenda := "BR_VERMELHO"
    EndIf

Return(cLegenda)

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDbClk
Função responsável pela apresentação da legenda

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetDbClk(oGrid,cField,nLineGrid,nLineModel)

    Local lRet  := .T.

    Local oLegenda  :=  FWLegend():New()

    If ( cField == "LEG_LISTA" )	
        
        oLegenda:Add("TESTE VERDE", "BR_VERDE", "Esta viagem está listada no monitor operacional") 
        oLegenda:Add("TESTE VERMELHO", "BR_VERMELHO", "Esta viagem não está listada no monitor operacional")

        oLegenda:Activate()
        oLegenda:View()
        oLegenda:DeActivate()

    EndIf

Return(lRet)

// Static Function PrintViag(oView)

//     Local nLine := oView:GetModel("GRID"):GetLine()

//     oView:GetViewObj("VIEW_GRID")[3]:oBrowse:Report()
    
//     oView:GetModel("GRIF"):GoLine(nLine)
//     oView:Refresh("VIEW_GRID")
// Return()
