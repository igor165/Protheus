#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#INCLUDE "FWTABLEATTACH.CH"
#include 'parmtype.ch' 

Static oBrwMonit
Static aTestDummy := {.f.,nil}

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 15/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPMONBrow(oWorkArea,cFunctionLog)
    
    Local lActive       := .T.

    If ( Valtype(oBrwMonit) != "O" )

        oBrwMonit	:= FWMBrowse():New()    

        oBrwMonit:SetAlias("GYS")
        oBrwMonit:SetDoubleClick({|| GTPMVIEW() })
        oBrwMonit:setOwner( oWorkarea:GetPanel( "WDGT01" ) )
        oBrwMonit:AddButton("Reintegrar", {|| Integra(.T.) } )
        oBrwMonit:AddButton("Integrar", {|| IIf(GTPMChk(),Integra(),FwAlertHelp("Opção não disponível para este método."))} )
        oBrwMonit:AddButton("Visualizar", {|| GTPMVIEW()} )
        oBrwMonit:SetDescription("Logs de erros")

        lActive := .F.

    EndIf
    
    oBrwMonit:Refresh()
    oBrwMonit:CleanFilter()       
    oBrwMonit:SetFilterDefault( 'GYS_ROTINA == "' + cFunctionLog + '"')
    oBrwMonit:ExecuteFilter(.T.)

    If ( !lActive )
        oBrwMonit:Activate()
    EndIf

Return()

/*/{Protheus.doc} GTPAMON
    (long_description)
    @type  Function
    @author user
    @since 15/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPMONIT()
    
    Local cMsgErro  := ""
    
    If ( FindClass("GTPRJLOG") .And. GTPxVldDic("GYS",,.T.,.T.,@cMsgErro) )

        FWMsgRun( /*oComponent*/,{ || CreateWorkArea() }, "Aguarde", "Carregando Área de trabalho" )	

        If ( ValType(oBrwMonit) == "O" )
            FreeObj(oBrwMonit)
        EndIf

    Else
        FwAlertHelp(cMsgErro)     
    EndIf

