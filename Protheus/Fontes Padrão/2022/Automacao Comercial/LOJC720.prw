#Include 'Protheus.ch'
#Include 'FWEditPanel.ch'
#Include 'fwmvcdef.ch'
#Include 'LOJC720.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJC720

Consulta Devolucoes realizadas via LOJA

@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
Function LOJC720()

Local aButtons :=  {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0030/*Exportar Excel*/},{.T.,STR0031 /*Fechar*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

FWExecView(STR0001,"LOJC720",MODEL_OPERATION_UPDATE,,{|| /*CloseOnOk*/ .F.},,,aButtons,{||l720Close()})//STR0001 - Consulta Devoluções 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Define o modelo 

@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStr := l720getMSt(1)
Local oStrDet := l720getDSt(1)

	oModel := MPFormModel():New('LOJC720',,, { |oModel| lOk := l720Commit(oModel) })

    oModel:SetDescription(STR0002)//Relatório
	
	oModel:AddFields("MASTER",,oStr,,,{|| l720LoadM() })
	oModel:getModel("MASTER"):SetDescription("DADOS")

    oModel:addGrid('DETAIL','MASTER',oStrDet,,,,,{|| l720InitD() })      
  
    oModel:GetModel("DETAIL"):SetOnlyQuery(.T.) 
    oModel:GetModel("DETAIL"):SetOptional(.T.)

    oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Define a view

@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel := ModelDef() 
Local oStr:= l720getMSt(2)
Local oStrDet := l720getDSt(2)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('FORM1' , oStr,'MASTER' ) 
    oView:AddGrid('FORM2' , oStrDet,'DETAIL' ) 
	
    oView:AddUserButton(STR0013,'', {||MsgRun(STR0035, STR0034, { || lOk := l720loadD() })} ,STR0013,,,.T.)//Buscando registros... Aguarde
    
    oView:CreateVerticalBox( 'BOXFORM1', 15)    
    oView:CreateVerticalBox( 'BOXFORM2', 85)
	
    oView:SetOwnerView('FORM1','BOXFORM1')
    oView:SetOwnerView('FORM2','BOXFORM2')
	
    oView:SetViewProperty('FORM1' , 'SETLAYOUT' , {FF_LAYOUT_VERT_DESCR_TOP, 1} ) 
	
    oView:EnableTitleView('FORM1' , STR0028 ) //Parâmetros
    oView:EnableTitleView('FORM2' , STR0026 ) //Devoluções

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} l720getMSt

Retorna os campos da estrutura do modelo master

@param nOpc - Modelo da estrutura retornada, 1: Model, 2: View
@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
Static function l720getMSt(nOpc)

Local oStruct 

