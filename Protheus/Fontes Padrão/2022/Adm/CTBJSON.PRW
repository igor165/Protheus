#Include "CTBJSON.ch"
#INCLUDE "FileIO.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'FWEditPanel.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBJSON
Rotina para carregar os demonstrativos em formato JSON e gerar o
arquivo final, unificado, para envio ao banco central.

Legislação referente à carta circular 4.051 de 14/05/2020 (Banco Central)


@author TOTVS
@since 10/02/2021
/*/
//-------------------------------------------------------------------
Function CTBJSON()
Local aButtons      := {}
Local aSM0          := FWArrFilAtu(cEmpAnt,cFilAnt)

Private cCNPJ       := aSM0[SM0_CGC]
Private aMarkBrow   := {}
Private cDocJson    := ""
Private cDataRef    := ""
Private cMultipl    := ""
Private cDatas      := ""

aButtons := {{.F.,Nil},; //1 - Copiar
             {.F.,Nil},; //2 - Recortar
             {.F.,Nil},; //3 - Colar
             {.F.,Nil},; //4 - Calculadora
             {.F.,Nil},; //5 - Spool
             {.F.,Nil},; //6 - Imprimir
             {.F.,Nil},; //7 - Confirmar
             {.T.,STR0001},; //8 - Cancelar //"Fechar"
             {.F.,Nil},; //9 - WalkTrhough
             {.F.,Nil},; //10 - Ambiente
             {.F.,Nil},; //11 - Mashup
             {.F.,Nil},; //12 - Help
             {.F.,Nil},; //13 - Formulário HTML
             {.F.,Nil}}  //14 - ECM

FWExecView(STR0002,"CTBJSON",3,,{|| .T.},,,aButtons) //"Demonstrativos JSON"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model da rotina

@author TOTVS
@since 10/02/2021
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oFieldStru := GetFieldStru()
Local oGridStru  := GetGridlStru()

oModel := MPFormModel():New('CTBJSON',,,/*bCommit*/)
oModel:SetDescription(STR0003) //'Gerar Arquivo'

oModel:AddFields("MASTER",,oFieldStru,/*bPreVld*/,/*bPosVld*/,{||}/*bLoad*/)
oModel:getModel("MASTER"):SetDescription("MASTER")