Return 
//------------------------------------------------------------------------------
/* /{Protheus.doc} CreateWorkArea
Função responsavel pela criação workarea do monitor operacional
@type Function
@author gustavo.silva2
@since 11/07/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function CreateWorkArea()

Local cMenuItem     := Nil
Local oMenu         := Nil
Local oMenuItem     := Nil
Local aSize         := FWGetDialogSize( oMainWnd )
Local oDlgWA        := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Monitor de Integrações", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
Local oWorkArea		:= FWUIWorkArea():New( oDlgWA )

oWorkarea:SetMenuWidth( 200 )

oMenu := FWMenu():New()
oMenu:Init()

//------------------------------------------------------------------------------------------------------
//  Metodos
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder("Status do Job " + CheckActiveJob() , "A") 
cMenuItem := oMenu:AddFolder("Metodos ", "A") 

oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( "+ Bilhetes "	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ115") } )
oMenuItem:AddContent( "+ Receitas e Despesas"	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ427") } )
oMenuItem:AddContent( "+ Horarios/Serviços"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ004") } )
oMenuItem:AddContent( "+ Trechos da Linha"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ003") } )
oMenuItem:AddContent( "+ Orgão"	                    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ000") } )
oMenuItem:AddContent( "+ Tipos de localidade"	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ035") } )
oMenuItem:AddContent( "+ Estado"	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ001A") } )
oMenuItem:AddContent( "+ Cidade"	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ001B") } )
oMenuItem:AddContent( "+ Localidade"	            , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ001") } )
oMenuItem:AddContent( "+ Categoria Linha"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ011") } )
oMenuItem:AddContent( "+ Linhas" 	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ002") } )
oMenuItem:AddContent( "+ Vias"	                    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ005") } )
oMenuItem:AddContent( "+ Colaboradores"             , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ008") } )
oMenuItem:AddContent( "+ Tipo de Agência"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ711") } )
oMenuItem:AddContent( "+ Agência"	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ006") } )
oMenuItem:AddContent( "+ Categoria Bilhetes"	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ118") } )
oMenuItem:AddContent( "+ Trechos (Pedágio)"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ120") } )
oMenuItem:AddContent( "+ Tipos de Documentos "	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ420") } )
oMenuItem:AddContent( "+ Tipos de Venda"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ050") } )
oMenuItem:AddContent( "+ Motivos de Cancelamento"	, "E", { || GTPMONBrow(oWorkArea, "GTPIRJ051") } )
oMenuItem:AddContent( "+ Impressoras (ECF)"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ121") } )

//------------------------------------------------------------------------------------------------------
// Reintegrações
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder("Reintegrações", "A") 
oMenuItem := oMenu:GetItem( cMenuItem )

//oMenuItem:AddContent( "+ Reintegra"	        , "E", { || Reintegra() } )
oMenuItem:AddContent( "+ Reintegra Todos", "E", { |z| z := time(), RunAll(), z:= ElapTime(z,Time()), FwAlertSuccess("Processamento finalizado - tempo total: " + z,"Finalizado") } )

oWorkarea:SetMenu( oMenu )

oWorkarea:CreateHorizontalBox( "LINE01" ,aSize[3], .T. )
oWorkarea:SetBoxCols( "LINE01", { "WDGT01" } )

oWorkarea:Activate()

GTPMONBrow(oWorkArea, "SEM FUNCAO - BROWSE VAZIO")  //Inicializa com orgãos

oDlgWA:lEscClose := .F.	
oDlgWA:Activate( , , , , , , EnchoiceBar( oDlgWA, {|| },  { || oDlgWA:End()}, , {}, , , , , .F., .F. ) ) //Ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} GTPAMVIEW
    (long_description)
    @type  Static Function
    @author user
    @since 15/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPMVIEW()

    FWExecView("Visualizar","GTPRJMODA",MODEL_OPERATION_VIEW,,{|| .T.})

Return 

/*/{Protheus.doc} Integra
    Função para efetuar a integração ou reintegração dos serviços REST do
    sistema TotalBus (RJ)
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param lReintegra, lógico, .T. para reintegrar, .f. para integrar
    @return lRet, Lógico, .T. processamento ocorreu bem.
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Integra(lReintegra,cRoutine,lNoAsk)
    
    Local cServNoParams := RetServNoParams()
    Local cRotina       := ""

    Local aParams   := {}
    
    Local lRet      := .T.

    Default lReintegra  := .F.
    Default cRoutine    := oBrwMonit:GetFilterExpression()
    Default lNoAsk      := .F.

    cRotina := cRoutine
    cRotina := Iif(At("=",cRotina) >0, StrTran(Separa(cRotina,"=")[2],"'",""), cRotina)   

    Begin Transaction
    
    If ( GYS->(!Eof()) )

        //Para os serviços sem parâmetros, não há busca pelos
        //parâmetros utilizados no serviços - lista de rotinas 
        //se encontra em cServNoParams
        If ( !(Alltrim(cRotina) $ cServNoParams) .And.; 
            (!Empty(GYS->GYS_URL) .And. lReintegra) )
            aParams := RJGetPars(GYS->GYS_URL,.T.)
        EndIf
        
        If ( lReintegra )
            lRet := GYS->(DeleteLog(GYS_ROTINA,GYS_PARAMS))
        EndIf

    ElseIf ( lReintegra .And. !(Alltrim(cRotina) $ cServNoParams)) 
        FWAlertError("Sem log de erro, não é possível Reintegrar", "Sem dados")
    EndIf

    If ( lRet )
        
        If ( !FwIsInCallStack("RUNALL") )
            GTPDummyOn(,.t.)
        EndIf

        Do Case
        //Bilhetes
        Case ( "GTPIRJ115" $ cRoutine ) 
            lRet := Bilhetes(aParams)
        //Receitas e Despesas
        Case ( "GTPIRJ427" $ cRoutine ) 
            lRet := ReceitaDespesa(aParams)            
        //Horários
        Case ( "GTPIRJ004" $ cRoutine ) 
            lRet := Horarios(aParams)            
        //Trechos da Linha
        Case ( "GTPIRJ003" $ cRoutine ) 
            lRet := Trechos(aParams)            
        //Orgãos
        Case ( "GTPIRJ000" $ cRoutine ) 
            GTPIRJ000(,,@lRet)
        //Tipos de localidade
        Case ( "GTPIRJ035" $ cRoutine ) 
            GTPIRJ035(,,@lRet)
        //Estado
        Case ( "GTPIRJ001A" $ cRoutine ) 
            GTPIRJA001(,,@lRet)
        //Cidade
        Case ( "GTPIRJ001B" $ cRoutine ) 
            GTPIRJB001(,,@lRet)
        //Localidade
        Case ( "GTPIRJ001" $ cRoutine ) 
            GTPIRJ001(,,@lRet,lNoAsk)
        //Categoria Linha
        Case ( "GTPIRJ011" $ cRoutine ) 
            GTPIRJ011(,,@lRet)
        //Linhas
        Case ( "GTPIRJ002" $ cRoutine ) 
            GTPIRJ002(,,@lRet)
        //Vias
        Case ( "GTPIRJ005" $ cRoutine ) 
            GTPIRJ005(,,@lRet)
        //Colaboradores
        Case ( "GTPIRJ008" $ cRoutine )
            GTPIRJ008(,,@lRet)
        //Tipo de Agência
        Case ( "GTPIRJ711" $ cRoutine ) 
            GTPIRJ711(,@lRet)
        //Agência
        Case ( "GTPIRJ006" $ cRoutine ) 
            GTPIRJ006(,,@lRet)
        //Categoria Bilhetes
        Case ( "GTPIRJ118" $ cRoutine ) 
            GTPIRJ118(,@lRet)
        //Trechos (Pedágio)
        Case ( "GTPIRJ120" $ cRoutine ) 
            GTPIRJ120(,@lRet)
        //Tipos de Documentos
        Case ( "GTPIRJ420" $ cRoutine ) 
            GTPIRJ420(,@lRet)
        //Tipos de Venda
        Case ( "GTPIRJ050" $ cRoutine ) 
            GTPIRJ050(,@lRet)
        //Motivos de Cancelamento
        Case ( "GTPIRJ051" $ cRoutine ) 
            GTPIRJ051(,@lRet)
        //Impressoras (ECF)
        Case ( "GTPIRJ121" $ cRoutine ) 
            GTPIRJ121(,@lRet)
        EndCase

        // Reintegração: Se deu erro no consumo do REST, então, deverá fazer o 
        // rollback (DisarmTransaction) da exclusão prévia dos dados do log
        // Integração: Não há necessidade de DisarmTransaction, pois não houve 
        // exclusão prévia do log de erro 
        If ( !lReintegra .and. !lRet )
            lRet := .T.
        EndIf
        
        If ( !FwIsInCallStack("RUNALL") )            
            GTPDummyOff()
        EndIf

    EndIf

    If ( !lRet )
        DisarmTransaction()
    EndIf

    End Transaction
    
    If ( lRet )
        oBrwMonit:Refresh(.f.,.t.,.t.)
    EndIf