Default nOpc := 1

    if nOpc == 1
        oStruct := FWFormModelStruct():New()

        /*Parâmetros AddField: <cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ],
         [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ]*/ 

        oStruct:AddField(STR0003, STR0003, 'FILIAL_DE', 'C', TamSX3("D1_FILORI")[1]    , 0, , , {}, .F., , .F., .F., .F., , )//STR0003 - Filial de:
        oStruct:AddField(STR0004, STR0004, 'FILIAL_ATE', 'C', TamSX3("D1_FILORI")[1]    , 0, , , {}, .F., , .F., .F., .F., , )//STR0004 - Filial até:
        
        oStruct:AddField(STR0005, STR0005, 'PROD_DE', 'C', TamSX3("D1_COD")[1]       , 0, , , {}, .F., , .F., .F., .F., , )//STR0005 - Produto de:
        oStruct:AddField(STR0006, STR0006, 'PROD_ATE', 'C', TamSX3("D1_COD")[1]       , 0, , , {}, .F., , .F., .F., .F., , )//STR0006 - Produto até:
        
        oStruct:AddField(STR0007, STR0007, 'DATA_DE', 'D', TamSX3("D1_EMISSAO")[1]   , 0, , , {}, .F., , .F., .F., .F., , )//STR0007 - Data de:
        oStruct:AddField(STR0008, STR0008, 'DATA_ATE', 'D', TamSX3("D1_EMISSAO")[1]   , 0, , , {}, .F., , .F., .F., .F., , )//STR0008 - Data até:
        
        oStruct:AddField(STR0009, STR0009, 'CLIENTE_DE', 'C', TamSX3("D1_FORNECE")[1]   , 0, , , {}, .F., , .F., .F., .F., , )//STR0009 - Cliente de:
        oStruct:AddField(STR0010, STR0010, 'CLIENTE_ATE', 'C', TamSX3("D1_FORNECE")[1]   , 0, , , {}, .F., , .F., .F., .F., , )//STR0010 - Cliente até:
        
        oStruct:AddField(STR0011, STR0011, 'LOJA_DE', 'C', TamSX3("D1_LOJA")[1]      , 0, , , {}, .F., , .F., .F., .F., , )//STR0011 - Loja de:
        oStruct:AddField(STR0012, STR0012, 'LOJA_ATE', 'C', TamSX3("D1_LOJA")[1]      , 0, , , {}, .F., , .F., .F., .F., , )//STR0012 - Loja até:
       
    else
        oStruct := FWFormViewStruct():New()
        
        /*Parâmetros AddField: [cIdField],[cOrdem],[cTitulo],[cDescric],[aHelp],[cType],[cPicture],[bPictVar],[cLookUp],[lCanChange],
            [cFolder],[cGroup],[aComboValues],[nMaxLenCombo],[cIniBrow],[lVirtual],[cPictVar],[lInsertLine],[nWidth]*/

        oStruct:AddField( 'FILIAL_DE','1', STR0003, STR0003,,'Get' ,,,"SM0",.T.,,,,,,,, )//STR0003 - Filial de:
        oStruct:AddField( 'FILIAL_ATE','2', STR0004, STR0004,,'Get' ,,,"SM0",.T.,,,,,,,, )//STR0004 - Filial até:
        
        oStruct:AddField( 'PROD_DE','3', STR0005, STR0005,,'Get' ,,,"SB1",.T.,,,,,,,, )//STR0005 - Produto de:
        oStruct:AddField( 'PROD_ATE','4', STR0006, STR0006,,'Get' ,,,"SB1",.T.,,,,,,,, )//STR0006 - Produto até:
        
        oStruct:AddField( 'DATA_DE','5', STR0007, STR0007,,'Get' ,,,,.T.,,,,,,,, )//STR0007 - Data de:
        oStruct:AddField( 'DATA_ATE','6', STR0008, STR0008,,'Get' ,,,,.T.,,,,,,,, )//STR0008 - Data até:
        
        oStruct:AddField( 'CLIENTE_DE','7', STR0009, STR0009,,'Get' ,,,"SA1",.T.,,,,,,,, )//STR0009 - Cliente de:
        oStruct:AddField( 'LOJA_DE','8', STR0011, STR0011,,'Get' ,,,,.T.,,,,,,,, )//STR0011 - Loja de:
        
        oStruct:AddField( 'CLIENTE_ATE','9', STR0010, STR0010,,'Get' ,,,"SA1",.T.,,,,,,,, )//STR0010 - Cliente até:
        oStruct:AddField( 'LOJA_ATE','A', STR0012, STR0012,,'Get' ,,,,.T.,,,,,,,, )//STR0012 - Loja até:
        
    endif

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} l720LoadM

Carrega dados default no master

@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
Static Function l720LoadM()
Local aLoad := {}
Local cProd := space(TamSX3("D1_COD")[1])
Local cCli  := space(TamSX3("D1_FORNECE")[1])
Local cLoja := space(TamSX3("D1_LOJA")[1])

   aAdd(aLoad, {cFilAnt,cFilAnt, cProd, StrTran(cProd," ","Z"), date()-30, date(), cCli, StrTran(cCli," ","Z"), cLoja, StrTran(cLoja," ","Z")}) //dados default iniciais
   aAdd(aLoad, 0) //recno
      
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} l720getDSt

Obtem a estrutura de campos do detail 

@param nOpc - Modelo da estrutura retornada, 1: Model, 2: View
@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
static function l720getDSt(nOpc)

Local oStruct

Default nOpc := 1

