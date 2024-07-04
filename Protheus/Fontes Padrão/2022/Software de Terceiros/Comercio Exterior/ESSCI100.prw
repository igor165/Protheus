#Include "AVERAGE.CH"
#Include "APWizard.CH"
#Include "EEC.CH"
#Include "Protheus.CH"
#Include "FILEIO.CH"

//Tipo de Processo
#Define AQUISICAO  "A" //EIC
#Define VENDA      "V" //EEC

//Servi�os
#Define INC_REG    "1" //1=Inclus�o Registro
#Define RET_REG	   "2" //2=Retifica��o de Registro
#Define INC_ADI    "3" //3=Inclus�o Aditivo
#Define RET_ADI    "4" //4=Retifica��o Aditivo
#Define INC_PAG    "5" //5=Inclus�o Pagamento
#Define CAN_PAG    "6" //6=Cancel. Pagamento
#Define RET_PAG    "7" //7=Retifica��o Pagamento
 
/*
INC_REG - "1" = Registro de Aquisi��o de Servi�o (RAS) / Registro de Venda de Servi�o (RVS)
RET_REG - "2" = Retifica��o de Aquisi��o de Servi�o (Retifica��o RAS) / Retifica��o de Venda de Servi�o (Retifica��o RVS)
INC_ADI - "3" = Aditivo ao Registro de Aquisi��o de Servi�o (Aditivo RAS) / Aditivo ao Registro de Venda de Servi�o (Aditivo RVS)
RET_ADI - "4" = Retifica��o de Aditivo de Aquisi��o de Servi�o (Retifica��o RAS) / Retifica��o de Aditivo de Venda de Servi�o (Retifica��o RVS)
INC_PAG - "5" = Registro de Pagamento de Servi�o (RP) / Registro de Faturamento de Servi�o (RF)
CAN_PAG - "6" = Cancelamento de Pagamento de Servi�o (Cancelamento RP) / Cancelamento de Faturamento de Servi�o (Cancelamento RF)
*/
//Status
#Define NAO_ENVIADO	"N"
#Define ENVIADO		"E"
#Define RECEBIDO	"R"
#Define PROCESSADO	"P"
#Define CANCELADO	"C"

/*
Funcao      : ESSCI100().
Objetivos   : Tela para central de integra��o com o SiscoServe.
Sintaxe     : ESSCI100()
Parametros  : cTipoServ A - Aquisi��o, V - Vendas
Retorno     : nil
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 17/08/12 - 10:00.
*/
Function ESSCI100(cTipoServ)
Local cTitulo     := ""
Default cTipoServ := ""
//Verifica��o se existe fun��o necessarias para essa rotina.
If FindFunction("ESSRS400") .And. FindFunction("ESSRA400").And.FindFunction("ESSRV400")
   If cTipoServ != "" 
      Do Case
         Case cTipoServ = AQUISICAO//tratamento para EIC
            cTitulo := "Aquisi��o de Servi�o"  
         Case cTipoServ = VENDA//tratamento para EEC
            cTitulo := "Venda de Servi�o"
      End Case
      
      ESSCI100 := ESSCI100():New("Integra��o SISCOSERV", cTitulo, "A��es", cTitulo, "A��es", cTitulo)
      ESSCI100:SetServicos(cTipoServ)
      ESSCI100:AddAction("Reprocessar" , "Act071" , {"RAIZ"}  , {|| SS101ProcLote(cTipoServ,,, ESSCI100, .T.)}   , , "avg_iproc", "avg_iproc")      
      ESSCI100:Show()
   Else 
      MsgStop("Erro no parametro contate o suporte tecnico.","Aten��o") 
   End If 
Else
   MsgStop("Esse ambiente n�o est� preparado para executar a nova rotina de integra��o com SiscoServ.", "Aten��o")
EndIf

Return nil 

/*
Classe      : ESSCI100.
Objetivos   : Cria��o de rotina com as regras de negocio do SiscoServ com a central de integra��o.
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 17/08/12 - 10:00.
*/
Class ESSCI100 From AvObject

	Data   cName
    Data   cSrvName
    Data   cActName
    Data   cTreeSrvName
    Data   cTreeAcName
    Data   cPanelName
    Data   bOk
    Data   bCancel
    Data   cIconSrv
    Data   cIconAction
    	
	Data   aServices
 
	Data   aCposGer
	Data   aCposEnv
	Data   aCposRec
	Data   aCposPrc
	Data   aCposCan
    
    Data   cDirGerados
    Data   cDirEnviados
    Data   cDirRecebidos
    Data   cDirRejeitados
    Data   cDirProcessados
	Data   cDirRoot
	Data   cDirLoc
    Data   cFile
    Data   aActions //RRC - 03/05/2013
    Data   oUserParams
    

	Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Constructor
	Method SetServicos(cTipoServ)
	Method Show()
  	Method SetDiretorios()
    Method GerarLote()
    Method ReceberArq(cWork,cServico)
    Method ProcessarArq(cWork,cServico)
    Method EditConfigs()
    Method GravaEL8(cArquivo, cServico, cStatus, aDesp)
    //RRC - 03/05/2013
    Method AddAction(cName, cId, aIDs, bAction, cStatus, cIconOpen, cIconClose)
	Method RetActions()
    //RRC - 16/12/2013 - Declara�ao do m�todo GravaEWZ estava pendente
    Method GravaEWZ(cArquivo, cServico, cStatus, aDesp)
    
End Class

Method New(cName, cSrvName, cActName, cTreeSrvName, cTreeAcName, cPanelName, bOk, bCancel, cIconSrv, cIconAction) Class ESSCI100

   Self:cName			:= cName
   Self:cSrvName		:= cSrvName
   Self:cActName		:= cActName
   Self:cTreeSrvName	:= cTreeSrvName
   Self:cTreeAcName		:= cTreeAcName
   Self:cPanelName		:= cPanelName
   Self:bOk				:= bOk
   Self:bCancel			:= bCancel
   Self:cIconSrv		:= cIconSrv
   Self:cIconAction		:= cIconAction
   //Self:oUserParams     := EASYUSERCFG():New("ESSCI100")
   Self:cFile           := ""

   Self:aServices 		:= {}
      
   Self:aCposGer        := {'EL8_STATUS','EL8_IDLOTE','EL8_TPPROC','EL8_TIPENV','EL8_ARQENV','EL8_DATAG','EL8_HORAG','EL8_USERG','EL8_DATAE','EL8_HORAE','EL8_USERE','EL8_ARQREC','EL8_DATAR','EL8_HORAR','EL8_USERR','EL8_DATAP','EL8_HORAP','EL8_USERP','EL8_NROREG','EL8_ERROS'}  

   Self:aCposEnv        := {'EL8_STATUS','EL8_IDLOTE','EL8_TPPROC','EL8_TIPENV','EL8_ARQENV','EL8_DATAG','EL8_HORAG','EL8_USERG','EL8_DATAE','EL8_HORAE','EL8_USERE','EL8_ARQREC','EL8_DATAR','EL8_HORAR','EL8_USERR','EL8_DATAP','EL8_HORAP','EL8_USERP','EL8_NROREG','EL8_ERROS'}  
   
   Self:aCposRec        := {'EL8_STATUS','EL8_IDLOTE','EL8_TPPROC','EL8_TIPENV','EL8_ARQENV','EL8_DATAG','EL8_HORAG','EL8_USERG','EL8_DATAE','EL8_HORAE','EL8_USERE','EL8_ARQREC','EL8_DATAR','EL8_HORAR','EL8_USERR','EL8_DATAP','EL8_HORAP','EL8_USERP','EL8_NROREG','EL8_ERROS'}  
   
   Self:aCposPrc        := {'EL8_STATUS','EL8_IDLOTE','EL8_TPPROC','EL8_TIPENV','EL8_ARQENV','EL8_DATAG','EL8_HORAG','EL8_USERG','EL8_DATAE','EL8_HORAE','EL8_USERE','EL8_ARQREC','EL8_DATAR','EL8_HORAR','EL8_USERR','EL8_DATAP','EL8_HORAP','EL8_USERP','EL8_NROREG','EL8_ERROS'}  
   
   Self:aCposCan        := {'EL8_STATUS','EL8_IDLOTE','EL8_TPPROC','EL8_TIPENV','EL8_ARQENV','EL8_DATAG','EL8_HORAG','EL8_USERG','EL8_DATAE','EL8_HORAE','EL8_USERE','EL8_ARQREC','EL8_DATAR','EL8_HORAR','EL8_USERR','EL8_DATAP','EL8_HORAP','EL8_USERP','EL8_NROREG','EL8_ERROS'}  
   //RRC - 03/05/2013
   Self:aActions        := {}
   
   Self:SetDiretorios()

Return Self

Method SetServicos(cTipoServ) Class ESSCI100