Return(lRet)

Static Function RetServNoParams()

    Local cRotinas := ""

    cRotinas += "GTPIRJ000|GTPIRJ035|GTPIRJ001|GTPIRJ001A|"
    cRotinas += "GTPIRJ001B|GTPIRJ011|GTPIRJ002|GTPIRJ005|"
    cRotinas += "GTPIRJ711|GTPIRJ006|GTPIRJ008|GTPIRJ118|GTPIRJ120|"
    cRotinas += "GTPIRJ420|GTPIRJ050|GTPIRJ051|GTPIRJ121"

Return(cRotinas)

/*/{Protheus.doc} DeleteLog
    Apaga previamente o log que fora gerado para a rotina e parâmetros
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  cRotina, caractere, Identificador da rotina
            cListPas, caractere, parâmetros que foi utilizado no POST do REST
    @return lRet, Lógico, .T. exclusão ocorreu bem.
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function DeleteLog(cRotina,cListPars)

    Local cDML := ""

    Local nStat := 0

    Local lRet  := .T.

    Default cRotina     := ""
    Default cListPars   := ""
        
    If ( !Empty(cRotina) )

        cDML := "DELETE " 
        cDML += "   "  + RetSQLName("GYS") + " " + chr(13)
        cDML += "WHERE " 
        cDML += "   GYS_ROTINA = '" + Alltrim(cRotina) + "' " + chr(13)
        
        If ( !Empty(cListPars) )
            cDML += "   AND GYS_PARAMS = '" + Alltrim(cListPars) + "' " + chr(13)
        EndiF
    
        nStat := TcSQLExec(cDML)
        
        lRet := nStat >= 0

    EndIf

Return(lRet)

/*/{Protheus.doc} Bilhetes
    Integra/Reintegra o serviço de Bilhetes
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegração do 
            serviço de Bilhetes
            
    @return lMonitOk, Lógico, .F. serviço REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Bilhetes(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams,7)
    
    GTPIRJ115(,aFunPars,@lMonitOk)    