if nOpc == 1 
    oStruct := FWFormModelStruct():New()
    /*Parâmetros AddField: <cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ],
        [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ]*/ 
    oStruct:AddTable('DETAIL',{'D1_DOC'},'DETAIL')
    oStruct:AddField(STR0014, '' , 'D1_FILORI', 'C', TamSX3("D1_FILORI")[1], 0,, , {})
    oStruct:AddField(STR0015, '' , 'D1_DOC',    'C', TamSX3("D1_DOC")[1], 0,, , {})
    oStruct:AddField(STR0016, '' , 'D1_SERIE',  'C', TamSX3("D1_SERIE")[1], 0,, , {})
    oStruct:AddField(STR0017, '' , 'D1_COD',    'C', TamSX3("D1_COD")[1], 0,, , {})
    oStruct:AddField(STR0018, '' , 'D1_UM',     'C', TamSX3("D1_UM")[1], 0,, , {})
    oStruct:AddField(STR0019, '' , 'D1_QUANT',  'N', TamSX3("D1_QUANT")[1], 0,, , {})
    oStruct:AddField(STR0020, '' , 'D1_TOTAL',  'N', TamSX3("D1_TOTAL")[1], 2,, , {})
    oStruct:AddField(STR0021, '' , 'D1_FORNECE','C', TamSX3("D1_FORNECE")[1], 0,, , {})
    oStruct:AddField(STR0022, '' , 'D1_LOJA',   'C', TamSX3("D1_LOJA")[1], 0,, , {})
    oStruct:AddField(STR0023, '' , 'D1_EMISSAO','D', TamSX3("D1_EMISSAO")[1], 0,, , {})
else

    oStruct := FWFormViewStruct():New()    
    /*Parâmetros AddField: [cIdField],[cOrdem],[cTitulo],[cDescric],[aHelp],[cType],[cPicture],[bPictVar],[cLookUp],[lCanChange],
        [cFolder],[cGroup],[aComboValues],[nMaxLenCombo],[cIniBrow],[lVirtual],[cPictVar],[lInsertLine],[nWidth]*/
    oStruct:AddField( 'D1_FILORI' ,'1', STR0014, STR0014,, 'Get' ,,,,,,,,,,,, )//Filial
    oStruct:AddField( 'D1_FORNECE','2', STR0021, STR0021,, 'Get' ,,,,,,,,,,,, )//Cliente
    oStruct:AddField( 'D1_LOJA'   ,'3', STR0022, STR0022,, 'Get' ,,,,,,,,,,,, )//Loja
    oStruct:AddField( 'D1_COD'    ,'4', STR0017, STR0017,, 'Get' ,,,,,,,,,,,, )//Produto
    oStruct:AddField( 'D1_TOTAL'  ,'5', STR0020, STR0020,, 'Get' ,"@E 999,999,999,999.99",,,,,,,,,,,)//Total
    oStruct:AddField( 'D1_QUANT'  ,'6', STR0019, STR0019,, 'Get' ,"@E 999,999,999,999",,,,,,,,,,, )//Quantidade
    oStruct:AddField( 'D1_EMISSAO','7', STR0023, STR0023,, 'Get' ,,,,,,,,,,,, )//Emissão
    oStruct:AddField( 'D1_DOC'    ,'8', STR0015, STR0015,, 'Get' ,,,,,,,,,,,, )//Documento
    oStruct:AddField( 'D1_SERIE'  ,'9', STR0016, STR0016,, 'Get' ,,,,,,,,,,,, )//Serie
    oStruct:AddField( 'D1_UM'     ,'A', STR0018, STR0018,, 'Get' ,,,,,,,,,,,, )//Un. Medida
    
endif    

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} l720loadD

Carrega as informações do grid de acordo com os parâmetros informados. 

@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
Static Function l720loadD()