oModel:AddGrid("DETAIL","MASTER",oGridStru,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
         
oModel:getModel("DETAIL"):SetDescription("DETAIL")

oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View da Rotina

@author TOTVS
@since 10/02/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel    := ModelDef() 
Local oViewStru := GetViewStru()
	
    oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddGrid('FORM1',oViewStru,'DETAIL' ) 
    oView:AddOtherObject("PANEL_SEL",{|oPanel,oOtherObject| CTBCriaBot(oPanel,oOtherObject)})
	
    oView:EnableTitleView('FORM1','') 
    
    oView:CreateHorizontalBox('BOXFORM1', 100)
	oView:SetOwnerView('FORM1','BOXFORM1')	

    oView:SetNoDeleteLine('FORM1')
    
    oView:addUserButton(STR0004, '',{|oView| CTBSelArq(oView)}, , , , .T.) //"Carregar Arquivos JSON"
    oView:addUserButton(STR0003, '', {|oView| CTBGrvArq()}, , , , .T.) //'Gerar Arquivo'
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBCriaBot
Cria o botão Inverte na grid

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CTBCriaBot(oPanel,oOtherObject)
    TButton():New( 0, 0, STR0005,oPanel,{|| CTBInverte(oOtherObject)}, 19,14,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Inverte"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBInverte
Função para fazer a inversão dos itens selecionados

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CTBInverte(oOtherObject)
Local oGrid := oOtherObject:GetModel():GetModel("DETAIL")
Local nX
Local lValue

For nX:=1 to oGrid:Length()
    oGrid:GoLine(nX)
    If !oGrid:isDeleted()
        lValue := oGrid:GetValue("SELECT")
        oGrid:LoadValue("SELECT", !lValue)
    EndIf
Next nX

oGrid:GoLine(1)
oOtherObject:oControl:Refresh('DETAIL')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFieldStru
Retorna a estrutura do componente Fields

@author TOTVS
@since 10/02/2021
/*/
//-------------------------------------------------------------------
Static Function GetFieldStru()
Local oStruct := FWFormModelStruct():New()
	
oStruct:AddField('','','FIELD','C',1,0,,,{},.T.,,.F.,.F.,.F.,,)	
	
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} GetGridlStru
Retorna a estrutura do componente Grid

@author TOTVS
@since 10/02/2021
/*/
//-------------------------------------------------------------------
Static Function GetGridlStru()
Local oStruct := FWFormModelStruct():New()

oStruct:AddField('SELECT','','SELECT', 'L',1,0, , , {}, .F.,FWBuildFeature(STRUCT_FEATURE_INIPAD, ".F."))
oStruct:AddField(STR0006,STR0006, 'CNOMDEM', 'C', 50, 0, , , {}, .F., , .F., .F., .F., , ) //'Demonstrativo'
oStruct:AddField(STR0007,STR0007, 'CMESANO', 'C',6, 0, , , {}, .F., , .F., .F., .F., , ) //'Mês/Ano Ref.'
oStruct:AddField(STR0008,STR0008, 'CDOCUMENTO', 'C', 4, 0, , , {}, .F., , .F., .F., .F., , ) //'Documento'
oStruct:AddField(STR0009,STR0009, 'CMULTI', 'C', 15, 0, , , {}, .F., , .F., .F., .F., , ) //'Multiplicador'
oStruct:AddField(STR0010,STR0010,'CLOCAL', 'C', 100, 0, , , {}, .F., , .F., .F., .F., , ) //'Caminho'

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} GetViewStru
Retorna a estrutura do componente View

@author TOTVS
@since 10/02/2021
/*/
//-------------------------------------------------------------------
Static Function GetViewStru()
Local oStruct := FWFormViewStruct():New()

oStruct:AddField( 'SELECT'      ,'1','','',,'Check' ,,,,,,,,,,,, )
oStruct:AddField( 'CNOMDEM'     ,'2',STR0006,STR0006,,'Get' ,,,,,,,,,,,, ) //'Demonstrativo'
oStruct:AddField( 'CMESANO'     ,'3',STR0007,STR0007,,'Get' ,,,,,,,,,,,, ) //'Mês/Ano Ref.'
oStruct:AddField( 'CDOCUMENTO'  ,'4',STR0008,STR0008,,'Get' ,,,,,,,,,,,, ) //'Documento'
oStruct:AddField( 'CMULTI'      ,'5',STR0009,STR0009,,'Get' ,,,,,,,,,,,, ) //'Multiplicador'
oStruct:AddField( 'CLOCAL'      ,'6',STR0010,STR0010,,'Get' ,,,,,,,,,,,, ) //'Caminho'

oStruct:SetProperty('CNOMDEM'   ,MVC_VIEW_CANCHANGE,.F.)
oStruct:SetProperty('CMESANO'   ,MVC_VIEW_CANCHANGE,.F.)
oStruct:SetProperty('CDOCUMENTO',MVC_VIEW_CANCHANGE,.F.)
oStruct:SetProperty('CMULTI'    ,MVC_VIEW_CANCHANGE,.F.)
oStruct:SetProperty('CLOCAL'    ,MVC_VIEW_CANCHANGE,.F.)

oStruct:SetProperty('*',MVC_VIEW_INSERTLINE,.F.)

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBSelArq
Seleciona os arquivos a serem processados pela rotina

@author TOTVS
@since 10/02/2021
/*/
//-------------------------------------------------------------------
Static Function CTBSelArq(oView)
Local cArqJson  := ""
Local aArquivos := {} 
Local lContinua := .T.

// Retirado pois em testes com binários/libs mais antigos a tela fica congelada
//cArqJson := TFileDialog( "Json files (*.json)",'Selecione os arquivos',,,.F.,GETF_MULTISELECT)

cArqJson := cGetFile ("Json files|*.json",STR0011,,,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_MULTISELECT,.T.,.T. ) //"Selecione os arquivos"
cArqJson  := StrTran(Lower(cArqJson)," servidor","") // A função cGetFile está retornando o nome SERVIDOR quando selecionado mais de um arquivo.
aArquivos := StrTokArr(cArqJson,"|")

lContinua := CtbPrepTela(aArquivos,aMarkBrow)

If lContinua
    CtbMontaTela(aMarkBrow)

    oView:Refresh()
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PrepTela
Prepara o array para montagem da grid na tela

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbPrepTela(aArquivos,aMarkBrow)
Local oJson  
Local nI        := 0 
Local nJ        := 0
Local lContinua := .T.
Local cDocAux   := ""
Local cDatAux   := ""
Local cMulAux   := ""

Local aNmJson   := {}

DEFAULT aArquivos := {}
DEFAULT aMarkBrow := {}

aMarkBrow := {}

For nI := 1 to Len(aArquivos)

    lContinua := CtbRetObj(aArquivos[nI],@oJson)
   
    If lContinua
        aNmJson := oJson:GetNames()

        For nJ := 1 to Len(aNmJson)
            If !(Upper(aNmJson[nJ])$'PERGUNTEREL/PARAMETROSJSON')
                cDemonst := aNmJson[nJ]
                Exit
            EndIf
        Next nJ
        
        cDataRef := oJson["ParametrosJson"]["PergunteJson"][2]:XCONTEUDO
        cDocJson := oJson["ParametrosJson"]["PergunteJson"][3]:XCONTEUDO
        cMultipl := CtbRetMul(oJson)
        cCaminho := aArquivos[nI]

        If !Empty(cDocAux) .And. cDocAux <> cDocJson
            If Aviso(STR0014, STR0012+cDocJson+STR0013+CHR(13)+CHR(10)+; //'Documento: "'
                                STR0015+CHR(13)+CHR(10)+; //"Os arquivos devem ter o mesmo tipo de documento"
                                STR0016+CHR(13)+CHR(10)+;                                 //"Se continuar, este arquivo será ignorado."
                                STR0017+aArquivos[nI],{STR0019,STR0018},2) == 1 //"Arquivo: "
                aMarkBrow := {}                
                Exit
            Else                
                Loop
            EndIf
            FreeObj(oJson)
        EndIf

        If !Empty(cDatAux) .And. cDatAux <> cDataRef
            If Aviso(STR0014, STR0021+cDataRef+STR0020+CHR(13)+CHR(10)+; //"Atenção"
                                STR0022+CHR(13)+CHR(10)+; //"Os arquivos devem ter a mesma data de referência"
                                STR0016+CHR(13)+CHR(10)+;                                 //"Se continuar, este arquivo será ignorado."
                                STR0017+aArquivos[nI],{STR0019,STR0018},2) == 1 //"Arquivo: "
                aMarkBrow := {}                
                Exit
            Else                
                Loop
            EndIf
            FreeObj(oJson)
        EndIf

          If !Empty(cMulAux) .And. cMulAux <> cMultipl
            If Aviso(STR0014, STR0023+cMultipl+STR0013+CHR(13)+CHR(10)+; //'" inválido. '
                                STR0024+CHR(13)+CHR(10)+; //"Os arquivos devem ter o mesmo fator multiplicador"
                                STR0016+CHR(13)+CHR(10)+;                                 //"Se continuar, este arquivo será ignorado."
                                STR0017+aArquivos[nI],{STR0019,STR0018},2) == 1 //"Arquivo: "
                aMarkBrow := {}                
                Exit
            Else                
                Loop
            EndIf
            FreeObj(oJson)
        EndIf

        cDocAux := cDocJson
        cDatAux := cDataRef
        cMulAux := cMultipl

        aAdd(aMarkBrow,{cDemonst,cDataRef,cDocJson,cMultipl,cCaminho})
    
    ElseIf Aviso(STR0014,STR0025+CHR(13)+CHR(10)+; //"Atenção"
                    STR0026+CHR(13)+CHR(10)+; //"Deseja continuar ? "
                    STR0017+aArquivos[nI],{STR0027,STR0028},2) <> 2 //"Arquivo: "
        aMarkBrow := {}
        FreeObj(oJson)
        Exit        
    EndIf   

    FreeObj(oJson)
Next nI

aSort(aMarkBrow,,,{|x,y| x[1] < y[1] })

Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbMontaTela
Monta a grid baseado no array recebido

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbMontaTela(aMarkBrow)
Local nI        := 0
Local oModel    := FWModelActive()
Local oModelGrd := oModel:GetModel('DETAIL')

oModelGrd:ClearData(.F.,.T.)

For nI := 1 to Len(aMarkBrow)
    oModelGrd:AddLine()
    oModelGrd:SetValue("SELECT"    ,.F.)
    oModelGrd:SetValue("CNOMDEM"   ,aMarkBrow[nI,1])    
    oModelGrd:SetValue("CMESANO"   ,aMarkBrow[nI,2])
    oModelGrd:SetValue("CDOCUMENTO",aMarkBrow[nI,3])    
    oModelGrd:SetValue("CMULTI"    ,aMarkBrow[nI,4])
    oModelGrd:SetValue("CLOCAL"    ,aMarkBrow[nI,5])
Next nI

oModelGrd:GoLine(1)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbMontaTela
Gera o arquivo Final para entrega ao Banco Central

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CTBGrvArq()
Local nI        := 0
Local oModel 	:= FWModelActive()
Local oModelGrd := oModel:GetModel( 'DETAIL' )
Local cCaminho  := ""
Local cDemonst  := ""
Local lContinua := .T.
Local lSeleciona:= .F.
Local cDirSave  := ""
Local oJson  
Local cStrJson  := ""
Local lFirst    := .T.
Local aDemons   := {}
Local cNomArq   := "INF"+cDocJson+cCNPJ+cDataRef+".JSON"
Local lAutomato := IsBlind()

cDatas := "" //Private

For nI:= 1 to oModelGrd:Length()
	oModelGrd:GoLine(nI)    
    If oModelGrd:GetValue("SELECT")
        lSeleciona := .T.
        
        cCaminho  := AllTrim(oModelGrd:GetValue("CLOCAL"))
        cDemonst  := AllTrim(oModelGrd:GetValue("CNOMDEM"))
        lContinua := CtbRetObj(cCaminho,@oJson)
        
        If lContinua
            If !lFirst
                cStrJson += ','
            EndIf

            aAdd(aDemons, cDemonst)

            cStrJson += '"'+cDemonst+'": '+;            
            oJson:GetJsontext(cDemonst)

            If !lFirst
                cDatas += ','
            EndIf

            cDatas += CtbVldDat(oJson)

            lFirst := .F.
        EndIf
    EndIf	
    FreeObj(oJson)
Next nI

oModelGrd:GoLine(1)  

If lContinua 
    If lSeleciona
        If lAutomato
            cDirSave := '\baseline\'
            cNomArq := StrTran(cNomArq,'.JSON','')+"_001auto.JSON"        
        Else
            cDirSave := cGetFile ("Json files|*.json",STR0011,,,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_RETDIRECTORY,.T.,.T. ) //"Selecione os arquivos"
            If Empty(cDirSave)
                lContinua := .F.
            EndIf
        EndIf
    Else
        Aviso(STR0014,STR0030,{STR0029}) //"Atenção"
        lContinua := .F.
    EndIf
EndIf

If lContinua
    cStrJson := CtbAddDem(cStrJson,aDemons)
    cStrJson := CtbRetJSON(cStrJson)
    
    If MemoWrite(cDirSave+cNomArq,cStrJson)
        Aviso(STR0014,STR0031+CHR(13)+CHR(10)+; //"Atenção"
                        cDirSave+cNomArq,{STR0029}) //"Ok"
    Else
        Aviso(STR0014,STR0032+CHR(13)+CHR(10)+; //"Atenção"
                       cDirSave+cNomArq,{STR0029}) //"Ok"
    EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbRetObj
Lê o arquivo JSON e retorna o objeto 

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbRetObj(cArquivo,oJson)
Local lRet := .T.
Local uRet

DEFAULT cArquivo := ""

cStrJson := MemoRead(cArquivo)
oJson    := JsonObject():new()
uRet     := oJson:FromJson(cStrJson)

If ValType(uRet) <> "U"  
    lRet := .F.    
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CtbVldDat
Valida as datas dos demonstrativos para montagem do arquivo final

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbVldDat(oJson)
Local nI        := 0
Local cRet      := ""
Local lFirst    := .T.
Local aIdDatas  := {}

aIdDatas := oJson["ParametrosJson"]["DatasJson"][1]:GetNames()

For nI := 1 to Len(aIdDatas)
    If !lFirst
        cRet += ','    
    EndIf
    
    cRet += '{"@id": "'+aIdDatas[nI]+'", "@data": "'+ &('oJson["ParametrosJson"]["DatasJson"][1]:'+aIdDatas[nI]) +'"}' 
     
    lFirst := .F.
Next nI

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CtbRetJSON
Retorna o arquivo JSON final para entrega ao Banco Central

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbRetJSON(cStrDemons)
Local cStrJson  := ""
Local cTipRemess:= "I" //modificar

DEFAULT cStrDemons := ""

If Aviso(STR0014,STR0037,{STR0038,STR0039}) == 1 //"Atenção" ### "Qual tipo de arquivo deseja gerar?" ### "S-Substituição" ### "I-Inclusão"  
    cTipRemess := "S"
EndIf

cStrJson  :='{"@cnpj": "'+cCNPJ+'",'+;
            '"@codigoDocumento": "'+cDocJson+'",'+;
            '"@tipoRemessa": "'+cTipRemess+'",'+;
            '"@unidadeMedida": '+CtbCodMul()+","+;
            '"@dataBase": "'+cDataRef+'",'+; 
            '"datasBaseReferencia": ['+;
            cDatas+'],'+;
            cStrDemons+'}'

Return cStrJson
//-------------------------------------------------------------------
/*/{Protheus.doc} CtbAddDem
Adiciona os demonstrativos padrões no arquivo JSON final

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbAddDem(cStrJson,aDemons)
Local nI := 0
Local aDemPad := {  "BalancoPatrimonial",;
                    "DemonstracaoDoResultado",;
                    "DemonstracaoDoResultadoAbrangente",;
                    "DemonstracaoDosFluxosDeCaixa",;
                    "DemonstracaoDasMutacoesDoPatrimonioLiquido",;
                    "DemonstracaoDosRecursosDeConsorcioConsolidada",;
                    "DemonstracaoDeVariacoesNasDisponibilidadesDeGruposConsolidada"}

For nI := 1 to Len(aDemPad)
    If aScan(aDemons,{|x| AllTrim(Upper(x))==AllTrim(Upper(aDemPad[nI]))}) == 0
        cStrJson += ',"'+aDemPad[nI]+'": {}'
    EndIf
Next nI

Return cStrJson
//-------------------------------------------------------------------
/*/{Protheus.doc} CtbRetMul
Retorna o multiplicador utilizado no relatório

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbRetMul(oJson)
Local nMultipl := 1
Local cRet     := STR0033 //"Não se Aplica"
Local cNmRelat := ""

cNmRelat := oJson["PergunteRel"]:GetNames()[1]

Do Case
    Case cNmRelat== "CTBR500"
        nMultipl := oJson["PergunteRel"]["CTBR500"][15]:XCONTEUDO
    Case cNmRelat== "CTBR510"
        nMultipl := oJson["PergunteRel"]["CTBR510"][21]:XCONTEUDO
    Case cNmRelat== "CTBR530"
        nMultipl := oJson["PergunteRel"]["CTBR530"][16]:XCONTEUDO
    Case cNmRelat== "CTBR560"
        nMultipl := oJson["PergunteRel"]["CTBR560"][24]:XCONTEUDO
End Case

If nMultipl == 2
	cRet := STR0034 //"Cem"
ElseIf nMultipl == 3
	cRet := STR0035 //"Mil"
ElseIf nMultipl == 4
	cRet := STR0036 //"Milhão"
EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CtbCodMul
Retorna o código do multiplicador utilizado no relatório

@author TOTVS
@since 10/02/2021
/*/
//------------------------------------------------------------------- 
Static Function CtbCodMul()
Local cRet := "0" //Não se Aplica

Do Case
    Case cMultipl == STR0034 //"Cem"
        cRet := "1"   
    Case cMultipl == STR0035 //"Mil"
        cRet := "2"
    Case cMultipl == STR0036 //"Milhão"
        cRet := "3"
End Case

Return cRet