Return(lMonitOk)

/*/{Protheus.doc} ReceitaDespesa
    Integra/Reintegra o serviço de ReceitaDespesa
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegração do 
            serviço de ReceitaDespesa
            
    @return lMonitOk, Lógico, .F. serviço REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReceitaDespesa(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams,7)

    GTPIRJ427(,aFunPars,@lMonitOk) 

Return(lMonitOk)

/*/{Protheus.doc} Horarios
    Integra/Reintegra o serviço de Horarios
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegração do 
            serviço de Horarios
            
    @return lMonitOk, Lógico, .F. serviço REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Horarios(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams,5)

    GTPIRJ004(,,aFunPars,@lMonitOk) 

Return(lMonitOk)

/*/{Protheus.doc} Trechos
    Integra/Reintegra o serviço de Trechos
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegração do 
            serviço de Trechos
            
    @return lMonitOk, Lógico, .F. serviço REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Trechos(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams)

    GTPIRJ003(,,aFunPars,@lMonitOk) 

Return(lMonitOk)

/*/{Protheus.doc} SetDefPar
    Monta a lista de parâmetros que serão enviados para o REST dos 
    serviços reintegrados
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegração do 
            serviço de Horarios
            nQtdPar, numérico, quantidade de parâmetros utilizados
    @return aFunPars, Array, lista de parâmetros convertidos em um vetor
            para o uso nas chamadas das funções que consomem o REST de serviços
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function SetDefPar(aParams,nQtdPar)
    
    Local cValue    := ""
    Local nI        := 0
    Local aFunPars  := {}

    Default aParams := {}
    Default nQtdPar := 1

    If ( Len(aParams) > 0 )
        
        aFunPars := Array(nQtdPar)
        AFill(aFunPars, "")
        
        For nI := 1 to Len(aParams)

            cValue := Iif( Valtype(aParams[nI,2]) == "A" .And. Len(aParams[nI,2]) > 1, aParams[nI,2][2], "")

            If ( "empresa" $ Lower(aParams[nI,1]) )
                aFunPars[1] := cValue
            ElseIf ( "data" $ Lower(aParams[nI,1]) )
                
                If ( "inicial" $ Lower(aParams[nI,1]) ) 
                    
                    If ( nQtdPar >= 2 )
                    
                        aFunPars[2] := SToD("20"+SubStr(cValue,1,6))
                    
                        If ( nQtdPar >= 3 )
                            aFunPars[3] := SubStr(cValue,7)
                        EndIf    

                    EndIf

                ElseIf ( "vigencia" $ Lower(aParams[nI,1]) )
                    aFunPars[1] := SToD(cValue)
                Else

                    If ( nQtdPar >= 4 )
                
                        aFunPars[4] := SToD("20"+SubStr(cValue,1,6))
                
                        If ( nQtdPar >= 5 )
                            aFunPars[5] := SubStr(cValue,7)
                        EndIf
                    
                    EndIf

                EndIf
            
            ElseIf ( "agencia" $ Lower(aParams[nI,1])  )

                If ( "inicio" $ Lower(aParams[nI,1]) )
                    
                    If ( nQtdPar >= 6 )
                        aFunPars[6] := cValue
                    EndIf

                Else

                    If ( nQtdPar >= 7 )
                        aFunPars[7] := cValue
                    EndIf
                    
                EndIf

            EndIf

        Next nI

    EndIf

Return(aFunPars)