Local oSrv_01
Local oSrv_02
Local oSrv_03
Local oSrv_04
Local oSrv_05
Local oSrv_06
Local oSrv_07 
Local cTipoArqInt := Alltrim( EasyGParam("MV_AVG0221",,"INI") )
Local lIntJava := CI100IsJava()

   /*
   Capa e delalhe relacionados pelo IDLOTE.(Ex: EL8_IDLOTE = EL3_IDLOTE)
   EL8_TPPROC     : A= Aquisi��o , V = Venda
   EL8_TPENV      : 1=Inclus�o Registro;2=Retifica��o de Registro;3=Inclus�o Aditivo;4=Retifica��o Aditivo;5=Inclus�o Pagamento;6=Cancel. Pagamento;
   EL8_STATUS     : N=N�o Enviado, E=Enviado, R=Recebido, P=Processado, C=Cancelado
   Tabela capa    : EL8
   Tabela detalhe : EL3, EL4, EL5
   Obrigatorio setar o indice para FILIAL + IDLOTE.(nao mudar!)
   */
   EL3->(dbSetOrder(2))
   EL4->(dbSetOrder(2))
   EL5->(dbSetOrder(2))
      Do case 
         Case cTipoServ = "A"//Aquisi��o
         
         oSrv_01 := EECSISSRV():New("Registro de Aquisi��o de Servi�o (RAS)"                          , "EL8" , "Aquisi��o", INC_REG ,1      , "NORMAS" , "NORMAS"  ,"EL3"     ,"Detalhe" ,'EL3_FILIAL+EL3_IDLOTE', "xFilial('EL3')+EL8_IDLOTE" )  
         
         If cTipoArqInt == "INI" 
            //Pastas
            oSrv_01:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+INC_REG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_01:AddFolder("Integrados"   , RECEBIDO	    , AQUISICAO+INC_REG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_01:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+INC_REG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_01:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+INC_REG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")  
            //A��es
            oSrv_01:AddAction("Gerar lote de arquivos"    , "Act011" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO, RET_PAG + NAO_ENVIADO} , {| cWork , cId           | cId := GetId(cId), If(!Empty(cId),SS101GerLote(cTipoServ           , CI100TpOper(cId)/*INC_REG*/            , NAO_ENVIADO ),)} , , "avg_iadd" , "avg_iadd" )          
			oSrv_01:AddAction("Enviar lote de arquivos"   , "Act012" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO, RET_PAG + NAO_ENVIADO} , {| cWork , cId , ESSCI100| cId := GetId(cId), If(!Empty(cId),SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)}  , , "avg_ienv" , "avg_ienv" )
            //oSrv_01:AddAction("Cancelar lote de arquivos" , "Act013" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO, INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO} , {| cWork , cId           | cId := GetId(cId), If(!Empty(cId),SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_01:AddAction("Processar"                 , "Act016" , {"RAIZ",INC_REG + RECEBIDO    , RET_REG + RECEBIDO    , INC_ADI + RECEBIDO   , RET_ADI + RECEBIDO   , INC_PAG + RECEBIDO   , CAN_PAG + RECEBIDO, RET_PAG + RECEBIDO}    , {| cWork , cId           | cId := GetId(cId), If(!Empty(cId),SS101ProcLote((cWork)->EL8_TPPROC, (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}     , , "avg_iproc", "avg_iproc")
            oSrv_01:AddAction("Cancelar"                  , "Act017" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO, RET_PAG + NAO_ENVIADO} , {| cWork , cId  | cId := GetId(cId), If(!Empty(cId),SS101CanLote((cWork)->EL8_IDLOTE),)}                                                         , , "avg_idel" , "avg_idel" ) //RRC
            
            If lIntJava
               oSrv_01:AddAction("Configura��es"          , "Act015" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO, RET_PAG + NAO_ENVIADO} , {|| Self:EditConfigs() }, , "avg_iopt"   , "avg_iopt"  )
            EndIf
            
         ElseIf cTipoArqInt == "XML"  
            //Pastas                                                                                                                                 
            oSrv_01:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+INC_REG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_01:AddFolder("Enviados"     , ENVIADO	    , AQUISICAO+INC_REG+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_01:AddFolder("Recebidos"    , RECEBIDO	    , AQUISICAO+INC_REG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_01:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+INC_REG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_01:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+INC_REG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            //RRC - 01/02/2013
			oSrv_01:AddAction("Gerar lote de arquivos"    , "Act011" , {INC_REG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId),SS101GerLote(cTipoServ, INC_REG),)} 																			   , , "avg_iadd"  , "avg_iadd")
		   	oSrv_01:AddAction("Enviar lote de arquivos"   , "Act012" , {INC_REG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId),SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),) } , , "avg_ienv"  , "avg_ienv" )
            oSrv_01:AddAction("Cancelar lote de arquivos" , "Act013" , {INC_REG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId),SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_01:AddAction("Receber"                   , "Act014" , {INC_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_import", "avg_import")
            oSrv_01:AddAction("Cancelar"                  , "Act015" , {INC_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*|cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_01:AddAction("Processar"                 , "Act016" , {INC_REG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
            
         Endif
   
         oSrv_02 := EECSISSRV():New("Retifica��o de Aquisi��o de Servi�o (Retifica��o RAS)"           , "EL8" , "Aquisi��o", RET_REG ,1 , "NORMAS", "NORMAS","EL3","Detalhe" ,"EL3_FILIAL+EL3_IDLOTE", "xFilial('EL3')+EL8_IDLOTE")  

         If cTipoArqInt == "INI" 
            //Pastas         
            oSrv_02:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+RET_REG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_02:AddFolder("Integrados"   , RECEBIDO	    , AQUISICAO+RET_REG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_02:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+RET_REG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_02:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+RET_REG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            /*oSrv_02:AddAction("Gerar lote de arquivos"    , "Act021" , {RET_REG + NAO_ENVIADO} , {| cWork , cId                    | cId := GetId(cId), If(!Empty(cId),SS101GerLote(cTipoServ           , RET_REG            , NAO_ENVIADO                     ),) } , , "avg_iadd" , "avg_iadd" )
            oSrv_02:AddAction("Enviar lote de arquivos"   , "Act022" , {RET_REG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId),SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),) } , , "avg_ienv" , "avg_ienv" )
            oSrv_02:AddAction("Cancelar lote de arquivos" , "Act023" , {RET_REG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId),SS101CanLote((cWork)->EL8_IDLOTE),)  }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_02:AddAction("Processar"                 , "Act026" , {RET_REG + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId),SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),) }   , , "avg_iproc", "avg_iproc")
            */                      
         ElseIf cTipoArqInt == "XML"  
            //Pastas                
            oSrv_02:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+RET_REG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_02:AddFolder("Enviados"     , ENVIADO	    , AQUISICAO+RET_REG+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_02:AddFolder("Recebidos"    , RECEBIDO  	, AQUISICAO+RET_REG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_02:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+RET_REG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_02:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+RET_REG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6") 
            //Acoes
            //oSrv_02:AddAction("Gerar lote de arquivos" , "Act021" , {RET_REG + NAO_ENVIADO,RET_REG + ENVIADO,RET_REG + RECEBIDO,RET_REG + PROCESSADO,RET_REG + CANCELADO} , {|| SS101GerLote(cTipoServ, RET_REG)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_02:AddAction("Gerar lote de arquivos"    , "Act021" , {RET_REG + NAO_ENVIADO} , {| cId                     | cId := GetId(cId), If(!Empty(cId),SS101GerLote(cTipoServ, RET_REG),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_02:AddAction("Enviar lote de arquivos"   , "Act022" , {RET_REG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_02:AddAction("Cancelar lote de arquivos" , "Act023" , {RET_REG + NAO_ENVIADO} , {| cWork , cId             | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_02:AddAction("Receber"                   , "Act024" , {RET_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_02:AddAction("Cancelar"                  , "Act025" , {RET_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_02:AddAction("Processar"                 , "Act026" , {RET_REG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
            
         EndIf
         
         oSrv_03 := EECSISSRV():New("Aditivo ao Registro de Aquisi��o de Servi�o (Aditivo RAS)"       , "EL8", "Aquisi��o", INC_ADI ,1 , "NORMAS", "NORMAS","EL4","Detalhe" ,"EL4_FILIAL+EL4_IDLOTE", "xFilial('EL4')+EL8_IDLOTE")  
         
         If cTipoArqInt == "INI" 
            //Pastas
            oSrv_03:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+INC_ADI+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_03:AddFolder("Integrados"   , RECEBIDO	    , AQUISICAO+INC_ADI+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_03:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+INC_ADI+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_03:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+INC_ADI+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6") 
            //Acoes
            /*oSrv_03:AddAction("Gerar lote de arquivos"    , "Act031" , {INC_ADI + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , INC_ADI            , NAO_ENVIADO                     ),) } , , "avg_iadd" , "avg_iadd" )
            oSrv_03:AddAction("Enviar lote de arquivos"   , "Act032" , {INC_ADI + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),) } , , "avg_ienv" , "avg_ienv" )
            oSrv_03:AddAction("Cancelar lote de arquivos" , "Act033" , {INC_ADI + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),)  }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_03:AddAction("Processar"                 , "Act036" , {INC_ADI + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),) }   , , "avg_iproc", "avg_iproc")
            */          
         ElseIf cTipoArqInt == "XML"  
            //Pastas
            oSrv_03:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+INC_ADI+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_03:AddFolder("Enviados"     , ENVIADO	    , AQUISICAO+INC_ADI+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_03:AddFolder("Recebidos"    , RECEBIDO	    , AQUISICAO+INC_ADI+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_03:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+INC_ADI+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_03:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+INC_ADI+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            //oSrv_03:AddAction("Gerar lote de arquivos" , "Act031" , {INC_ADI + NAO_ENVIADO,INC_ADI + ENVIADO,INC_ADI + RECEBIDO,INC_ADI + PROCESSADO,INC_ADI + CANCELADO} , {|| SS101GerLote(cTipoServ, INC_ADI)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_03:AddAction("Gerar lote de arquivos"    , "Act031" , {INC_ADI + NAO_ENVIADO} , {| cId         | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, INC_ADI),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_03:AddAction("Enviar lote de arquivos"   , "Act032" , {INC_ADI + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_03:AddAction("Cancelar lote de arquivos" , "Act033" , {INC_ADI + NAO_ENVIADO} , {| cWork , cId | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_03:AddAction("Receber"                   , "Act034" , {INC_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_03:AddAction("Cancelar"                  , "Act035" , {INC_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_03:AddAction("Processar"                 , "Act036" , {INC_ADI + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
            
         EndIf
                                                       
         oSrv_04 := EECSISSRV():New("Retifica��o de Aditivo de Aquisi��o de Servi�o (Retifica��o RAS)", "EL8", "Aquisi��o", RET_ADI ,1 , "NORMAS", "NORMAS","EL4","Detalhe" ,"EL4_FILIAL+EL4_IDLOTE", "xFilial('EL4')+EL8_IDLOTE")  
         
         If cTipoArqInt == "INI"
            //Pastas
            oSrv_04:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+RET_ADI+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_04:AddFolder("Integrados"   , RECEBIDO	    , AQUISICAO+RET_ADI+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_04:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+RET_ADI+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_04:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+RET_ADI+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")  
            //Acoes
            /*oSrv_04:AddAction("Gerar lote de arquivos"    , "Act041" , {RET_ADI + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , RET_ADI            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_04:AddAction("Enviar lote de arquivos"   , "Act042" , {RET_ADI + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_04:AddAction("Cancelar lote de arquivos" , "Act043" , {RET_ADI + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_04:AddAction("Processar"                 , "Act046" , {RET_ADI + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}   , , "avg_iproc", "avg_iproc")
            */                                                       
         ElseIf cTipoArqInt == "XML"
            //Pastas
            oSrv_04:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+RET_ADI+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_04:AddFolder("Enviados"     , ENVIADO	    , AQUISICAO+RET_ADI+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_04:AddFolder("Recebidos"    , RECEBIDO	    , AQUISICAO+RET_ADI+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_04:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+RET_ADI+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_04:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+RET_ADI+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            //oSrv_04:AddAction("Gerar lote de arquivos" , "Act041" , {RET_ADI + NAO_ENVIADO,RET_ADI + ENVIADO,RET_ADI + RECEBIDO,RET_ADI + PROCESSADO,RET_ADI + CANCELADO} , {|| SS101GerLote(cTipoServ, RET_ADI)} , , "avg_iadd", "avg_iadd")            
            //RRC - 01/02/2013
			oSrv_04:AddAction("Gerar lote de arquivos"    , "Act041" , {RET_ADI + NAO_ENVIADO} , {| cId         | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, RET_ADI),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_04:AddAction("Enviar lote de arquivos"   , "Act042" , {RET_ADI + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_04:AddAction("Cancelar lote de arquivos" , "Act043" , {RET_ADI + NAO_ENVIADO} , {| cWork , cId | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_04:AddAction("Receber"                   , "Act044" , {RET_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_04:AddAction("Cancelar"                  , "Act045" , {RET_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_04:AddAction("Processar"                 , "Act046" , {RET_ADI + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
                                                                 
         EndIf
        
         oSrv_05 := EECSISSRV():New("Registro de Pagamento de Servi�o (RP)"                           , "EL8", "Aquisi��o"       , INC_PAG ,1 , "NORMAS", "NORMAS","EL5","Detalhe" ,"EL5_FILIAL+EL5_IDLOTE", "xFilial('EL5')+EL8_IDLOTE")  

         If cTipoArqInt == "INI"
            //Pastas
            oSrv_05:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+INC_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_05:AddFolder("Integrados"   , RECEBIDO	    , AQUISICAO+INC_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_05:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+INC_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_05:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+INC_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            /*oSrv_05:AddAction("Gerar lote de arquivos"    , "Act051" , {INC_PAG + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , INC_PAG            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_05:AddAction("Enviar lote de arquivos"   , "Act052" , {INC_PAG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_05:AddAction("Cancelar lote de arquivos" , "Act053" , {INC_PAG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_05:AddAction("Processar"                 , "Act056" , {INC_PAG + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}   , , "avg_iproc", "avg_iproc")
            */  
         ElseIf cTipoArqInt == "XML" 
            //Pastas
            oSrv_05:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+INC_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_05:AddFolder("Enviados"     , ENVIADO	    , AQUISICAO+INC_PAG+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_05:AddFolder("Recebidos"    , RECEBIDO 	, AQUISICAO+INC_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_05:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+INC_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_05:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+INC_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            //oSrv_05:AddAction("Gerar lote de arquivos" , "Act051" , {INC_PAG + NAO_ENVIADO,INC_PAG + ENVIADO,INC_PAG + RECEBIDO,INC_PAG + PROCESSADO,INC_PAG + CANCELADO} , {|| SS101GerLote(cTipoServ, INC_PAG)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_05:AddAction("Gerar lote de arquivos"    , "Act051" , {INC_PAG + NAO_ENVIADO} , {| cId         | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, INC_PAG),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_05:AddAction("Enviar lote de arquivos"   , "Act052" , {INC_PAG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_05:AddAction("Cancelar lote de arquivos" , "Act053" , {INC_PAG + NAO_ENVIADO} , {| cWork , cId | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_05:AddAction("Receber"                   , "Act054" , {INC_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_05:AddAction("Cancelar"                  , "Act055" , {INC_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_05:AddAction("Processar"                 , "Act056" , {INC_PAG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
            
         EndIf
                                
         oSrv_06 := EECSISSRV():New("Cancelamento de Pagamento de Servi�o (Cancelamento RP)"          , "EL8", "Aquisi��o"        , CAN_PAG ,1 , "NORMAS", "NORMAS","EL5","Detalhe" ,'EL5_FILIAL+EL5_IDLOTE', "xFilial('EL5')+EL8_IDLOTE")  

         If cTipoArqInt == "INI" 
            //Pastas
            oSrv_06:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+CAN_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_06:AddFolder("Integrados"   , RECEBIDO	    , AQUISICAO+CAN_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_06:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+CAN_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_06:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+CAN_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")  
            //Acoes
            /*oSrv_06:AddAction("Gerar lote de arquivos"    , "Act061" , {CAN_PAG + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , CAN_PAG            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_06:AddAction("Enviar lote de arquivos"   , "Act062" , {CAN_PAG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_06:AddAction("Cancelar lote de arquivos" , "Act063" , {CAN_PAG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_06:AddAction("Processar"                 , "Act066" , {CAN_PAG + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}   , , "avg_iproc", "avg_iproc")
            */         
         ElseIf cTipoArqInt == "XML" 
            //Pastas
            oSrv_06:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+CAN_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_06:AddFolder("Enviados"     , ENVIADO	    , AQUISICAO+CAN_PAG+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_06:AddFolder("Recebidos"    , RECEBIDO	    , AQUISICAO+CAN_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_06:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+CAN_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_06:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+CAN_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            //oSrv_06:AddAction("Gerar lote de arquivos" , "Act061" , {CAN_PAG + NAO_ENVIADO,CAN_PAG + ENVIADO,CAN_PAG + RECEBIDO,CAN_PAG + PROCESSADO,CAN_PAG + CANCELADO} , {|| SS101GerLote(cTipoServ, CAN_PAG)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_06:AddAction("Gerar lote de arquivos"    , "Act061" , {CAN_PAG + NAO_ENVIADO} , {| cId         | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, CAN_PAG),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_06:AddAction("Enviar lote de arquivos"   , "Act062" , {CAN_PAG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_06:AddAction("Cancelar lote de arquivos" , "Act063" , {CAN_PAG + NAO_ENVIADO} , {| cWork , cId | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_06:AddAction("Receber"                   , "Act064" , {CAN_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_06:AddAction("Cancelar"                  , "Act065" , {CAN_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_06:AddAction("Processar"                 , "Act066" , {CAN_PAG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
              
         EndIf  
         
         oSrv_07 := EECSISSRV():New("Retifica��o de Pagamento de Servi�o (RP)"                           , "EL8", "Aquisi��o"       , RET_PAG ,1 , "NORMAS", "NORMAS","EL5","Detalhe" ,"EL5_FILIAL+EL5_IDLOTE", "xFilial('EL5')+EL8_IDLOTE")  

         If cTipoArqInt == "INI"
            //Pastas
            oSrv_07:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+RET_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_07:AddFolder("Integrados"   , RECEBIDO	    , AQUISICAO+RET_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_07:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+RET_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_07:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+RET_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")

         ElseIf cTipoArqInt == "XML" 
            //Pastas
            oSrv_07:AddFolder("N�o enviados" , NAO_ENVIADO  , AQUISICAO+RET_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_07:AddFolder("Enviados"     , ENVIADO	    , AQUISICAO+RET_PAG+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_07:AddFolder("Recebidos"    , RECEBIDO 	, AQUISICAO+RET_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_07:AddFolder("Processados"  , PROCESSADO	, AQUISICAO+RET_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_07:AddFolder("Cancelados"   , CANCELADO	, AQUISICAO+RET_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")

            oSrv_07:AddAction("Gerar lote de arquivos"    , "Act051" , {RET_PAG + NAO_ENVIADO} , {| cId         | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, RET_PAG),)} 																			   , , "avg_iadd"  , "avg_iadd")
            oSrv_07:AddAction("Enviar lote de arquivos"   , "Act052" , {RET_PAG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
		    oSrv_07:AddAction("Cancelar lote de arquivos" , "Act053" , {RET_PAG + NAO_ENVIADO} , {| cWork , cId | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
		    oSrv_07:AddAction("Receber"                   , "Act054" , {RET_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
		    oSrv_07:AddAction("Cancelar"                  , "Act055" , {RET_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
		    oSrv_07:AddAction("Processar"                 , "Act056" , {RET_PAG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")

         EndIf
         
      Case cTipoServ = "V"//Venda
       
         oSrv_01 := EECSISSRV():New("Registro de Venda de Servi�o (RVS)"                              , "EL8", "Venda", INC_REG ,1 , "NORMAS", "NORMAS","EL3","Detalhe" ,'EL3_FILIAL+EL3_IDLOTE', "xFilial('EL3')+EL8_IDLOTE")  
         
         If cTipoArqInt == "INI" 
            //Pastas
            oSrv_01:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+INC_REG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_01:AddFolder("Integrados"   , RECEBIDO	    , VENDA+INC_REG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_01:AddFolder("Processados"  , PROCESSADO	, VENDA+INC_REG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_01:AddFolder("Cancelados"   , CANCELADO	, VENDA+INC_REG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")  
            //Acoes
            oSrv_01:AddAction("Gerar lote de arquivos"    , "Act011" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO, RET_PAG + NAO_ENVIADO} , {| cWork , cId           | cId := GetId(cId), If(!Empty(cId),SS101GerLote(cTipoServ           , CI100TpOper(cId)/*INC_REG*/            , NAO_ENVIADO ),)} , , "avg_iadd" , "avg_iadd" )          
			oSrv_01:AddAction("Enviar lote de arquivos"   , "Act012" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO, RET_PAG + NAO_ENVIADO} , {| cWork , cId , ESSCI100| cId := GetId(cId), If(!Empty(cId),SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)}  , , "avg_ienv" , "avg_ienv" )
            //oSrv_01:AddAction("Cancelar lote de arquivos" , "Act013" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO, INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO} , {| cWork , cId           | cId := GetId(cId), If(!Empty(cId),SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_01:AddAction("Processar"                 , "Act016" , {"RAIZ",INC_REG + RECEBIDO    , RET_REG + RECEBIDO    , INC_ADI + RECEBIDO   , RET_ADI + RECEBIDO   , INC_PAG + RECEBIDO   , CAN_PAG + RECEBIDO, RET_PAG + RECEBIDO}    , {| cWork , cId           | cId := GetId(cId), If(!Empty(cId),SS101ProcLote((cWork)->EL8_TPPROC, (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}     , , "avg_iproc", "avg_iproc")
            oSrv_01:AddAction("Cancelar"                  , "Act017" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO} , {| cWork , cId  | cId := GetId(cId), If(!Empty(cId),SS101CanLote((cWork)->EL8_IDLOTE),)}                                                         , , "avg_idel" , "avg_idel" ) //RRC
            
            If lIntJava
               oSrv_01:AddAction("Configura��es"          , "Act015" , {"RAIZ",INC_REG + NAO_ENVIADO , RET_REG + NAO_ENVIADO , INC_ADI + NAO_ENVIADO, RET_ADI + NAO_ENVIADO, INC_PAG + NAO_ENVIADO, CAN_PAG + NAO_ENVIADO, RET_PAG + NAO_ENVIADO} , {|| Self:EditConfigs() }, , "avg_iopt"   , "avg_iopt"  )
            EndIf
         ElseIf cTipoArqInt == "XML"  
            //Pastas                                                                                                                     
            oSrv_01:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+INC_REG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_01:AddFolder("Enviados"     , ENVIADO	    , VENDA+INC_REG+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_01:AddFolder("Recebidos"    , RECEBIDO	    , VENDA+INC_REG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_01:AddFolder("Processados"  , PROCESSADO	, VENDA+INC_REG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_01:AddFolder("Cancelados"   , CANCELADO	, VENDA+INC_REG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            //oSrv_01:AddAction("Gerar lote de arquivos" , "Act011" , {INC_REG + NAO_ENVIADO,INC_REG + ENVIADO,INC_REG + RECEBIDO,INC_REG + PROCESSADO,INC_REG + CANCELADO} , {|| SS101GerLote(cTipoServ, INC_REG)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_01:AddAction("Gerar lote de arquivos"    , "Act011" , {INC_REG + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, INC_REG),)} 																			   , , "avg_iadd"  , "avg_iadd")
		   	oSrv_01:AddAction("Enviar lote de arquivos"   , "Act012" , {INC_REG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),) } , , "avg_ienv"  , "avg_ienv" )
            oSrv_01:AddAction("Cancelar lote de arquivos" , "Act013" , {INC_REG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_01:AddAction("Receber"                   , "Act014" , {INC_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_01:AddAction("Cancelar"                  , "Act015" , {INC_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_01:AddAction("Processar"                 , "Act016" , {INC_REG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
            
         Endif        

         oSrv_02 := EECSISSRV():New("Retifica��o de Venda de Servi�o (Retifica��o RVS)"               , "EL8", "Venda", RET_REG ,1 , "NORMAS", "NORMAS","EL3","Detalhe" ,'EL3_FILIAL+EL3_IDLOTE', "xFilial('EL3')+EL8_IDLOTE")  
                  
         If cTipoArqInt == "INI"
         
            //Pastas
            oSrv_02:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+RET_REG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_02:AddFolder("Integrados"   , RECEBIDO	    , VENDA+RET_REG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_02:AddFolder("Processados"  , PROCESSADO	, VENDA+RET_REG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_02:AddFolder("Cancelados"   , CANCELADO	, VENDA+RET_REG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")               
            //Acoes
            /*oSrv_02:AddAction("Gerar lote de arquivos"    , "Act021" , {RET_REG + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , RET_REG            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_02:AddAction("Enviar lote de arquivos"   , "Act022" , {RET_REG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_02:AddAction("Cancelar lote de arquivos" , "Act023" , {RET_REG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_02:AddAction("Processar"                 , "Act026" , {RET_REG + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}                                                                                                          , , "avg_iproc", "avg_iproc")
            */
         ElseIf cTipoArqInt == "XML"
            //Pastas
            oSrv_02:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+RET_REG+NAO_ENVIADO    ,Self:aCposGer ,"Folder5","Folder6")
            oSrv_02:AddFolder("Enviados"     , ENVIADO	    , VENDA+RET_REG+ENVIADO        ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_02:AddFolder("Recebidos"    , RECEBIDO	    , VENDA+RET_REG+RECEBIDO       ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_02:AddFolder("Processados"  , PROCESSADO	, VENDA+RET_REG+PROCESSADO     ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_02:AddFolder("Cancelados"   , CANCELADO	, VENDA+RET_REG+CANCELADO      ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            // oSrv_02:AddAction("Gerar lote de arquivos" , "Act021" , {RET_REG + NAO_ENVIADO,RET_REG + ENVIADO,RET_REG + RECEBIDO,RET_REG + PROCESSADO,RET_REG + CANCELADO} , {|| SS101GerLote(cTipoServ, RET_REG)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_02:AddAction("Gerar lote de arquivos"    , "Act021" , {RET_REG + NAO_ENVIADO} , {| cId          | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, RET_REG),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_02:AddAction("Enviar lote de arquivos"   , "Act022" , {RET_REG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_02:AddAction("Cancelar lote de arquivos" , "Act023" , {RET_REG + NAO_ENVIADO} , {| cWork , cId  | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_02:AddAction("Receber"                   , "Act024" , {RET_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_02:AddAction("Cancelar"                  , "Act025" , {RET_REG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_02:AddAction("Processar"                 , "Act026" , {RET_REG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
                
         EndIf 
         
         oSrv_03 := EECSISSRV():New("Aditivo ao Registro de Venda de Servi�o (Aditivo RVS)"           , "EL8", "Venda", INC_ADI ,1 , "NORMAS", "NORMAS","EL4","Detalhe" ,'EL4_FILIAL+EL4_IDLOTE', "xFilial('EL4')+EL8_IDLOTE")  
         
         If cTipoArqInt == "INI"  
            //Pastas
            oSrv_03:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+INC_ADI+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_03:AddFolder("Integrados"   , RECEBIDO	    , VENDA+INC_ADI+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_03:AddFolder("Processados"  , PROCESSADO	, VENDA+INC_ADI+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_03:AddFolder("Cancelados"   , CANCELADO	, VENDA+INC_ADI+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6") 
            //Acoes
            /*oSrv_03:AddAction("Gerar lote de arquivos"    , "Act031" , {INC_ADI + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , INC_ADI            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_03:AddAction("Enviar lote de arquivos"   , "Act032" , {INC_ADI + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ,),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_03:AddAction("Cancelar lote de arquivos" , "Act033" , {INC_ADI + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_03:AddAction("Processar"                 , "Act036" , {INC_ADI + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}                                                                                                          , , "avg_iproc", "avg_iproc")
            */                                                                                                                                                                                     
         ElseIf cTipoArqInt == "XML"
            //Pastas
            oSrv_03:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+INC_ADI+NAO_ENVIADO    ,Self:aCposGer ,"Folder5","Folder6")
            oSrv_03:AddFolder("Enviados"     , ENVIADO	    , VENDA+INC_ADI+ENVIADO        ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_03:AddFolder("Recebidos"    , RECEBIDO 	, VENDA+INC_ADI+RECEBIDO       ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_03:AddFolder("Processados"  , PROCESSADO	, VENDA+INC_ADI+PROCESSADO     ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_03:AddFolder("Cancelados"   , CANCELADO	, VENDA+INC_ADI+CANCELADO      ,Self:aCposCan ,"Folder5","Folder6")         
            //Acoes
            //oSrv_03:AddAction("Gerar lote de arquivos" , "Act031" , {INC_ADI + NAO_ENVIADO,INC_ADI + ENVIADO,INC_ADI + RECEBIDO,INC_ADI + PROCESSADO,INC_ADI + CANCELADO} , {|| SS101GerLote(cTipoServ, INC_ADI)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_03:AddAction("Gerar lote de arquivos"    , "Act031" , {INC_ADI + NAO_ENVIADO} , {| cId            | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, INC_ADI),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_03:AddAction("Enviar lote de arquivos"   , "Act032" , {INC_ADI + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_03:AddAction("Cancelar lote de arquivos" , "Act033" , {INC_ADI + NAO_ENVIADO} , {| cWork , cId    | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_03:AddAction("Receber"                   , "Act034" , {INC_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_03:AddAction("Cancelar"                  , "Act035" , {INC_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_03:AddAction("Processar"                 , "Act036" , {INC_ADI + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
            
         EndIf         
         
         oSrv_04 := EECSISSRV():New("Retifica��o de Aditivo de Venda de Servi�o (Retifica��o RVS)"    , "EL8", "Venda", RET_ADI ,1 , "NORMAS", "NORMAS","EL4","Detalhe" ,'EL4_FILIAL+EL4_IDLOTE', "xFilial('EL4')+EL8_IDLOTE")  
         
         If cTipoArqInt == "INI"
            //Pastas
            oSrv_04:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+RET_ADI+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_04:AddFolder("Integrados"   , RECEBIDO	    , VENDA+RET_ADI+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_04:AddFolder("Processados"  , PROCESSADO	, VENDA+RET_ADI+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_04:AddFolder("Cancelados"   , CANCELADO	, VENDA+RET_ADI+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")
            //Acoes
            /*oSrv_04:AddAction("Gerar lote de arquivos"    , "Act041" , {RET_ADI + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , RET_ADI            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_04:AddAction("Enviar lote de arquivos"   , "Act042" , {RET_ADI + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_04:AddAction("Cancelar lote de arquivos" , "Act043" , {RET_ADI + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_04:AddAction("Processar"                 , "Act046" , {RET_ADI + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}                                                                                                          , , "avg_iproc", "avg_iproc")
            */          
         ElseIf cTipoArqInt == "XML"  
            //Pastas
            oSrv_04:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+RET_ADI+NAO_ENVIADO    ,Self:aCposGer ,"Folder5","Folder6")
            oSrv_04:AddFolder("Enviados"     , ENVIADO	    , VENDA+RET_ADI+ENVIADO        ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_04:AddFolder("Recebidos"    , RECEBIDO	    , VENDA+RET_ADI+RECEBIDO       ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_04:AddFolder("Processados"  , PROCESSADO	, VENDA+RET_ADI+PROCESSADO     ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_04:AddFolder("Cancelados"   , CANCELADO	, VENDA+RET_ADI+CANCELADO      ,Self:aCposCan ,"Folder5","Folder6")
            //A��es
            //oSrv_04:AddAction("Gerar lote de arquivos" , "Act041" , {RET_ADI + NAO_ENVIADO,RET_ADI + ENVIADO,RET_ADI + RECEBIDO,RET_ADI + PROCESSADO,RET_ADI + CANCELADO} , {|| SS101GerLote(cTipoServ, RET_ADI)} , , "avg_iadd", "avg_iadd")            
            //RRC - 01/02/2013
			oSrv_04:AddAction("Gerar lote de arquivos"    , "Act041" , {RET_ADI + NAO_ENVIADO} , {| cId         | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, RET_ADI),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_04:AddAction("Enviar lote de arquivos"   , "Act042" , {RET_ADI + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_04:AddAction("Cancelar lote de arquivos" , "Act043" , {RET_ADI + NAO_ENVIADO} , {| cWork , cId | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_04:AddAction("Receber"                   , "Act044" , {RET_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_04:AddAction("Cancelar"                  , "Act045" , {RET_ADI + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_04:AddAction("Processar"                 , "Act046" , {RET_ADI + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
            
         EndIf
                  
         oSrv_05 := EECSISSRV():New("Registro de Faturamento de Servi�o (RF)"                         , "EL8", "Venda", INC_PAG ,1 , "NORMAS", "NORMAS","EL5","Detalhe" ,'EL5_FILIAL+EL5_IDLOTE', "xFilial('EL5')+EL8_IDLOTE")  
         
         If cTipoArqInt == "INI" 
            //Pastas
            oSrv_05:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+INC_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_05:AddFolder("Integrados"   , RECEBIDO	    , VENDA+INC_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_05:AddFolder("Processados"  , PROCESSADO	, VENDA+INC_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_05:AddFolder("Cancelados"   , CANCELADO	, VENDA+INC_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6") 
            //Acoes
            /*oSrv_05:AddAction("Gerar lote de arquivos"    , "Act051" , {INC_PAG + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ           , INC_PAG            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_05:AddAction("Enviar lote de arquivos"   , "Act052" , {INC_PAG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId), SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_05:AddAction("Cancelar lote de arquivos" , "Act053" , {INC_PAG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_05:AddAction("Processar"                 , "Act056" , {INC_PAG + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId), SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}   , , "avg_iproc", "avg_iproc")
            */          
         ElseIf cTipoArqInt == "XML" 
            //Pastas
            oSrv_05:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+INC_PAG+NAO_ENVIADO    ,Self:aCposGer ,"Folder5","Folder6")
            oSrv_05:AddFolder("Enviados"     , ENVIADO	    , VENDA+INC_PAG+ENVIADO        ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_05:AddFolder("Recebidos"    , RECEBIDO	    , VENDA+INC_PAG+RECEBIDO       ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_05:AddFolder("Processados"  , PROCESSADO	, VENDA+INC_PAG+PROCESSADO     ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_05:AddFolder("Cancelados"   , CANCELADO	, VENDA+INC_PAG+CANCELADO      ,Self:aCposCan ,"Folder5","Folder6")  
            //Acoes
            //oSrv_05:AddAction("Gerar lote de arquivos" , "Act051" , {INC_PAG + NAO_ENVIADO,INC_PAG + ENVIADO,INC_PAG + RECEBIDO,INC_PAG + PROCESSADO,INC_PAG + CANCELADO} , {|| SS101GerLote(cTipoServ, INC_PAG)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_05:AddAction("Gerar lote de arquivos"    , "Act051" , {INC_PAG + NAO_ENVIADO} , {| cId          | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, INC_PAG),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_05:AddAction("Enviar lote de arquivos"   , "Act052" , {INC_PAG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_05:AddAction("Cancelar lote de arquivos" , "Act053" , {INC_PAG + NAO_ENVIADO} , {| cWork , cId  | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_05:AddAction("Receber"                   , "Act054" , {INC_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_05:AddAction("Cancelar"                  , "Act055" , {INC_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_05:AddAction("Processar"                 , "Act056" , {INC_PAG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
                
         EndIf
                         
         oSrv_06 := EECSISSRV():New("Cancelamento de Faturamento de Servi�o (Cancelamento RF)"        , "EL8", "Venda", CAN_PAG ,1 , "NORMAS", "NORMAS","EL5","Detalhe" ,'EL5_FILIAL+EL5_IDLOTE', "xFilial('EL5')+EL8_IDLOTE")  
         
         If cTipoArqInt == "INI" 
            //Pastas
            oSrv_06:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+CAN_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_06:AddFolder("Integrados"   , RECEBIDO	    , VENDA+CAN_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_06:AddFolder("Processados"  , PROCESSADO	, VENDA+CAN_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_06:AddFolder("Cancelados"   , CANCELADO	, VENDA+CAN_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6") 
            //Acoes
            /*oSrv_06:AddAction("Gerar lote de arquivos"    , "Act061" , {CAN_PAG + NAO_ENVIADO} , {| cId                    | cId := GetId(cId), If(!Empty(cId),  SS101GerLote(cTipoServ           , CAN_PAG            , NAO_ENVIADO                     ),)} , , "avg_iadd" , "avg_iadd" )
            oSrv_06:AddAction("Enviar lote de arquivos"   , "Act062" , {CAN_PAG + NAO_ENVIADO} , {| cWork , ESSCI100 , cId | cId := GetId(cId), If(!Empty(cId),  SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 ),)} , , "avg_ienv" , "avg_ienv" )
            oSrv_06:AddAction("Cancelar lote de arquivos" , "Act063" , {CAN_PAG + NAO_ENVIADO} , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId),  SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel" , "avg_idel" )
            oSrv_06:AddAction("Processar"                 , "Act066" , {CAN_PAG + RECEBIDO}    , {| cWork , cId            | cId := GetId(cId), If(!Empty(cId),  SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100),)}   , , "avg_iproc", "avg_iproc")
            */          
         ElseIf cTipoArqInt == "XML"    
            //Pastas
            oSrv_06:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+CAN_PAG+NAO_ENVIADO    ,Self:aCposGer ,"Folder5","Folder6")
            oSrv_06:AddFolder("Enviados"     , ENVIADO	    , VENDA+CAN_PAG+ENVIADO        ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_06:AddFolder("Recebidos"    , RECEBIDO 	, VENDA+CAN_PAG+RECEBIDO       ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_06:AddFolder("Processados"  , PROCESSADO	, VENDA+CAN_PAG+PROCESSADO     ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_06:AddFolder("Cancelados"   , CANCELADO	, VENDA+CAN_PAG+CANCELADO      ,Self:aCposCan ,"Folder5","Folder6") 
            //A��es
            //oSrv_06:AddAction("Gerar lote de arquivos" , "Act061" , {CAN_PAG + NAO_ENVIADO,CAN_PAG + ENVIADO,CAN_PAG + RECEBIDO,CAN_PAG + PROCESSADO,CAN_PAG + CANCELADO} , {|| SS101GerLote(cTipoServ, CAN_PAG)} , , "avg_iadd", "avg_iadd")
            //RRC - 01/02/2013
			oSrv_06:AddAction("Gerar lote de arquivos"    , "Act061" , {CAN_PAG + NAO_ENVIADO} , {| cId          | cId := GetId(cId), If(!Empty(cId),  SS101GerLote(cTipoServ, CAN_PAG),)} 																			   , , "avg_iadd"  , "avg_iadd")
			oSrv_06:AddAction("Enviar lote de arquivos"   , "Act062" , {CAN_PAG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_06:AddAction("Cancelar lote de arquivos" , "Act063" , {CAN_PAG + NAO_ENVIADO} , {| cWork , cId  | cId := GetId(cId), If(!Empty(cId),  SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_06:AddAction("Receber"                   , "Act064" , {CAN_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_06:AddAction("Cancelar"                  , "Act065" , {CAN_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_06:AddAction("Processar"                 , "Act066" , {CAN_PAG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")
                 
         EndIf
         
         oSrv_07 := EECSISSRV():New("Retifica��o de Faturamento de Servi�o (RF)"                           , "EL8", "Venda"       , RET_PAG ,1 , "NORMAS", "NORMAS","EL5","Detalhe" ,"EL5_FILIAL+EL5_IDLOTE", "xFilial('EL5')+EL8_IDLOTE")  

         If cTipoArqInt == "INI"
            //Pastas
            oSrv_07:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+RET_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_07:AddFolder("Integrados"   , RECEBIDO	    , VENDA+RET_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_07:AddFolder("Processados"  , PROCESSADO	, VENDA+RET_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_07:AddFolder("Cancelados"   , CANCELADO	, VENDA+RET_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")

            ElseIf cTipoArqInt == "XML" 
            //Pastas
            oSrv_07:AddFolder("N�o enviados" , NAO_ENVIADO  , VENDA+RET_PAG+NAO_ENVIADO,Self:aCposGer ,"Folder5","Folder6")
            oSrv_07:AddFolder("Enviados"     , ENVIADO	    , VENDA+RET_PAG+ENVIADO    ,Self:aCposEnv ,"Folder5","Folder6") 
            oSrv_07:AddFolder("Recebidos"    , RECEBIDO 	, VENDA+RET_PAG+RECEBIDO   ,Self:aCposRec ,"Folder5","Folder6")
            oSrv_07:AddFolder("Processados"  , PROCESSADO	, VENDA+RET_PAG+PROCESSADO ,Self:aCposPrc ,"Folder5","Folder6")
            oSrv_07:AddFolder("Cancelados"   , CANCELADO	, VENDA+RET_PAG+CANCELADO  ,Self:aCposCan ,"Folder5","Folder6")

            oSrv_07:AddAction("Gerar lote de arquivos"    , "Act051" , {RET_PAG + NAO_ENVIADO} , {| cId         | cId := GetId(cId), If(!Empty(cId), SS101GerLote(cTipoServ, RET_PAG),)} 																			   , , "avg_iadd"  , "avg_iadd")
            oSrv_07:AddAction("Enviar lote de arquivos"   , "Act052" , {RET_PAG + NAO_ENVIADO} , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork , ESSCI100 | SS101EnvLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV, (cWork)->EL8_IDLOTE , ESSCI100 )*/} , , "avg_ienv"  , "avg_ienv" )
            oSrv_07:AddAction("Cancelar lote de arquivos" , "Act053" , {RET_PAG + NAO_ENVIADO} , {| cWork , cId | cId := GetId(cId), If(!Empty(cId), SS101CanLote((cWork)->EL8_IDLOTE),) }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_07:AddAction("Receber"                   , "Act054" , {RET_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")}   , , "avg_import", "avg_import")
            oSrv_07:AddAction("Cancelar"                  , "Act055" , {RET_PAG + ENVIADO}     , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*cWork             | SS101CanLote((cWork)->EL8_IDLOTE)*/ }                                                        , , "avg_idel"  , "avg_idel" )
            oSrv_07:AddAction("Processar"                 , "Act056" , {RET_PAG + RECEBIDO}    , {||EasyHelp("Esta op��o est� indispon�vel no momento.","Aviso")/*| cWork             | SS101ProcLote((cWork)->EL8_TPPROC , (cWork)->EL8_TIPENV,(cWork)->EL8_IDLOTE, ESSCI100)*/}   , , "avg_iproc" , "avg_iproc")

         EndIf

   End Case

   //Adicionando todos os servi�os
   aAdd(Self:aServices, oSrv_01)
   aAdd(Self:aServices, oSrv_02)
   aAdd(Self:aServices, oSrv_03)
   aAdd(Self:aServices, oSrv_04)
   aAdd(Self:aServices, oSrv_05)
   aAdd(Self:aServices, oSrv_06)
   If EasyGParam("MV_ESS0027",,9) >= 10
      aAdd(Self:aServices, oSrv_07)
   EndIf
   
Return Nil

Method Show() Class ESSCI100
Local aServicos := {}
Local aAcoes  := {}
Local nInc
   
   //RRC - 03/05/2013 - Adiciona a a��o de "Reprocessar"
   For nInc := 1 To Len(Self:aActions)
      aEval(Self:RetActions(), {|x| aAdd(aAcoes, x) })
   Next

   For nInc := 1 To Len(Self:aServices)
      aAdd(aServicos, Self:aServices[nInc]:RetService())
      aEval(Self:aServices[nInc]:RetActions(), {|x| aAdd(aAcoes, x) })
   Next
   
   AvCentIntegracao(aServicos, aAcoes, Self:cName, Self:cSrvName, Self:cActName, Self:cTreeSrvName, Self:cTreeAcName, Self:cPanelName, Self:bOk, Self:bCancel, Self:cIconSrv, Self:cIconAction, .T., .T.,"{|x| CI100VisDet(x) }","{|oMsSelect| CI100VisErro(oMsSelect)}",.F.)

Return Nil

Method SetDiretorios() Class ESSCI100

Private cDirGerados     := "" 
Private cDirEnviados    := ""
Private cDirRecebidos   := ""
Private cDirRejeitados  := ""
Private cDirProcessados := ""
   
If IsSrvUnix()
   //If EasyGParam("MV_AVG0221",,"INI") == "INI"
      Self:cDirGerados     := "/comex/siscoserv/naoenviados/"
      Self:cDirEnviados    := "/comex/siscoserv/enviados/"
      Self:cDirRecebidos   := "/comex/siscoserv/integrados/"
      Self:cDirRejeitados  := "/comex/siscoserv/cancelados/"
      Self:cDirProcessados := "/comex/siscoserv/processados/"   
   /*
   Else      
      Self:cDirGerados     := "/comex/siscoserv/gerados/"
      Self:cDirEnviados    := "/comex/siscoserv/enviados/"
      Self:cDirRecebidos   := "/comex/siscoserv/recebidos/"
      Self:cDirRejeitados  := "/comex/siscoserv/rejeitados/"
      Self:cDirProcessados := "/comex/siscoserv/integrados/"   
   EndIf
   */
Else
   //If EasyGParam("MV_AVG0221",,"INI") == "INI"
      Self:cDirGerados     := "\comex\siscoserv\naoenviados\"
      Self:cDirEnviados    := "\comex\siscoserv\enviados\"
      Self:cDirRecebidos   := "\comex\siscoserv\integrados\"
      Self:cDirRejeitados  := "\comex\siscoserv\cancelados\"
      Self:cDirProcessados := "\comex\siscoserv\processados\"     
   /*
   Else
      Self:cDirGerados     := "\comex\siscoserv\gerados\"
      Self:cDirEnviados    := "\comex\siscoserv\enviados\"
      Self:cDirRecebidos   := "\comex\siscoserv\recebidos\"
      Self:cDirRejeitados  := "\comex\siscoserv\rejeitados\"
      Self:cDirProcessados := "\comex\siscoserv\integrados\"
   EndIf
   */
EndIf   
   
If FindFunction("AvUpdate01") 
   oUpdAtu := AvUpdate01():New()
   cDirGerados     := Self:cDirGerados         //NaoEnviados
   cDirEnviados    := Self:cDirEnviados        //Enviados
   cDirRecebidos   := Self:cDirRecebidos       //Integrados
   cDirRejeitados  := Self:cDirRejeitados      //Cancelados
   cDirProcessados := Self:cDirProcessados     //Processados
EndIf

If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
   oUpdAtu:aChamados := {{nModulo,{|o| CriaDir(o)}}}
   oUpdAtu:Init(,.T.)
EndIf
   
Self:cDirRoot := GetSrvProfString("ROOTPATH","")
//Self:cDirLoc  := Self:oUserParams:LoadParam("NUMDIRLOC", "","ESSCI100")

Return Nil

/*
M�todo     : EditConfigs()
Classe     : EICINTSISWEB
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Edi��o de configura��es do usuario
*/
*---------------------------------*
Method EditConfigs() Class ESSCI100
*---------------------------------*
Local nLin := 5, nCol := 12
Local lRet := .F.
Local bOk := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local oUserParams := EASYUSERCFG():New("ESSCI100")
Local cDirJava  := oUserParams:LoadParam("JAVA","","ESSCI100")
Local cPrxUrl   := If(!Empty(oUserParams:LoadParam("PROXYURL","","ESSCI100")),oUserParams:LoadParam("PROXYURL"), "")
Local cPrxPrt   := If(!Empty(oUserParams:LoadParam("PROXYPRT","","ESSCI100")),oUserParams:LoadParam("PROXYPRT"), "")
Local cPrxUsr   := If(!Empty(oUserParams:LoadParam("PROXYUSR","","ESSCI100")),oUserParams:LoadParam("PROXYUSR"), "")
Local cPrxPss   := If(!Empty(oUserParams:LoadParam("PROXYPSS","","ESSCI100")),oUserParams:LoadParam("PROXYPSS"), "")

Local bSetFileJav := {|| cDirJava  := cGetFile("","Diret�rio local onde encontra-se o execut�vel 'Java.exe'.", 0, cDirJava ,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }
   
   cPrxUrl := If(Empty(cPrxUrl), Space(100), cPrxUrl)
   cPrxPrt := If(Empty(cPrxPrt), Space(6)  , cPrxPrt)
   cPrxUsr := If(Empty(cPrxUsr), Space(50) , cPrxUsr)
   cPrxPss := If(Empty(cPrxPss), Space(50) , cPrxPss)
   
   DEFINE MSDIALOG oDlg TITLE "Configura��es para o usu�rio: " + cUserName FROM 320,400 TO 770,785 OF oMainWnd PIXEL
   
      nLin += 35 //VPB 26/10/2016

      @ nLin,nCol Say "Diret�rio local onde encontra-se o execut�vel 'Java.exe'." Size 160,08 PIXEL OF oDlg
      nLin += 10
      @ nLin,nCol MsGet cDirJava Size 150,08 PIXEL WHEN .F. OF oDlg
      @ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileJav) SIZE 10,10 PIXEL OF oDlg	

      nLin += 25
      @ nLin, 6 To 210, 181 Label "Configura��es de Proxy" Of oDlg Pixel
      nLin += 10
      @ nLin,nCol Say "URL:" Size 160,08 PIXEL OF oDlg
      nLin += 10
      @ nLin,nCol MsGet cPrxUrl Size 150,08 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say "Porta:" Size 160,08 PIXEL OF oDlg
      nLin += 10
      @ nLin,nCol MsGet cPrxPrt Size 150,08 PIXEL OF oDlg
      
      nLin += 20
      @ nLin,nCol Say "Usu�rio:" Size 160,08 PIXEL OF oDlg
      nLin += 10
      @ nLin,nCol MsGet cPrxUsr Size 150,08 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say "Senha:" Size 160,08 PIXEL OF oDlg
      nLin += 10
      @ nLin,nCol MsGet cPrxPss Password Size 150,08 PIXEL OF oDlg


   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      oUserParams:SetParam("JAVA" , cDirJava ,"ESSCI100")
      oUserParams:SetParam("PROXYURL", cPrxUrl,"ESSCI100")
      oUserParams:SetParam("PROXYPRT", cPrxPrt,"ESSCI100")
      oUserParams:SetParam("PROXYUSR", cPrxUsr,"ESSCI100")
      oUserParams:SetParam("PROXYPSS", cPrxPss,"ESSCI100")
   EndIf

Return Nil

Method GerarLote() Class ESSCI100

Local cArquivo       := ""
Local cServico       := ""
Local aDesp          := {}
//Private cFaseOR102   := cFaseOR102 // Variavel a ser tratada na fun��o EICOR102(), para definir a fase
Private cCodDeEI100  := "" // Variavel a ser tratada na fun��o Ori100Main()
Private cDespEI100   := "" // Variavel a ser tratada na fun��o Ori100Main()
Private cEmailEI100  := "" // Variavel a ser tratada na fun��o Ori100Main()

//MsgInfo("TESTE - EM DESENVOLVIMENTO")
/* nopado trecho por RNLP - Fun��o n�o compilada/declarada em nenhum fonte do sistema
ESSCI101()
*/
//PROGRAMAR ACAO
/*
Begin Sequence
   
   If cFaseOR102 == "PO"
      cServico := ENV_PO
   Else
      cServico := ENV_DI
   EndIf

   // A gera��o do arquivo esta definida na fun��o Ori100Main(), onde foram realizado tratamentos para indicar o diretorio
   cArquivo := EICOR102()

   If !Empty(cArquivo) .And. Valtype(cArquivo) == "C"
      aDesp := {cCodDeEI100, cDespEI100, cEmailEI100}
      Self:GravaEWZ(cArquivo, cServico, GERADOS,aDesp)
   Else
      MsgInfo("Arquivo n�o gerado.","Aten��o")
      If Select("TRB") > 0
         TRB->(DBCloseArea())
      EndIf
   EndIf

End Sequence
*/
Return Nil

Method ProcessarArq(cWork,cServico) Class ESSCI100

Local lRet     := .T.
Local nOpcao   := 0
Local aDesp    := {}
Local cDestino := ""
Local cStatus  := ""
Local cFileOld := ""
Private cFileEICEI100 := ""  // Variavel para guardar o nome do txt da nova integra��o para ser tratada na fun��o IN100Integ()
Private cStatusEI100  := Nil // Variavel para verificar o status (aceito ou rejeitado) do arquivo na fun��o IN100Integ()
Private lPrvEI100     := .F. // Variavel para verificar se � .T. - para integra��o ou .F. - para previa na fun��o IN100Integ()

Begin Sequence

   Do Case
      Case cServico == REC_NUMERARIO .Or. cServico == REC_DESPESAS
         aDesp  := {(cWork)->EWZ_CODDES,(cWork)->EWZ_NOMEDE,(cWork)->EWZ_EMAIL}
         nOpcao := 10
         If cServico == REC_NUMERARIO
            nOpcao := 13
         EndIf
      Case cServico == REC_NF
         aDesp  := {(cWork)->EWZ_CODDES,(cWork)->EWZ_NOMEDE,(cWork)->EWZ_EMAIL}
         nOpcao := 12
      Otherwise
         Return Nil
   EndCase

   If Empty((cWork)->EWZ_ARQUIV)
      MsgInfo("Selecione um registro para ser processado.","Aten��o")
      Break
   Else 
      cFileEICEI100 := (cWork)->EWZ_ARQUIV
   EndIf

   // Alterando a extensao do arquivo na variavel para que seja possivel mover o arquivo
   cFileOld := StrTran(Upper((cWork)->EWZ_ARQUIV), ".TXT", ".OLD")
   EWZ->(DbSetOrder(2))
   If EWZ->(DbSeek(xFilial("EWZ") + AvKey(cServico,"EWZ_SERVIC") + AvKey(cFileOld,"EWZ_ARQUIV")))
      cStatus := If (EWZ->EWZ_STATUS == REJEITADOS, "rejeitado", "integrado")
      lRet := MsgYesNo("O arquivo " + AllTrim(Upper((cWork)->EWZ_ARQUIV)) + " esta com status '" + AllTrim(cStatus)+ "' pelo usuario '" + AllTrim(EWZ->EWZ_USERPR) + "'."+;
      ENTER + "Deseja processar o arquivo novamente?","Aten��o")
   EndIf

   If lRet

      EICIN100(nOpcao,,.T.)
      If Type("cStatusEI100") == "C"

         If lPrvEI100
            (cWork)->(DbGoTop())
            Break
         EndIf

         If cStatusEI100 == "T"
            cDestino := Self:cDirRoot+Self:cDirProcessados+cFileOld
            cStatus  := INTEGRADOS
         Else
            cDestino := Self:cDirRoot+Self:cDirRejeitados+cFileOld
            cStatus  := REJEITADOS
         EndIf

         If !CopiaArq(Self:cDirRoot+Self:cDirRecebidos+cFileOld,cDestino,.T.)
            Break
         EndIf
            
         // Gravando na tabela de controle da nova integra��o com despachante
         If !Self:GravaEWZ((cWork)->EWZ_ARQUIV, cServico, cStatus, aDesp)
            Break
         EndIf

      EndIf

   EndIf

End Sequence

Return nil

Method GravaEWZ(cArquivo, cServico, cStatus, aDesp) Class ESSCI100
Local i       := 0
Local lRet    := .T.
Local cSeek   := "" 
Local lNew    := .T.
Default aDesp := {}

Begin Sequence

   Do Case 

      // Servico de Numerario ou Despesas ou NF para status de recebidos
      Case cStatus == RECEBIDOS
         aCampos := Self:aCposRec
         If cServico == REC_NF
            aCampos := Self:aCposRecNF
         EndIf

      // Servico de Numerario ou Despesas ou NF para status de integrados ou rejeitados
      Case cStatus == INTEGRADOS .Or. cStatus == REJEITADOS
         aCampos  := Self:aCposPrc
         EWZ->(DbSetOrder(1))
         lNew := !EWZ->(DbSeek(xFilial("EWZ")+AvKey(cServico,"EWZ_SERVIC")+AvKey(RECEBIDOS,"EWZ_STATUS")+AvKey(cArquivo,"EWZ_ARQUIV")))
         cArquivo := StrTran(Upper(cArquivo), ".TXT", ".OLD")
         If cServico == REC_NF
            aCampos := Self:aCposPrcNF
         End

      Case cStatus == GERADOS
         aCampos := Self:aCposGer

      Case cStatus == ENVIADOS
         aCampos := Self:aCposEnv
         EWZ->(DbSetOrder(1))
         lNew := !EWZ->(DbSeek(xFilial("EWZ")+AvKey(cServico,"EWZ_SERVIC")+AvKey(GERADOS,"EWZ_STATUS")+AvKey(cArquivo,"EWZ_ARQUIV")))

   End Case

   If RecLock("EWZ", lNew)
      EWZ->EWZ_FILIAL    := xFilial("EWZ")
      EWZ->EWZ_SERVIC    := cServico
      EWZ->EWZ_STATUS    := cStatus
      EWZ->EWZ_ARQUIV    := Upper(cArquivo)
      EWZ->&(aCampos[AScan(aCampos,"EWZ_USER")]) := cUserName
      EWZ->&(aCampos[AScan(aCampos,"EWZ_DATA")]) := dDataBase
      EWZ->&(aCampos[AScan(aCampos,"EWZ_HORA")]) := Time()
      If Len(aDesp) > 0
         EWZ->EWZ_CODDES    := aDesp[1]
         EWZ->EWZ_NOMEDE    := aDesp[2]
         EWZ->EWZ_EMAIL     := aDesp[3]
      EndIf
      EWZ->(MsUnLock())
   EndIf

End Sequence

Return lRet

Method RetActions() Class ESSCI100

Return Self:aActions

Method AddAction(cName, cId, aIDs, bAction, cStatus, cIconOpen, cIconClose) Class ESSCI100

   aAdd(Self:aActions, {cName, cId, aIDs, bAction, cStatus, cIconOpen, cIconClose})

Return Nil

Static Function AltExtensao(cArquivo,cDeExt,cParaExt)
Local cArquivo := Upper(cArquivo)
Local cDeExt   := Upper(cDeExt)
Local cParaExt := Upper(cParaExt)
Local cFileDes := ""

Begin Sequence
   // Renomeando arquivo processados (integrados ou rejeitados)
   If At(cDeExt,cArquivo) > 0
      cFileDes := StrTran(cArquivo,  cDeExt, cParaExt)
      If !(FRename(cArquivo,cFileDes) == 0)
         MsgInfo("N�o foi poss�vel renomear o arquivo " + cArquivo + " para " + cFileDes + ".")
         Break
      EndIf
   Else
      cFileDes := cArquivo
   EndIf
End Sequence

Return cFileDes

Static Function CopiaArq(cArqOri,cArqDest,lDelArqOri)
Local lRet := .F.
Default lDelArqOri := .F.
Begin Sequence

   If !File(cArqOri)
      MsgInfo(StrTran("O arquivo '###' n�o foi encontrado. N�o ser� poss�vel executar a rotina.", "###", cArqOri), "Aviso")
      Break
   EndIf
   
   __CopyFile(cArqOri, cArqDest)
   
   If !File(cArqDest)
      MsgInfo(StrTran("O arquivo '###' n�o foi encontrado. N�o ser� poss�vel executar a rotina.", "###", cArqDest), "Aviso")
      Break
   EndIf

   If lDelArqOri
      If FErase(cArqOri) <> 0
         MsgInfo(StrTran("O arquivo '###' n�o foi exclu�do.", "###", cArqOri), "Aviso")
         Break
      EndIf
   EndIf
   
   lRet := .T.

End Sequence

Return lRet

Static Function CriaDir(o)
      
o:TableData('DIRETORIO',{cDirGerados},,.F.)
o:TableData('DIRETORIO',{cDirEnviados},,.F.)
o:TableData('DIRETORIO',{cDirRecebidos},,.F.)
o:TableData('DIRETORIO',{cDirRejeitados},,.F.)
o:TableData('DIRETORIO',{cDirProcessados},,.F.)

Return Nil

/*
Funcao      : CI100VisDet
Parametros  : Objeto da AvCentIntegracao (AVFRM105.PRW)
Retorno     : Nenhum
Objetivos   : Visualizar detalhes dos lotes RAS e RVS
Autor       : Raphael Rodrigues Ventura
Data/Hora   : 28/03/2013 - 11:35:00
*/

Function CI100VisDet(cId)
Local aNomeFolders  := {"Itens","Documentos"}
Local aPosTela  := {}
Local oDlg
Local oFld
Local oEnch
Local oMsSelMer
Local oMsSelFab
Local oMsSelDrB
Local cAliasOld := Alias()
Local cCpoCapa  := ""
Local cCpoDet   := ""
Local aOrd := SaveOrd("EL7")
PRIVATE lInvert := .F.

   DEFINE MSDIALOG oDlg TITLE "Detalhes do Lote" FROM 0,0;
                                                 TO DLG_LIN_FIM*0.9, DLG_COL_FIM*0.7;
                                                 OF oMainWnd PIXEL
   If cId:oBrowse:cAlias == "EL3"
      aPosTelaUp  := PosDlgUp(oDlg)
      aPosTelaDown:= POsDlgDown(oDlg)	
      oEnch := MsMGet():New("EL3", EL3->(Recno()), VISUALIZAR,,,,, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3],aPosTelaUp[4]})
      oEnch:oBox:Align := CONTROL_ALIGN_TOP
   
      //Cria��o do Folder.
      oFld := TFolder():New(aPosTelaDown[1]+35,aPosTelaDown[2]-1,aNomeFolders,aNomeFolders,oDlg,,,,.T.,.F.,aPosTelaDown[4],aPosTelaDown[4]-260)
      oFld:Align := CONTROL_ALIGN_ALLCLIENT
   
      aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
      oFldLt    := oFld:aDialogs[1]
      oFldDoc   := oFld:aDialogs[2]  
      aPosTela  := PosDlg(oFldLt)
     
      // Filtro para exibi��o da msSelect para os itens
      cCpoCapa := "xFilial('EL3')+EL3->EL3_IDLOTE+EL3->EL3_TPPROC+EL3->EL3_REGIST"
      cCpoDet  := "EL4_FILIAL+EL4_IDLOTE+EL4_TPPROC+EL4_REGIST"
      oMsSelMer := MsSelect():New("EL4",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldLt)
      oMsSelMer:oBrowse:Hide()
      oMsSelMer:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelMer:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
      oMsSelMer:oBrowse:Refresh()
      oMsSelMer:oBrowse:Show()
  
      // Filtro para exibi��o da msSelect para os documentos
      EL7->(dBSETORDER(3))
      cCpoCapa := "xFilial('EL3')+EL3->EL3_TPPROC+EL3->EL3_REGIST+EL3->EL3_SQEVCP"
      cCpoDet  := "EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP"
      oMsSelFab := MsSelect():New("EL7",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldDoc)
      oMsSelFab:oBrowse:Hide()
      oMsSelFab:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelFab:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
      oMsSelFab:oBrowse:Refresh()
      oMsSelFab:oBrowse:Show()
   
   ElseIf cId:oBrowse:cAlias == "EL5"
      aPosTelaUp  := PosDlgUp(oDlg)
      aPosTelaDown:= POsDlgDown(oDlg)	
      oEnch := MsMGet():New("EL5", EL3->(Recno()), VISUALIZAR,,,,, {aPosTelaUp[1]-14.5,aPosTelaUp[2]-1,aPosTelaUp[3],aPosTelaUp[4]})
      oEnch:oBox:Align := CONTROL_ALIGN_TOP
   
      //Cria��o do Folder.
      oFld := TFolder():New(aPosTelaDown[1]+35,aPosTelaDown[2]-1,aNomeFolders,aNomeFolders,oDlg,,,,.T.,.F.,aPosTelaDown[4],aPosTelaDown[4]-260)
      oFld:Align := CONTROL_ALIGN_ALLCLIENT
   
      aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
      oFldLt    := oFld:aDialogs[1]
      oFldDoc   := oFld:aDialogs[2]  
      aPosTela  := PosDlg(oFldLt)
   
      // Filtro para exibi��o da msSelect para os itens
      cCpoCapa := "xFilial('EL5')+EL5->EL5_TPPROC+EL5->EL5_REGIST+EL5->EL5_SEQPAG+EL5->EL5_SQEVPG"
      cCpoDet  := "EL6_FILIAL+EL6_TPPROC+EL6_REGIST+EL6_SEQPAG+EL6_SQEVPG"
      oMsSelMer := MsSelect():New("EL6",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldLt)
      oMsSelMer:oBrowse:Hide()
      oMsSelMer:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelMer:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
      oMsSelMer:oBrowse:Refresh()
      oMsSelMer:oBrowse:Show()
  
      // Filtro para exibi��o da msSelect para os documentos
      EL7->(dBSETORDER(3))
      cCpoCapa := "xFilial('EL5')+EL5->EL5_TPPROC+EL5->EL5_REGIST+EL5->EL5_SQEVPG"
      cCpoDet  := "EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP"
      oMsSelFab := MsSelect():New("EL7",,,,@lInvert,,{aPosTela[1]-14.25,aPosTela[2],aPosTela[3]+3.75,aPosTela[4]+2.40},,,oFldDoc)
      oMsSelFab:oBrowse:Hide()
      oMsSelFab:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelFab:oBrowse:SetFilter(cCpoDet,&(cCpoCapa),&(cCpoCapa))
      oMsSelFab:oBrowse:Refresh()
      oMsSelFab:oBrowse:Show()
   EndIf

ACTIVATE MSDIALOG oDlg Centered

DbSelectArea(cAliasOld)
RestOrd(aOrd, .T.)

Return Nil

//TRP - 17/12/12
//GetId(cId) - Ajusta o Id da pasta selecionada 
//RRC - Utiliza��o da fun��o GetId() origin�ria do fonte EICEI100.PRW
Static Function GetId(cId)

	cId := Alltrim(StrTran(cId, "oS", ""))
	
	If cId <> "RAIZ"
		cId := Left(cId, 3)
	Else
		MsgInfo("Selecione uma pasta v�lida para execu��o da a��o.", "Aviso")
		cId := ""
	EndIf

Return cId

/*
Programa   : CI100TpOper()
Objetivo   : Retornar o tipo de opera��o utilizada
Par�metros : cId
Retorno    : cTpOper
Autor      : Rafael Ramos Capuano
Data       : 02/07/2013 - 13:47
*/

Static Function CI100TpOper(cId)
Local cTpOper := ""

Do Case 
   Case AllTrim(cId) == INC_REG + NAO_ENVIADO
      cTpOper := INC_REG
   Case AllTrim(cId) == RET_REG + NAO_ENVIADO
      cTpOper := RET_REG
   Case AllTrim(cId) == INC_ADI + NAO_ENVIADO
      cTpOper := INC_ADI
   Case AllTrim(cId) == RET_ADI + NAO_ENVIADO
      cTpOper := RET_ADI
   Case AllTrim(cId) == INC_PAG + NAO_ENVIADO
      cTpOper := INC_PAG
   Case AllTrim(cId) == CAN_PAG + NAO_ENVIADO
      cTpOper := CAN_PAG   
   Case AllTrim(cId) == RET_PAG + NAO_ENVIADO
      cTpOper := RET_PAG 
EndCase

Return cTpOper

/*
Programa   : CI100VisErro()
Objetivo   : Retornar mensagem de erro
Par�metros : oMsSelect
Retorno    : -
Autor      : Marcos R R Cavini Filho
Data       : 19/01/2016
*/

Function CI100VisErro(oMsSelect)
Local cMemo := ""
Local cAlias := oMsSelect:oBrowse:cAlias
   
   EL8->(dbSetOrder(2))
   If EL8->(DbSeek(xFilial("EL8")+ AvKey((cAlias)->EL8_IDLOTE,"EL8_IDLOTE") )) .And. EL8->(FieldPos("EL8_CODERR")) > 0
      cMemo := MSMM(EL8->EL8_CODERR,AVSX3("EL8_ERROS",AV_TAMANHO),,,LERMEMO)
   EndIf
   
   If !Empty(cMemo)
      EECView(cMemo, "Aten��o")
   Endif

Return nil

Function CI100IsJava()
/*Local cDir
Static lJava := NIL

If ValType(lJava) == "U"
   cDir := GetClientDir()
   cDir += if(SubStr(cDir,Len(cDir)-1,1)$"\/","","\")
   
   lJava := File(cDir+"tr-sw-web-solution-siscoserv.jar")
EndIf
*/
Return .T. //THTS - 09/06/2020 - OSSME-4709