Local cAlias := GetNextAlias()
Local oModel := FwModelActive()
Local oDetModel := oModel:GetModel("DETAIL")
Local nItens := 0
Local nTotal := 0

    oDetModel:SetNoUpdate(.F.) 
    oDetModel:SetNoInsert(.F.) 
    oDetModel:SetNoDelete(.F.) 
    oDetModel:SetMaxLine(9999999)
    oDetModel:ClearData()

    BeginSql Alias cAlias	
        SELECT D1_FILIAL,D1_DOC, D1_SERIE ,D1_COD, D1_UM, D1_QUANT,D1_TOTAL, D1_FORNECE, D1_LOJA, D1_EMISSAO 
        FROM %table:SD1% SD1
        WHERE D1_FILORI >= %Exp:oModel:GetValue("MASTER", "FILIAL_DE")%
        AND D1_FILORI <= %Exp:oModel:GetValue("MASTER", "FILIAL_ATE")%
        AND D1_EMISSAO >= %Exp:dtos(oModel:GetValue("MASTER", "DATA_DE"))%
        AND D1_EMISSAO <= %Exp:dtos(oModel:GetValue("MASTER", "DATA_ATE"))%
        AND D1_COD >= %Exp:oModel:GetValue("MASTER", "PROD_DE")%
        AND D1_COD <= %Exp:oModel:GetValue("MASTER", "PROD_ATE")%
        AND D1_FORNECE >= %Exp:oModel:GetValue("MASTER", "CLIENTE_DE")%
        AND D1_FORNECE <= %Exp:oModel:GetValue("MASTER", "CLIENTE_ATE")%
        AND D1_LOJA >= %Exp:oModel:GetValue("MASTER", "LOJA_DE")%
        AND D1_LOJA <= %Exp:oModel:GetValue("MASTER", "LOJA_ATE")%
        AND D1_ORIGLAN = 'LO'
        AND SD1.%NotDel%
    EndSql

    If (cAlias)->(!EOF()) 

        While (cAlias)->(!EOF())            
            oDetModel:SetValue("D1_FILORI",  (cAlias)->D1_FILIAL)
            oDetModel:SetValue("D1_DOC",     (cAlias)->D1_DOC)
            oDetModel:SetValue("D1_SERIE",   (cAlias)->D1_SERIE)
            oDetModel:SetValue("D1_COD",     (cAlias)->D1_COD)
            oDetModel:SetValue("D1_UM",      (cAlias)->D1_UM)
            oDetModel:SetValue("D1_QUANT",   (cAlias)->D1_QUANT)
            oDetModel:SetValue("D1_TOTAL",   (cAlias)->D1_TOTAL)
            oDetModel:SetValue("D1_FORNECE", (cAlias)->D1_FORNECE)
            oDetModel:SetValue("D1_LOJA",    (cAlias)->D1_LOJA)
            oDetModel:SetValue("D1_EMISSAO", stod((cAlias)->D1_EMISSAO) )    
            
            oDetModel:addLine()
            
            nItens += (cAlias)->D1_QUANT
            nTotal += (cAlias)->D1_TOTAL
        
            (cAlias)->(DbSkip())
        EndDo

        oDetModel:SetValue("D1_COD","_ TOTAL:")
        oDetModel:SetValue("D1_QUANT", nItens)
        oDetModel:SetValue("D1_TOTAL", nTotal)
        oDetModel:SetValue("D1_FILORI",  "_")
        oDetModel:SetValue("D1_DOC",     "_" )
        oDetModel:SetValue("D1_SERIE",   "_" )
        oDetModel:SetValue("D1_UM",      "_" )
        oDetModel:SetValue("D1_FORNECE", "_" )
        oDetModel:SetValue("D1_LOJA",    "_" )
            
    Else
        oDetModel:SetValue("D1_FILORI", "")
        oDetModel:SetValue("D1_DOC", "")
        oDetModel:SetValue("D1_SERIE", "")
        oDetModel:SetValue("D1_COD", "")
        oDetModel:SetValue("D1_UM", "")
        oDetModel:SetValue("D1_QUANT", 0)
        oDetModel:SetValue("D1_TOTAL", 0)
        oDetModel:SetValue("D1_FORNECE", "")
        oDetModel:SetValue("D1_LOJA", "")
        oDetModel:SetValue("D1_EMISSAO", ctod(""))

        MSGINFO(STR0024, STR0025 )//"STR0024 - Nenhhuma devolução foi encontrada dentro dos parâmetros fornecidos! STR0025 - Busca Concluida"

    EndIf

    oDetModel:SetNoUpdate(.T.) 
    oDetModel:SetNoInsert(.T.) 
    oDetModel:SetNoDelete(.T.) 
    
    oDetModel:GoLine(1)

    (cAlias)->(DbCloseArea())
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} l720InitD

Carrega valores iniciais do grid

@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
static function l720InitD()

Local aLoad := {}
aAdd(aLoad,{0 /*RECNO*/,{"","","","","",0,0,"","",ctod("")} })

return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} l720Commit

Bloco executado ao Clicar no botão "exportar excel", gera o excel com o relatório