/*/{Protheus.doc} RunAll
    Reintegra todos os serviços TotalBus
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunAll()

    Local aOrdemGTPI    := {}
    Local aSeek         := {}
    Local aResult       := {{"GYS_ROTINA","GYS_PARAMS"}}
    Local nI            := 0
    Local cLista        := "GTPIRJ115|GTPIRJ427|GTPIRJ004|GTPIRJ003"
    Local lRet          := .T.

    aOrdemGTPI := GetAllRoutine()

    GTPDummyOn(,.t.)
    
    For nI := 1 to Len(aOrdemGTPI)

        lRet := .T.

        If ( aOrdemGTPI[nI,1] $ cLista )
            
            aSeek := {}
            Aadd(aSeek, {"GYS_ROTINA",aOrdemGTPI[nI,1]})
            
            lRet := ( GTPSeekTable("GYS",aSeek,aResult,.t.,"R_E_C_N_O_ DESC",.T.) )
        
        EndIf

        If ( lRet )
            Integra(.t.,aOrdemGTPI[nI,1],(Alltrim(aOrdemGTPI[nI,1]) == "GTPIRJ001"))        
        EndIf

    Next nI
    
    GTPDummyOff()
    
Return()

/*/{Protheus.doc} GetAllRoutine
    Retorna todas as rotinas que integram com os serviços
    da TotalBus
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  
    @return aOrdemGTPI, array, contém o nome da rotina do Protheus, 
        tabela e descrição do serviço
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetAllRoutine()

    Local aOrdemGTPI := {}
     
    Aadd(aOrdemGTPI,{"GTPIRJ000", "GIO"		,"Orgão"})                     
    Aadd(aOrdemGTPI,{"GTPIRJ035", "G9V"		,"Tipos de localidade"})       
    Aadd(aOrdemGTPI,{"GTPIRJ001A", "SX5"	,"Estado"})                    
    Aadd(aOrdemGTPI,{"GTPIRJ001B", "CC2"	,"Cidade"})                    
    Aadd(aOrdemGTPI,{"GTPIRJ001", "GI1"		,"Localidade"})                
    Aadd(aOrdemGTPI,{"GTPIRJ011", "GYR"		,"Categoria linha"})           
    Aadd(aOrdemGTPI,{"GTPIRJ002", "GI2/G5I"	,"Linhas"})                    
    Aadd(aOrdemGTPI,{"GTPIRJ003", "GI4"		,"Trechos da linha"})     
    Aadd(aOrdemGTPI,{"GTPIRJ004", "GID/GIE"	,"Horarios/Serviços"})          
    Aadd(aOrdemGTPI,{"GTPIRJ005", "G9U"		,"Vias"})
	Aadd(aOrdemGTPI,{"GTPIRJ008", "GYG"		,"Colaboradores"})
    Aadd(aOrdemGTPI,{"GTPIRJ711", "GI5"		,"Tipo de agência"})           
    Aadd(aOrdemGTPI,{"GTPIRJ006", "GI6"		,"Agência"})                   
    Aadd(aOrdemGTPI,{"GTPIRJ118", "G9B"		,"Categoria bilhetes"})        
    Aadd(aOrdemGTPI,{"GTPIRJ120", "G9T"		,"Trechos (pedágio)"})         
    Aadd(aOrdemGTPI,{"GTPIRJ420", "GZC"		,"Tipos de documentos"})       
    Aadd(aOrdemGTPI,{"GTPIRJ050", "GYB"		,"Tipos de venda"})            
    Aadd(aOrdemGTPI,{"GTPIRJ051", "GYC"		,"Motivos de cancelamento"})   
    Aadd(aOrdemGTPI,{"GTPIRJ115", "GIC/GZP"	,"Bilhetes"})                  
    Aadd(aOrdemGTPI,{"GTPIRJ121", "SLG"		,"Impressoras (ECF)"})         
    Aadd(aOrdemGTPI,{"GTPIRJ427", "GZT/GZP"	,"Receitas e despesas"})

Return(aClone(aOrdemGTPI))

/*/{Protheus.doc} GTPDummyOn
    Função responsável por "ligar" o teste Dummy, onde o usuário 
    poderá informar a quantidade máxima de registros que será
    executada em cada uma das integrações.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, numérico, valor máximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyOn(nVal,lParam)
    
    Local aParamBox := {}
    Local aPergRet  := {}
    
    Default nVal    := -1
    Default lParam  := .F.

    If ( RuleDummy() )    

        aTestDummy[1] := .t.

        If ( nVal < 0 .Or. lParam )
            
            aTestDummy[2] := 0
            
            aAdd(aParamBox, {1, 'Max. Registros Leitura ',aTestDummy[2], "@e 999999" ,,,, 6, .F.} )	
            
            If ( ParamBox(aParamBox, "Test Dummy On: Defina valor máximo de registros", aPergRet) )
                aTestDummy[2] := aPergRet[1]
            EndIf

        Else
            aTestDummy[2] := nVal
        EndIf
    
    Else
        GTPDummyOff()
    EndIf

Return()

/*/{Protheus.doc} GTPDummyOn
    Função responsável por "ligar" o teste Dummy, onde o usuário 
    poderá informar a quantidade máxima de registros que será
    executada em cada uma das integrações.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, numérico, valor máximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyVal()

Return(aTestDummy[2])

/*/{Protheus.doc} GTPDummyOn
    Função responsável por "ligar" o teste Dummy, onde o usuário 
    poderá informar a quantidade máxima de registros que será
    executada em cada uma das integrações.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, numérico, valor máximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyOff()
    
    aTestDummy[1] := .f.
    aTestDummy[2] := Nil

Return()

/*/{Protheus.doc} GTPDummyOn
    Função responsável por "ligar" o teste Dummy, onde o usuário 
    poderá informar a quantidade máxima de registros que será
    executada em cada uma das integrações.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, numérico, valor máximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyRunning()
    
Return (aTestDummy[1] .and. Valtype(aTestDummy[2]) == "N" )

/*/{Protheus.doc} RuleDummy
    Integra/Reintegra o serviço de Trechos
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 30/08/2021
    @version version
    @param 
    @return lMonitOk, Lógico, .F. serviço REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RuleDummy()
    
    Local lRet  := .F.

    GTPSetRules("SETDUMMYON","3","",".F.", "GTPMONIT","Teste Dummy ligado?","")
    lRet := RetCodUsr() == "000000" .And. GYF->(GYF_PARAME == "SETDUMMYON" .AND. Upper(Alltrim(GYF_CONTEU)) == ".T.")

Return(lRet)

/*/{Protheus.doc} CheckActiveJob
    Verifica se o Job e Agente estão ativados ou não
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  
    @return cActive, caractere, texto com a mensagem de schedule ativo ou não 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CheckActiveJob()

    Local cSchdId   := FWSchdByFunction("GTPJOBRJINTEG")    
    //Local cAlias    := GetNextAlias()
    Local cActive   := ""
                
    If ( FindFunction("GTPJOBRJINTEG") .and. !Empty(cSchdId) )

        If FwAlertYesNo("Deseja consultar o status do schedule GTPJOBRJINTEG ?")
            cActive := GTPSchedGet("GTPJOBRJINTEG")
        Else
            cActive := " não verificado"
        Endif

    Else
        cActive := "(Sched. GTPJobRjInteg não cadastrado)"
    EndIf

Return(cActive)


/*/{Protheus.doc} GTPMChk
    Verifca se o método escolhido pelo menu lateral possui parâmetros. 
    Se não possui parâmetros, não há necessidade de funcionamento do botão
    Integrar, somente a opção Reintegrar
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 02/09/2021
    @version version
    @param  
    @return lRet, lógico, .t. - Permite acesso ao botão Integrar.
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GTPMChk()

    Local lRet  := .T.

    Local cFunction := oBrwMonit:GetFilterExpression()
 
    cFunction := Iif(At("=",cFunction) > 0, StrTran(Separa(cFunction,"=")[2],"'",""), cFunction)

    If ( Alltrim(cFunction) $ RetServNoParams() )
        lRet := .F.
    Else
        lRet := .T.
    EndIf

Return(lRet)

/*/{Protheus.doc} GTPMainJob
    Verifica se o Job e Agente estão ativados ou não
    @type  Main Function
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param  
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Main Function GTPMainJob()
    GTPJOBRJINTEG({"T1","D MG 01 "})
Return()