@param oModel - Estrutura do modelo trabalhado
@author Julio Teixeira
@since 31/12/2019
/*/
//-------------------------------------------------------------------
Static Function l720Commit(oModel)

Local lRet := .T.
Local oExcel := FWMsExcel():New()
Local oModelMaster := oModel:GetModel("MASTER")
Local oModelDet := oModel:GetModel("DETAIL")
Local nLines := oModelDet:Length()
Local cArquivo := 'LOJC720_'+dtos(date())+'_'+StrTran( time(),":","-")+'.xml'
Local cDir := ""
Local nX := 1

If nLines > 1 

    oExcel:AddworkSheet(STR0026)//"Devoluções"
    oExcel:AddTable (STR0026,STR0027)//"Relatório de Devoluções"
    oExcel:AddColumn(STR0026,STR0027,STR0014,2,1)//Filial
    oExcel:AddColumn(STR0026,STR0027,STR0015,2,2)//Doc
    oExcel:AddColumn(STR0026,STR0027,STR0016,2,3)//Serie
    oExcel:AddColumn(STR0026,STR0027,STR0017,2,1)//Produto
    oExcel:AddColumn(STR0026,STR0027,STR0018,2,1)//Un. Medida
    oExcel:AddColumn(STR0026,STR0027,STR0019,2,1)//Quantidade
    oExcel:AddColumn(STR0026,STR0027,STR0020,2,1)//Total
    oExcel:AddColumn(STR0026,STR0027,STR0021,2,1)//Cliente
    oExcel:AddColumn(STR0026,STR0027,STR0022,2,1)//Loja
    oExcel:AddColumn(STR0026,STR0027,STR0023,2,1)//Dt.Devolucao

    oModelDet:GoLine(1)

    for nX := 1 to nLines
        
        oModelDet:GoLine(nX)

        oExcel:AddRow(STR0026,STR0027,{;
        oModelDet:GetValue("D1_FILORI",nX),;
        oModelDet:GetValue("D1_DOC",nX),;
        oModelDet:GetValue("D1_SERIE",nX),;
        oModelDet:GetValue("D1_COD",nX),;
        oModelDet:GetValue("D1_UM",nX),;
        oModelDet:GetValue("D1_QUANT",nX),;
        oModelDet:GetValue("D1_TOTAL",nX),;
        oModelDet:GetValue("D1_FORNECE",nX),;
        oModelDet:GetValue("D1_LOJA",nX),;
        oModelDet:GetValue("D1_EMISSAO",nX)})
        
    next nX

    oExcel:AddworkSheet(STR0028)//"Parâmetros"
    oExcel:AddTable (STR0028,STR0029)//"Parâmetros utilizados" 
    oExcel:AddColumn(STR0028,STR0029,STR0032,2,1)//Parametro
    oExcel:AddColumn(STR0028,STR0029,STR0033,2,1)//Conteudo

    oExcel:AddRow(STR0028,STR0029,{STR0003,oModelMaster:getValue("FILIAL_DE")})
    oExcel:AddRow(STR0028,STR0029,{STR0004,oModelMaster:getValue("FILIAL_ATE")})

    oExcel:AddRow(STR0028,STR0029,{STR0005,oModelMaster:getValue("PROD_DE")})
    oExcel:AddRow(STR0028,STR0029,{STR0006,oModelMaster:getValue("PROD_ATE")})

    oExcel:AddRow(STR0028,STR0029,{STR0007,oModelMaster:getValue("DATA_DE")})
    oExcel:AddRow(STR0028,STR0029,{STR0008,oModelMaster:getValue("DATA_ATE")})

    oExcel:AddRow(STR0028,STR0029,{STR0009,oModelMaster:getValue("CLIENTE_DE")})
    oExcel:AddRow(STR0028,STR0029,{STR0010,oModelMaster:getValue("CLIENTE_ATE")})

    oExcel:AddRow(STR0028,STR0029,{STR0011,oModelMaster:getValue("LOJA_DE")})
    oExcel:AddRow(STR0028,STR0029,{STR0012,oModelMaster:getValue("LOJA_ATE")})

    cDir := cGetFile( '*' , STR0036+'('+cArquivo+')', 1, 'C:\', .F.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ) ,.T., .T. )//Diretorio Destino 

    if(empty(cDir), cDir := GETTEMPPATH() ,)

    oExcel:Activate()
    oExcel:GetXMLFile(cDir+cArquivo)
    
    If GetRemoteType() == 1 //-1= Job, 1 = Windows, 2 = Linux
        winexec("explorer.exe "+cDir+cArquivo)
    Endif

Else
    oModel:SetErrorMessage (,,,,STR0037,STR0038,STR0039)//"Nenhum registro!","Nenhum registro para ser exportado!","Para exportar o arquivo é necessário ter ao menos um registro no grid."
    lRet = .F.       
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} l720Close

Encerra o programa

@author Julio Teixeira
@since 15/01/2020
/*/
//-------------------------------------------------------------------
Static Function l720Close()

Local oModel := FwModelActive()

oModel:lModify := .F.

Return .T.