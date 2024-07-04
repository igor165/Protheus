#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "Eicqc400.ch" 

/*
Funcao      : EICQC400 -  REQ03   - 13/05/2014 
Parametros  : 
Retorno     : 
Objetivos   : Efetuar a rotina de cotação de precos     
Autor       : Sandro de Souza Silva
Data/Hora   : 13/05/2014
Revisao     : 
Obs.        : 
*/    
*-----------------*
Function EICQC400(cItem,cFil,cCC,cSi)
*-----------------*
Local oBrowse                  
DEFAULT cFil       := ""    
DEFAULT cItem      := ""               
DEFAULT cCC        := ""               
DEFAULT cSI        := ""               
PRIVATE aAtuStatus := {}

//Criação da Mbrowse
oBrowse := FWMBrowse():New() //Instanciando a Classe    
oBrowse:SetAlias("SWR") //Informando o Alias 
oBrowse:SetMenuDef("EICQC400") //Nome do fonte do MenuDef
oBrowse:SetExecuteDef(2) //No duplo clique executa a visualização
oBrowse:SetDescription(STR0006) //"Cotação de Importação"

//IGOR CHIBA 03/06/14 FILTRAR A CONCORRENCIA TRAZENDO APENAS AS QUE TEM O MESMO CODIGO DO ITEM DO PARAMETRO DA SI
IF ISINCALLSTACK('EICSI410') .AND. !EMPTY(cItem)
   Private aConcorr := GerQry(cItem,cFilial,cCC,cSi)
   Private aFilConc := {cItem,cFil,cCC,cSi}
   oBrowse:SetFilterDefault("EasyAScan(aConcorr,SWR->WR_NR_CONC)>0")
ENDIF 

oBrowse:Activate()
Return Nil    

*------------------------*                                    
Static Function MenuDef()
*------------------------*
Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0001          ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0002          ACTION "VIEWDEF.EICQC400" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003          ACTION "VIEWDEF.EICQC400" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004          ACTION "VIEWDEF.EICQC400" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005          ACTION "VIEWDEF.EICQC400" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina  

*-------------------------*
Static Function ModelDef()
*-------------------------*
// Cria a estrutura a ser usada no Modelo de Dados 
Local oStruSWR := FWFormStruct( 1, "SWR")
Local oStruSWS := FWFormStruct( 1, "SWS")
Local oStruSWT := FWFormStruct( 1, "SWT")
Local bPosValidacao := {|oModel| EICQCPRE(oModel) .AND. EICQCPOS(oModel) .AND. EICQC410(.T.,oModel,)}//IGOR CHIBA 30/05/14 ENVIO
//Local bPreValidacao := {|oModel| EICQCPRE(oModel,)}//IGOR CHIBA 30/05/14 PRE VALIDACAO
//Local bCommit       := {|oModel| EICQCCOM(oModel,)}//IGOR CHIBA 30/05/14 COMMIT 
Local bCommit := {|oMdl| QC400Commit(oMdl)}
Local nI
Local aTrigue  :={}

If ( (nPos := Ascan( oStruSWR:aFields,{|x| alltrim(x[3]) == "WR_IMPNOME"})) > 0)   //IGOR CHIBA 30/05/14
   oStruSWR:aFields[npos][11] := {|| Posicione("SYT",1,xFilial("SYT")+SWR->WR_IMPOR,"YT_NOME") }
EndIf          

If ( (nPos := Ascan( oStruSWS:aFields,{|x| alltrim(x[3]) == "WS_NECES"})) > 0)  //IGOR CHIBA 30/05/14 PREENCHER CAMPO VIRTUAL
   oStruSWS:aFields[npos][11] := {|| BUSCANEC('SWS') }
EndIf          

/*If ( (nPos := Ascan( oStruSWS:aFields,{|x| alltrim(x[3]) == "WS_DESCR"})) > 0)
   oStruSWS:aFields[npos][11] := {|| Atu('WS_DESCR')}
EndIf          */

If ( (nPos := Ascan( oStruSWS:aFields,{|x| alltrim(x[3]) == "WS_PESO"})) > 0)
   oStruSWS:aFields[npos][11] := {|| Posicione("SB1",1,xFilial("SB1")+SWS->WS_COD_I,"B1_PESO") }
EndIf

/*If ( (nPos := Ascan( oStruSWT:aFields,{|x| alltrim(x[3]) == "WT_FORNOME"})) > 0)
   oStruSWT:aFields[npos][11] := {|| Atu('WT_FORNOME') }
EndIf*/
                                              
If ( (nPos := Ascan( oStruSWT:aFields,{|x| alltrim(x[3]) == "WT_FABRNOM"})) > 0)
   oStruSWT:aFields[npos][11] := {|| Posicione("SA2",1,xFilial("SA2")+SWT->WT_FABR+SWT->WT_FABLOJ,"A2_NREDUZ") }
EndIf

oModel := MPFormModel():New( "EICQC400",/* bPreValidacao */, bPosValidacao,bCommit, /*bCancel*/)

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SWRMASTER', /*cOwner*/, oStruSWR)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'SWSDETAIL', 'SWRMASTER', oStruSWS, {|oModelGrid,nLine,cAction,cField| SWSLINE(cAction,nLine)}/* bLinePre */, /*bLinePost*/, /*bPreVal*/ , /*bPosVal*/,/* BLoad*/ )
//oModel:AddGrid( 'SWTDETAIL', 'SWRMASTER', oStruSWT, {|oModelGrid,nLine,cAction,cField| SWTLINE(cAction,nLine,cField)}/* bLinePre */, /* bLinePost */, /* bPreVal */ , /* bPosVal */, /* BLoad */ ) ]
oModel:AddGrid( 'SWTDETAIL', 'SWSDETAIL', oStruSWT, {|oModelGrid,nLine,cAction,cField| SWTLINE(cAction,nLine,cField)}/* bLinePre */, /* bLinePost */, /* bPreVal */ , /* bPosVal */, /* BLoad */ ) 
                                                  
//Modelo de relação entre detalhe(SWR) e detalhe(SWT)
oModel:SetRelation('SWSDETAIL',{{"WS_FILIAL",'xFilial("SWS")'},{"WS_NR_CONC","WR_NR_CONC"}}, SWS->(IndexKey(1)) )
//oModel:SetRelation('SWTDETAIL',{{"WT_FILIAL",'xFilial("SWT")'},{"WT_NR_CONC","WR_NR_CONC"}}, SWT->(IndexKey(1)) )//,{"WT__CC","WS__CC"},{"WT_SI_NUM","WS_SI_NUM"},{"WT_COD_I","WS_COD_I"}}, SWT->(IndexKey(3)) )
oModel:SetRelation('SWTDETAIL',{{"WT_FILIAL",'xFilial("SWT")'},{"WT_NR_CONC","WS_NR_CONC"},{"WT__CC","WS__CC"},{"WT_SI_NUM","WS_SI_NUM"},{"WT_COD_I","WS_COD_I"}}, SWT->(IndexKey(3)) )//WT_FILIAL+WT_NR_CONC+WT__CC+WT_SI_NUM+WT_COD_I+WT_REG+WT_FORN+WT_FORLOJ+WT_FABR+WT_FABLOJ

oModel:SetPrimaryKey( { "WR_FILIAL", "WR_NR_CONC"}) 
oModel:GetModel("SWSDETAIL"):SetUniqueLine({"WS_SI_NUM","WS_COD_I"} )
oModel:GetModel("SWTDETAIL"):SetUniqueLine({"WT__CC","WT_SI_NUM","WT_COD_I","WT_FORN","WT_FORLOJ","WT_FABR","WT_FABLOJ"} )

//Não permitir inclusao de linhas na Grid
oModel:GetModel('SWSDETAIL'):SetNoInsertLine(.T.)    
//nao permite alteracao de linhas na grid
oModel:GetModel('SWSDETAIL'):SetNoUpdateLine( .T. ) 

oModel:GetModel('SWTDETAIL'):SetOptional(.T.)
oModel:GetModel('SWSDETAIL'):SetOptional(.T.)

//Desabilitar os valid's e when's dos campos do dicionario   SWS item                       
bBlock := FwBuildFeature(STRUCT_FEATURE_VALID,"") 
oStruSWS:SetProperty("*",MODEL_FIELD_VALID   ,bBlock)
bBlock := FwBuildFeature(STRUCT_FEATURE_WHEN,"") 
oStruSWS:SetProperty("*",MODEL_FIELD_WHEN    ,bBlock)

//igor chiba retirar  when's dos campos do dicionario e obrigatoriedade 
bBlock := FwBuildFeature(STRUCT_FEATURE_WHEN,"") 
oStruSWT:SetProperty("*",MODEL_FIELD_WHEN    ,bBlock)                                                   

bBlock := FwBuildFeature(STRUCT_FEATURE_VALID,"") 
oStruSWT:SetProperty("*",MODEL_FIELD_VALID   ,bBlock)

//igor chiba Não permitir inclusao de linhas na Grid de cotações e alteracao até que fornecedor seja inclluido
oModel:GetModel('SWTDETAIL'):SetNoInsertLine(.T.)    
                                    
//igor chiba incluindo gatilhos nos campos                     
AADD(aTrigue,{'WT_QTDE'    ,'WT_TOTMVC'})
AADD(aTrigue,{'WT_VL_UNIT' ,'WT_TOTMVC'})

AADD(aTrigue,{'WT_ORIGEM'  ,'WT_MOE_FRE'}) 

AADD(aTrigue,{'WT_QTDE'        ,'WT_FRE_KG'})
AADD(aTrigue,{'WT_INCOTER'     ,'WT_FRE_KG'})
AADD(aTrigue,{'WT_UM'          ,'WT_FRE_KG'} )   

AADD(aTrigue,{'WT_TOTMVC'      ,'WT_SEGURO'} )
AADD(aTrigue,{'WT_FRE_KG'      ,'WT_SEGURO'} )
AADD(aTrigue,{'WT_DESPIN'      ,'WT_SEGURO'} )

AADD(aTrigue,{'WT_TOTMVC'  ,'WT_CIFRS'}) 
AADD(aTrigue,{'WT_MOEDA'   ,'WT_CIFRS'}) 
AADD(aTrigue,{'WT_DESPIN'  ,'WT_CIFRS'}) 
AADD(aTrigue,{'WT_FRE_KG'  ,'WT_CIFRS'}) 
AADD(aTrigue,{'WT_SEGURO'  ,'WT_CIFRS'}) 

AADD(aTrigue,{'WT_QTDE'    ,'WT_TOTRS'})
AADD(aTrigue,{'WT_TOTMVC'  ,'WT_TOTRS'})  
AADD(aTrigue,{'WT_CIFRS'   ,'WT_TOTRS'})  
AADD(aTrigue,{'WT_DESPRS'  ,'WT_TOTRS'})

AADD(aTrigue,{'WT_TOTRS'   ,'WT_TOTURS'})

AADD(aTrigue,{'WT_QTDE'     ,'WT_STATUS'})
AADD(aTrigue,{'WT_VL_UNIT' , 'WT_STATUS'})
AADD(aTrigue,{'WT_MOEDA'   , 'WT_STATUS'})
AADD(aTrigue,{'WT_COD_PAG' , 'WT_STATUS'})
AADD(aTrigue,{'WT_DT_FORN' , 'WT_STATUS'})
AADD(aTrigue,{'WT_INCOTER' , 'WT_STATUS'})

oStruSWT := AddGatilhos(oStruSWT,aTrigue,"EICQ400CAL")
                                                                           
//igor chiba retirando valid do dicionario e configurando manualmente
For nI:=1 to len(oStruSWT :AFIELDS)
   aGrid:=oModel:GetModel('SWTDETAIL'):AHEADER
   cCpo:= oStruSWT :AFIELDS[nI][3]
   IF ASCAN(aGrid,{|x| x[2]== cCpo}) <> 0 .AND. cCpo <> 'WT_STATUS'//se o campo da estrutura estiver no grid fazer o valid
      bBlock := FwBuildFeature(STRUCT_FEATURE_VALID,"QC400VLCPO('"+cCpo+"')") 
      oStruSWT:SetProperty(cCpo,MODEL_FIELD_VALID ,bBlock)    
   ENDIF
Next

//igor chiba retirando valid do dicionario e configurando manualmente
For nI:=1 to len(oStruSWR :AFIELDS)
   //aGrid:=oModel:GetModel('MASTER'):AHEADER
   cCpo:= oStruSWR :AFIELDS[nI][3]
   IF cCpo $ 'WR_VIA WR_DESTINO WR_PER_SEG WR_DT_CONC'
      bBlock := FwBuildFeature(STRUCT_FEATURE_VALID,"QC400VLCPO('"+cCpo+"')") 
      oStruSWR:SetProperty(cCpo,MODEL_FIELD_VALID ,bBlock)    
   ENDIF
Next

oStruSWT:SetProperty("WT_INCOTER",MODEL_FIELD_OBRIGAT,.F.)
oStruSWT:SetProperty("WT_VL_UNIT",MODEL_FIELD_OBRIGAT,.F.)

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
Local oStruSWR := FWFormStruct( 2, "SWR",)
Local oStruSWS := FWFormStruct( 2, "SWS", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruSWT := FWFormStruct( 2, "SWT", /*bAvalCampo*/, /*lViewUsado*/ )  

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oView
Local oModel   := FWLoadModel( "EICQC400" )                                          
          
// Cria o objeto de View
oView := FWFormView():New()    
oView:bCanActivate := {|oView| AtuView(oView)}

//Remover os campos da tela
oStruSWS:RemoveField('WS_DTNECES')
oStruSWT:RemoveField('WT_FOB_UNI')
oStruSWT:RemoveField('WT_FOB_TOT')
oStruSWT:RemoveField('WT_ULT_FOB')
oStruSWT:RemoveField('WT_ULT_ENT')                                                      
oStruSWT:RemoveField('WT_COD_I')
oStruSWT:RemoveField('WT_ID')
oStruSWT:RemoveField('WT_SI_NUM')
oStruSWT:RemoveField('WT_REG')
oStruSWT:RemoveField('WT__CC')        
oStruSWT:RemoveField('WT_NR_CONC')        
oStruSWS:RemoveField('WS_NR_CONC')        

oView:SetModel( oModel )
oView:AddField( 'VIEW_SWR', oStruSWR, 'SWRMASTER' )
oView:AddGrid( 'VIEW_SWS', oStruSWS, 'SWSDETAIL' )
oView:AddGrid( 'VIEW_SWT', oStruSWT, 'SWTDETAIL' )

oView:SETVIEWPROPERTY('VIEW_SWS', "ENABLENEWGRID")
oView:SETVIEWPROPERTY('VIEW_SWT', "ENABLENEWGRID")

/* AAF 29/09/2014 - o Framework MVC ja relaciona os browses se definido no modeldef.
oView:bAfterViewActivate := {|oView| Eval(oView:GETVIEWOBJ('VIEW_SWS')[3]:oBrowse:bChange := {|| FilDataView('VIEW_SWT',{|a,b,c| AtuWTFilter(a,b,c)})}),;
                                          oView:GETVIEWOBJ('VIEW_SWT')[3]:oBrowse:bChange := {|| AtuModelSWT() },;
                                          oView:GETVIEWOBJ('VIEW_SWT')[3]:oBrowse:oBrowse:bGotFocus := {|| AtuModelSWT() },;
                                          oPrvData := oView:GETVIEWOBJ('VIEW_SWT')[3]:oBrowse:oData,;
                                          if(Type("oPrvData:aArray") == "U",oView:GETVIEWOBJ("VIEW_SWT")[3]:oBrowse:bOnMove :={|| .T.},) }
*/
                                
//Bloquear a insercão de linhas na View
//oView:SetNoInsertLine('VIEW_SWS') 

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'ACIMA'  , 35 /*,,,"IDFOLDER","IDSHEET01"*/)
oView:CreateHorizontalBox( 'ABAIXO' , 65 /*,,,"IDFOLDER","IDSHEET01"*/)    

oView:CreateVerticalBox( 'ESQUERDA' , 50 ,'ABAIXO',,/*"IDFOLDER","IDSHEET01"*/)    
oView:CreateVerticalBox( 'DIREITA'  , 50 ,'ABAIXO',,/*"IDFOLDER","IDSHEET01"*/)    

// Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_SWR', 'ACIMA'  )
oView:SetOwnerView( 'VIEW_SWS', 'ESQUERDA')
oView:SetOwnerView( 'VIEW_SWT', 'DIREITA')

// Liga a identificação do componente
oView:EnableTitleView( 'VIEW_SWS',STR0007, RGB(240, 248, 255 )) //"Itens"
oView:EnableTitleView( 'VIEW_SWT',STR0008, RGB(240, 248, 255 ) )//"Fornecedores"

//Habilita ButtonsBar
oView:EnableControlBar(.F.)

Return oView

*-------------------------------------*
Function Itens_Conc(oModel)
*-------------------------------------*                  
Local oBrowse
Local oColumn
Local oDlg 
Local cCadastro		:= STR0009 //"Selecão de itens para concorrência"
Local bValid		:= {|| If(Len(aItens) > 0,MsgYesNo(STR0010,STR0011), (MsgInfo(STR0012, STR0011), .F.))} //"Deseja Incluir"###"Atenção"###"Selecione ao menos um item para inclusão"###"Atenção"
Local bAcao         := {|| ItensSel(aItens),oDlg:End()}
Local bOk 			:= {|| If(Eval(bValid), Eval(bAcao), Nil) }
Local bCancel		:= {|| If(Len(aItens) > 0,If(MsgYesNo(STR0013, STR0011),oDlg:End(),),oDlg:End() )} //"Há item selecionados. Confirma o cancelamento?"
Local bMarca		:= {|| If((nPos := aScan(aItens, TEMP->(RECNO()) ) ) == 0, aAdd(aItens, TEMP->(RECNO()) ), (aDel(aItens, nPos), aSize(aItens, Len(aItens)-1))) }
Local bMarcaTodos	:= {|oBrowse| If(Len(aItens) > 0, aItens := {}, aItens := GetAllItens()), oBrowse:Refresh() }   
Local aInd          := {"W1_SI_NUM+W1_COD_I"}             
Local nLinha
Local cQuery        := ""
Local nInc                                                                                                         
LOCAL oView    := FWViewActive()
                                                                               
Private oModelSWS   := oModel:GetModel("SWSDETAIL")
Private aCampos     := LoadCpo('SW1',{"W1_CC","W1_SI_NUM","W1_COD_I","B1_DESC","B1_UM","W1_QTDE","ELD_DTPREV","W1_DTENTR_"},"W1_CC,W1_SI_NUM,W1_COD_I,' ' B1_DESC ,' ' B1_UM,W1_QTDE,W1_DTENTR_,W1_REG,'  ' B1_PESO")[1]
Private cCampos     := LoadCpo('SW1',{"W1_CC","W1_SI_NUM","W1_COD_I","B1_DESC","B1_UM","W1_QTDE","ELD_DTPREV","W1_DTENTR_"},"W1_CC,W1_SI_NUM,W1_COD_I,' ' B1_DESC ,' ' B1_UM,W1_QTDE,W1_DTENTR_,W1_REG,'  ' B1_PESO")[2] 
Private aItens		:= {}              


IF !oModelSWS:VldLineData() .AND. !EMPTY(oModelSWS:GETVALUE('WS_SI_NUM'))//SE NAO FOR UMA LINHA EM BRANCO VERIFICAR SE ESTA VALIDA
   EasyHelp(STR0014,STR0011) //"Linha do item não está válida."###"Atenção"
   RETURN .F.
ENDIF 

If Select("TEMP") > 0 
   TEMP->(DbCloseArea())
EndIf
            
//nLinha      := GoLineModelSWS(.F.)//oView:GetViewObj("VIEW_SWS")[3]:oBrowse:nAt

cQuery += "Select "+cCampos + " , (SELECT MIN(ELD_DTPREV) FROM "+RetSqlName("ELD")+" ELD WHERE ELD.D_E_L_E_T_ = '' AND ELD.ELD_FILIAL = '"+xFilial("SW1")+"' AND ELD.ELD_CC = SW1.W1_CC AND ELD.ELD_SI_NUM = SW1.W1_SI_NUM ) ELD_DTPREV"
cQuery += " From "+RetSqlName("SW1")+" SW1 "   
cQuery += " "
cQuery += "Where SW1.D_E_L_E_T_ = '' AND SW1.W1_FILIAL = '"+xFilial("SW1")+"' AND W1_SEQ = 0 AND W1_SALDO_Q > 0 AND W1_FORN = '' AND W1_NR_CONC = ''  AND W1_STATUS <> 'G' AND W1_C3_NUM = ''"    
                                          
aSemSX3:={}                               
AADD(aSemSX3,{"B1_DESC"   ,"C",100,0})
AADD(aSemSX3,{"B1_UM"     ,"C",002,0})
AADD(aSemSX3,{"ELD_DTPREV","D",008,0}) 
AADD(aSemSX3,{"B1_PESO   ","N",011,4})      

EasyWkQuery(cQuery,"TEMP",aInd,,{|cWork| !(cWork)->(oModelSWS:SeekLine({{"WS_SI_NUM" ,W1_SI_NUM} ,{"WS_COD_I"  ,W1_COD_I  }}))})

TEMP->(DbGotop())
Do While TEMP->(!Eof())                         
   TEMP->B1_DESC := Posicione('SB1',1,xFilial('SB1')+TEMP->W1_COD_I,'B1_DESC')
   TEMP->B1_UM   := Posicione('SB1',1,xFilial('SB1')+TEMP->W1_COD_I,'B1_UM'  )   
   TEMP->B1_PESO := Posicione('SB1',1,xFilial('SB1')+TEMP->W1_COD_I,'B1_PESO') 
   TEMP->(DbSkip())
EndDo
TEMP->(DbGotop())

DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL
	
	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TEMP" OF oDlg
	
		ADD MARKCOLUMN oColumn DATA { || If(aScan(aItens, TEMP->(RECNO()) ) == 0, 'LBNO', 'LBOK') } DOUBLECLICK bMarca HEADERCLICK bMarcaTodos OF oBrowse
		For nInc := 1 To Len(aCampos)
			ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) PICTURE AvSx3(aCampos[nInc], AV_PICTURE)  SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
     	Next 
                                                                
	ACTIVATE FWBROWSE oBrowse
	
	oDlg:lMaximized := .T.                                                       

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED
oModel:GetModel('SWSDETAIL'):SetNoInsertLine(.t.)
oModel:GetModel('SWSDETAIL'):SetNoUpdateLine(.t.)

Return .T. 

/*
Function: GetAllItens
Objetivo: Retornar array com a sequência de todos os itens da Marcados
*/
*---------------------------*
Static Function GetAllItens()
*---------------------------*
Local aItens := {}, aOrd := SaveOrd("TEMP")

While TEMP->(!Eof())
   aAdd(aItens, TEMP->(RECNO()) )
   TEMP->(DbSkip())
EndDo                                

RestOrd(aOrd, .T.)                                                           
Return aItens

*---------------------------------------*          
Static Function LoadCpo(cALias,aCpo,cCpo)                               
*---------------------------------------*
LOCAL aCpo_SW1 := aCpo 
LOCAL cCpo_SW1 := cCpo 
cCpo := cCpo_SW1
aCpo := aCpo_SW1
SX3->(DbSetOrder(1)) 
SX3->(DbGotop())
If SX3->(DbSeek(cALias)) 
   Do While SX3->( !EOF() ) .And. SX3->X3_ARQUIVO == cALias  
      If ( (SX3->X3_PROPRI == "U") .AND. (SX3->X3_BROWSE == "S") )               
         AADD(aCpo,ALLTRIM(SX3->X3_CAMPO))
         cCpo += If(!Empty(ALLTRIM(SX3->X3_CAMPO)),',','')+If(!Empty(ALLTRIM(SX3->X3_CAMPO)),ALLTRIM(SX3->X3_CAMPO),'')  
      ENDIF
      SX3->(dbskip()) 
   EndDo                                       
EndIf

Return {aCpo,cCpo}

*-------------------------------*
Function Forne_Conc(oModel)
*-------------------------------*
Local oBrowse
Local oColumn
Local oDlg 
Local cCadastro	  := STR0015 //"Selecione o(s) Fornecedor(es) para cotações"
Local bValid	  := {|| If(Len(aItens) > 0,MsgYesNo(STR0010,STR0011), (MsgInfo(STR0016, STR0011), .F.))} //"Deseja Incluir"###"Atenção"###"Selecione ao menos um fornecedor para inclusão"###"Atenção"
Local bAcao       := {|| FornecSel(aItens),oDlg:End()}
Local bOk 		  := {|| If(Eval(bValid), Eval(bAcao), Nil) }   
Local bCancel	  := {|| If(Len(aItens) > 0,If(MsgYesNo(STR0017, STR0011),oDlg:End(),),oDlg:End() )} //"Há fornecedor(es) selecionado(s). Confirma o cancelamento?"###"Atenção"
Local bMarca	  := {|| If((nPos := aScan(aItens, TEMP->(RECNO()) ) ) == 0, aAdd(aItens, TEMP->(RECNO()) ), (aDel(aItens, nPos), aSize(aItens, Len(aItens)-1))) }
Local bMarcaTodos := {|oBrowse| If(Len(aItens) > 0, aItens := {}, aItens := GetAllItens()), oBrowse:Refresh() }     
Local aInd        := {"A5_FORNECE"} 
Local cQuery      := ""
LOCAL oView       := FWViewActive()
Local nInc        
Local nJ
Local nLinha      := 0
Local cProduto    := ""
Local aSaveLines  := FWSaveRows()

Private aCampos   := LoadCpo('SA5',{'A5_FORNECE','A5_LOJA','A2_NOME','A5_FABR','A5_FALOJA','A2_NREDUZ','A5_UNID','A2_PAIS','A5_INCOTER'},"A5_FORNECE,A5_LOJA,' ' A2_NOME,A5_FABR,A5_FALOJA,' 'A2_NOME,A5_UNID,' ' A2_PAIS,A5_INCOTER")[1] 
Private cCampos   := LoadCpo('SA5',{'A5_FORNECE','A5_LOJA','A2_NOME','A5_FABR','A5_FALOJA','A2_NREDUZ','A5_UNID','A2_PAIS','A5_INCOTER'},"A5_FORNECE,A5_LOJA,' ' A2_NOME,A5_FABR,A5_FALOJA,' 'A2_NREDUZ,A5_UNID,' ' A2_PAIS,A5_INCOTER")[2] 
Private aItens	  := {}            
Private oModelSWS   := oModel:GetModel('SWSDETAIL')  
Private oModelSWT   := oModel:GetModel('SWTDETAIL')
Private aRegCot     :={}

If Select("TEMP") > 0 
   TEMP->(DbCloseArea())
EndIf                                       

cProduto    := oModelSWS:GetValue("WS_COD_I") 

lMarcado:=.F.
IF !oModelSWS:IsDeleted() .AND. !EMPTY(oModelSWS:GETVALUE("WS__CC") + oModelSWS:GETVALUE("WS_SI_NUM") +oModelSWS:GETVALUE("WS_COD_I")) 
   lMarcado:=.T.
ENDIF

IF !lMarcado
   EasyHelp(STR0018,STR0011) //"É necessário selecionar o item a ser cotado"###"Atenção"
   oModel:GetModel('SWTDETAIL'):SetNoInsertLine(.t.)
   
   RETURN .T.
ELSEIF !oModelSWS:VldLineData()
   EasyHelp(STR0014,STR0011) //"Linha do item não está válida."###"Atenção"
   RETURN .T.
ENDIF 

cQuery += "Select "+cCampos + "                         
cQuery += "From "+RetSqlName("SA5")+" SA5 " 
cQuery += " "
cQuery += "Where SA5.D_E_L_E_T_ = '' AND SA5.A5_FILIAL = '"+xFilial("SA5")+"' AND A5_PRODUTO = '"+cProduto+"'

nLinha := oModelSWT:GetLine()

//montando um array com as cotacoes que ja foram inseridas 
FOR nJ:=1 to oModelSWT:Length()
   oModelSWT:GoLine(nJ)    
   IF oModelSWT:IsDeleted()
      LOOP
   ENDIF
   cChave:=oModelSWT:GetValue('WT__CC')+oModelSWT:GetValue('WT_SI_NUM')+oModelSWT:GetValue('WT_COD_I')+oModelSWT:GetValue('WT_FORN')+;
           oModelSWT:GetValue('WT_FORLOJ')+oModelSWT:GetValue('WT_FABR') +oModelSWT:GetValue('WT_FABLOJ') 
   
   AADD(aRegCot,cChave)
NEXT
 
FWRestRows(aSaveLines)
 
cCC:=oModelSWS:GetValue("WS__CC")
cSI:=oModelSWS:GetValue("WS_SI_NUM")
EasyWkQuery(cQuery,"TEMP",aInd,,{|cWork| aScan(aRegCot,cCC+cSI+cProduto+(cWork)->A5_FORNECE+(cWork)->A5_LOJA+(cWork)->A5_FABR+(cWork)->A5_FALOJA) == 0   })  

lMarcado:=.F.
TEMP->(DbGotop())
Do While TEMP->(!Eof())
   TEMP->A2_NOME    := Posicione('SA2',1,xFilial('SA2')+TEMP->(A5_FORNECE+A5_LOJA),"A2_NREDUZ")
   TEMP->A2_NREDUZ  := Posicione('SA2',1,xFilial('SA2')+TEMP->(A5_FABR+A5_FALOJA ),"A2_NREDUZ")
   TEMP->A2_PAIS    := Posicione('SA2',1,xFilial('SA2')+TEMP->(A5_FORNECE+A5_LOJA),"A2_PAIS")    
   lMarcado:=.T.
   TEMP->(DbSkip())
EndDo

TEMP->(DbGotop())
IF !lMarcado
   EasyHelp(STR0019,STR0011) //"Nenhum fornecedor encontrado."###"Atenção"
   oModel:GetModel('SWTDETAIL'):SetNoInsertLine(.t.)
   
   RETURN .T.
ENDIF

DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL
	
	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TEMP" OF oDlg
	
		ADD MARKCOLUMN oColumn DATA { || If(aScan(aItens, TEMP->(RECNO()) ) == 0, 'LBNO', 'LBOK') } DOUBLECLICK bMarca HEADERCLICK bMarcaTodos OF oBrowse
		For nInc := 1 To Len(aCampos)  		    	
			ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse			
     	Next
	ACTIVATE FWBROWSE oBrowse 
	
	oDlg:lMaximized := .T.                                                       

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED

oModel:GetModel('SWTDETAIL'):SetNoInsertLine(.t.)
                                                               
Return .T.

*------------------------------*
Static Function ItensSel(aItens)
*------------------------------*
Local oModel      := FWModelActive()
Local oMdlSWS     := oModel:GetModel('SWSDETAIL')
Local lRet        := .T.
Local nCont                                      
Private lInclusao := If(oModel:GetOperation() ==  3,.T.,.F.) 
Private cFilSW1   := xFilial("SW1"),cFilSA5 := xFilial("SA5"),cFilSB1 := xFilial("SB1")

oMdlSWS:SetNoInsertLine(.F.)
oMdlSWS:SetNoUpdateLine(.F.)

If !Empty(aItens)
   TEMP->(DbGoTop())
   For nCont := 1 To Len(aItens)   

      TEMP->(DbGoTo(aItens[nCont]))       
      If !Empty(oMdlSWS:GetValue("WS_SI_NUM"))    //Verificação para não gerar linha em branco no Gride
         ForceAddLine(oMdlSWS)
      EndIf                
      oMdlSWS:SetValue("WS_NR_CONC",M->WR_NR_CONC  )
      oMdlSWS:SetValue("WS__CC"   ,TEMP->W1_CC    )       
      oMdlSWS:SetValue("WS_SI_NUM",TEMP->W1_SI_NUM)      
      oMdlSWS:SetValue("WS_COD_I" ,TEMP->W1_COD_I )
      oMdlSWS:SetValue("WS_REG"   ,TEMP->W1_REG   )     
      oMdlSWS:SetValue("WS_DESCR" ,TEMP->B1_DESC  ) 
      oMdlSWS:SetValue("WS_QTDE"  ,TEMP->W1_QTDE  )           
      oMdlSWS:SetValue("WS_PESO"  ,TEMP->B1_PESO * TEMP->W1_QTDE )
                      
      cNecess:= BuscaNec('TEMP')
      
      oMdlSWS:SetValue("WS_NECES",cNecess  )
      
   Next
EndIf   

Return lRet

*--------------------------------------*
Static Function ForceAddLine(oModelGrid)  
*--------------------------------------*
Local lDel := .F.

If oModelGrid:Length() >= oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If !oModelGrid:IsDeleted()
      oModelGrid:DeleteLine()
      lDel := .T.
   EndIf
   oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If lDel
      oModelGrid:UnDeleteLine()
   EndIf
   oModelGrid:GoLine(oModelGrid:Length())
EndIf

Return .T.

/*
*------------------------------------*
Static Function QC400GridVal(oStruSWS)
*------------------------------------*
Local lRet        := .T.
Local nCont,nPos                                     

If ( (nPos := Ascan( oStruSWS:aFields,{|x| alltrim(x[3]) == "WS_DESCR"})) >0)
   oStruSWS:aFields[npos][07] := {|| Posicione("SB1",1,xFilial("SB1")+SWS->WS_COD_I,"B1_DESC") }
EndIf          

If ( (nPos := Ascan( oStruSWS:aFields,{|x| alltrim(x[3]) == "WS_PESO"})) >0)
   oStruSWS:aFields[npos][09] := {|| Posicione("SB1",1,xFilial("SB1")+SWS->WS_COD_I,"B1_PESO") }
EndIf

Return lRet
*/
*-------------------------------*
Static Function FornecSel(aItens)
*-------------------------------*
Local oModel      := FWModelActive()
Local oMdlSWT     := oModel:GetModel('SWTDETAIL')
Local oMdlSWS     := oModel:GetModel('SWSDETAIL')
LOCAL oView       := FWViewActive()
Local lRet        := .T.
Local nCont                                      
Private lInclusao := If(oModel:GetOperation() ==  3,.T.,.F.) 
Private cFilSW1   := xFilial("SW1"),cFilSA5 := xFilial("SA5"),cFilSB1 := xFilial("SB1"),cFilSA2 := xFilial("SA2") 

oMdlSWT:SetNoInsertLine(.F.)  

If !Empty(aItens)
   TEMP->(DbGoTop())                         
   For nCont := 1 To Len(aItens)   
   
      TEMP->(DbGoTo(aItens[nCont]))       
      If !Empty(oMdlSWT:GetValue("WT_FORN")  )  //Verificação para não gerar linha em branco no Gride             
         ForceAddLine(oMdlSWT)   
         oMdlSWT:GoLine(oMdlSWT:Length())
      EndIf
      //IGOR CHIBA GRAVANDO CAMPOS QUE SERAO NECESSARIOS PARA VINCULO
      oMdlSWT:SetValue("WT_NR_CONC",M->WR_NR_CONC )      
      oMdlSWT:SetValue("WT_SI_NUM" ,oMdlSWS:GetValue("WS_SI_NUM") ) 
      oMdlSWT:SetValue("WT_REG"    ,oMdlSWS:GetValue("WS_REG") ) 
      oMdlSWT:SetValue("WT__CC"    ,oMdlSWS:GetValue("WS__CC"))                             
      oMdlSWT:SetValue("WT_COD_I"  ,oMdlSWS:GetValue("WS_COD_I"))

      oMdlSWT:SetValue("WT_FORN"   ,TEMP->A5_FORNECE )
      oMdlSWT:SetValue("WT_FORLOJ" ,TEMP->A5_LOJA    )     
      
      cOrigem:=POSICIONE('SYR',2,XFILIAL('SYR')+M->WR_VIA+M->WR_DESTINO,'YR_ORIGEM') //IGOR CHIBA 
      oMdlSWT:SetValue("WT_ORIGEM" ,cOrigem)     
      
      oMdlSWT:SetValue("WT_FORNOME",LEFT(TEMP->A2_NOME,20)    )
      oMdlSWT:SetValue("WT_FABR"   ,TEMP->A5_FABR    )
      oMdlSWT:SetValue("WT_FABLOJ" ,TEMP->A5_FALOJA  )
      oMdlSWT:SetValue("WT_FABRNOM",LEFT(TEMP->A2_NREDUZ,20)  )
      
      cUnid           := Posicione('SB1',1,xFilial('SB1')+AVKEY(oMdlSWS:GetValue('WS_COD_I'),'B1_COD'),"B1_UM")    
      oMdlSWT:SetValue("WT_UM"     ,cUnid      )//IGOR CHIBA   UNIDADE
      
      //AAF 07/08/2014 - Considerar apenas unidade do item 
      //IF cUnid <> TEMP->A5_UNID
      //   nQtde := AVTransUnid(cUnid,TEMP->A5_UNID,oMdlSWS:GetValue('WS_COD_I'),oMdlSWS:GetValue('WS_QTDE'),.F.,.F.,{},TEMP->A5_FORNECE,TEMP->A5_LOJA)//IGOR CHIBA CONVERTER UNIDADE
      //ELSE
      nQtde := oMdlSWS:GetValue('WS_QTDE')
      //ENDIF
      
      oMdlSWT:SetValue("WT_QTDE"   ,nQtde)            
      oMdlSWT:SetValue("WT_INCOTER",LEFT(TEMP->A5_INCOTER,3) )  
   Next
EndIf

Return lRet

/*
FUNCAO  : EICQCPRE(oModel)
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: nao deixar exlcuir se possuir alguma cotacao aprovada
*/
*--------------------------*
STATIC FUNCTION EICQCPRE(oModel)
*--------------------------*   
Local nI, nJ
Local oModelSWS  := oModel:GetModel( 'SWSDETAIL' )//MODEL ITEM 
Local oModelSWT  := oModel:GetModel( 'SWTDETAIL' )//MODEL COTACAO

IF oModel:GetOperation() == 5 //EXCLUSAO 
   
   For nI:=1 to oModelSWS:Length()
      oModelSWS:GoLine( nI )
   
      For nJ:=1 to oModelSWT:Length()
         oModelSWT:GoLine( nJ )
         
		 If oModelSWT:GetValue('WT_STATUS') == '3'
            EasyHelp(STR0020,STR0011) //"Processo não pode ser excluído, existem cotações aprovadas."###"Atenção"
            Return .F.
         EndIf
		 
         /*IF !EMPTY(oModelSWT:GetValue('WT_NUMERP')) 
            EasyHelp(STR0021,STR0011) //"Processo não pode ser excluído, existem cotações com número do ERP preenchido."###"Atenção"
            RETURN .F.
         ENDIF*/
         
      Next nJ 
   Next nI
   
EndIf

Return .T.

/*
FUNCAO  : SWSLINE(cAction,nLine)
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: VALID DO DELETAR E DO RETORNAR LINHA DO ITEM SWS
*/
*-------------------------------------*
STATIC FUNCTION SWSLINE(cAction,nLine)
*-------------------------------------*
LOCAL oModel     := FWModelActive()
LOCAL oModelSWS  := oModel:GetModel( 'SWSDETAIL' )//MODEL ITEM 
LOCAL oModelSWT  := oModel:GetModel( 'SWTDETAIL' )//MODEL COTACAO
LOCAL oView      := FWViewActive()
LOCAL nJ   

IF ALLTRIM(cAction) == 'DELETE'
    //  oModelSWS:GoLine(nLine)
      //FOR DE COTACOES
      aDelSWT:={}
      For nJ:=1 to oModelSWT:Length()
         oModelSWT:GoLine( nJ )  
         IF oModelSWT:IsDeleted()
            LOOP
         ENDIF
         
         IF oModelSWT:GetValue('WT_COD_I')+oModelSWT:GetValue('WT_SI_NUM')+oModelSWT:GetValue('WT__CC') <> ;
            oModelSWS:GetValue('WS_COD_I')+oModelSWS:GetValue('WS_SI_NUM')+oModelSWS:GetValue('WS__CC') 
            LOOP
         ENDIF
         
         IF oModelSWT:GetValue('WT_STATUS') == '3' 
            EasyHelp(STR0022,STR0011) //"Item não pode ser deletado, possui cotações aprovadas."###"Atenção"
            RETURN .F.  
         ELSE//pode deletar posteriormente
            AADD(aDelSWT,nJ)
         ENDIF   
      NEXT
      IF LEN(aDelSWT) <> 0 
         FOR nJ:=1 to len(aDelSWT)
            oModelSWT:GoLine( aDelSWT[nJ] )    
            oModelSWT:Deleteline()   
         NEXT
      ENDIF
ELSEIF  ALLTRIM(cAction) == 'UNDELETE' 
   For nJ:=1 to oModelSWT:Length()
      oModelSWT:GoLine( nJ )
       
      IF oModelSWT:GetValue('WT_COD_I')+oModelSWT:GetValue('WT_SI_NUM')+oModelSWT:GetValue('WT__CC') <> ;
         oModelSWS:GetValue('WS_COD_I')+oModelSWS:GetValue('WS_SI_NUM')+oModelSWS:GetValue('WS__CC') 
         LOOP
      ENDIF
         
      oModelSWT:UNDeleteline()    
   
   NEXT
ENDIF

Return .T.

/*
FUNCAO  : EICQCPOS()
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: VALIDACAO DOS CAMPOS SWT
*/
*---------------------------*
FUNCTION EICQCPOS(oModel)
   
*---------------------------*
Local lRet:=.T.         
oModSWR := oModel:GetModel( 'SWRMASTER' )

IF !EMPTY(oModSWR:GetValue('WR_INIVAL')).AND. !EMPTY(oModSWR:GetValue('WR_FIMVAL'))
   IF oModSWR:GetValue('WR_FIMVAL')<oModSWR:GetValue('WR_INIVAL')
      EasyHelp(STR0023,STR0011) //"Data de validade inicial deve ser menor do que a data de validade final."###"Atenção"
      lRet:=.F.         
   ENDIF  
   
ENDIF
/*
IF LRET 
    EICQCCOM(oModel)
ENDIF
*/
Return lRet

/*
FUNCAO  : QC400VLCPO(cCpo)
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: VALIDACAO DOS CAMPOS SWT
*/
*---------------------------*
FUNCTION QC400VLCPO(cCpo)
*---------------------------*
Local lRet:=.T.
Local nJ                         
Local lAtualizou:=.f.
LOCAL oView    := FWViewActive()
LOCAL oModel   := FWModelActive()
LOCAL aValues  := aClone(oModel:GetErrorMessage())                                                  
LOCAL lValida  := 'WT_' $ cCpo .AND. EMPTY(oModel:GetModel('SWTDETAIL'):GetValue("WT_FABR")+oModel:GetModel('SWTDETAIL'):GetValue("WT_FORN"));
                               .AND. !IsInCallStack("Forne_Conc") ;
                               .AND. oModel:GetModel('SWTDETAIL'):Length() == 1 
//NAO DEIXAR ALTERA CAMPO DA SWT QUANDO A LINHA FOR A PRIMEIRA E TIVER OS VALORES DE FABRICANTE E FORNECEDOR EM BRANCO EXCETO QUANDO VEM DO BOTAO FORNECE_CONC                               


IF lValida
   EasyHelp(STR0024) //"Campo não pode ser alterado sem incluir um fornecedor."
   RETURN .F.
ENDIF
   
DO CASE                           
  
      
   CASE cCpo == 'WT_MOEDA'
      lRet:= EXISTCPO('SYF',M->WT_MOEDA,1) .AND. !Empty(BuscaTaxa(M->WT_MOEDA,M->WR_DT_CONC,,.T.,.T.,,'1'))
   
   CASE cCpo == 'WT_MOE_FRE'
      lRet:= EXISTCPO('SYF',WT_MOE_FRE)
 
   CASE cCPo == 'WT_FRE_KG'
      IF (lRet:=POSITIVO(M->&(cCPo)))         
         IF AvRetInco(oModel:GetModel('SWTDETAIL'):GetValue("WT_INCOTER"),"CONTEM_FRETE")
            EasyHelp(STR0025) //"Incoterm nao preve frete."
            lRet:=.F.
         ENDIF
      ENDIF
      
   CASE cCPo == 'WT_SEGURO'
      IF (lRet:=POSITIVO(M->&(cCPo)))
         IF AvRetInco(oModel:GetModel('SWTDETAIL'):GetValue("WT_INCOTER"),"CONTEM_SEG")
            EasyHelp(STR0026) //"Incoterm nao preve seguro."
            lRet:=.F.
         ENDIF
      ENDIF
     
   CASE cCPo == 'WT_FABR'
      lRet:=EXISTCPO('SA2',M->WT_FABR)
   
   CASE cCPo $ 'WT_VL_UNIT WT_DESPIN WT_DESPRS'
      lRet:=POSITIVO(M->&(cCPo))
  
   CASE cCPo == 'WT_FORN'
      lRet:=EXISTCPO('SA2',M->WT_FORN)
      //oMdlSWS:SetValue("WS__CC"   ,TEMP->W1_CC    )       
   
   CASE cCPo == 'WT_ORIGEM'
      cChave := oModel:GetModel('SWTDETAIL'):GetValue("WT_ORIGEM")
      lRet:= ExistCpo("SYR",cChave,3)
   CASE cCPo == 'WT_INCOTER'
      lRet:=ExistCpo('SYJ',M->WT_INCOTER)

   CASE cCPo == 'WT_COD_PAG'
      lRet:=ExistCpo("SY6",M->WT_COD_PAG)

   CASE cCPo == 'WR_VIA'
      lRet:=ExistCpo('SYQ',M->WR_VIA)
      IF lRet .AND. !EMPTY(oModel:GetModel('SWTDETAIL'):GetValue("WT_FABR")+oModel:GetModel('SWTDETAIL'):GetValue("WT_FORN"))
         AtivaTrig(cCPo)
      ENDIF
       
   CASE cCPo == 'WR_DESTINO'
      SYR->(DBSETORDER(2))
      lRet:=ExistCpo('SYR',M->WR_VIA+M->WR_DESTINO)
      SYR->(DBSETORDER(1))
      IF lRet .AND. !EMPTY(oModel:GetModel('SWTDETAIL'):GetValue("WT_FABR")+oModel:GetModel('SWTDETAIL'):GetValue("WT_FORN"))
         AtivaTrig(cCPo)
      ENDIF
         
   CASE cCPo == 'WR_DT_CONC'
      IF !EMPTY(oModel:GetModel('SWTDETAIL'):GetValue("WT_FABR")+oModel:GetModel('SWTDETAIL'):GetValue("WT_FORN"))
         AtivaTrig(cCPo)
      ENDIF
   CASE cCPo == 'WR_PER_SEG'
      lRet:=POSITIVO(M->WR_PER_SEG)
      IF lRet .AND. !EMPTY(oModel:GetModel('SWTDETAIL'):GetValue("WT_FABR")+oModel:GetModel('SWTDETAIL'):GetValue("WT_FORN"))
         AtivaTrig(cCPo)
      ENDIF
      
ENDCASE
                          
IF ! cCpo $ 'WR_VIA WR_DESTINO WR_PER_SEG WR_DT_CONC WT_STATUS' .AND. !ISINCALLSTACK('RUNTRIGGER')//ASCAN(aMsg,oModel:GetModel('SWTDETAIL'):GetLine()) == 0 // os campos da capa nao devem ativar essa validação
   //EM TODOS CASOS DOS GRIDS
   IF oModel:GetModel('SWTDETAIL'):GetValue("WT_STATUS") == '4' .AND. !oModel:GetModel('SWTDETAIL'):IsDeleted()
      IF !MSGYESNO(STR0027) //"Existe uma outra cotação já aprovada para este item, deseja mesmo alterar esta cotação?"
         RETURN .F.                                        
      ENDIF
   ELSEIF oModel:GetModel('SWTDETAIL'):GetValue("WT_STATUS") == '3' .AND. !oModel:GetModel('SWTDETAIL'):IsDeleted()
      IF cCpo $ ' WT_VL_UNIT WT_DESPRS WT_FRE_KG WT_SEGURO WT_DESPIN' 
         IF aValues[9]<aValues[8]   //VALOR 9= ANTIGO E VALOR 8=NOVO OU SEJA ESTA AUMENTANDO
               
            IF !MSGYESNO(STR0028) //"Esta cotação já está aprovada. A alteração para um custo maior está sujeita a nova aprovação. Tem certeza que deseja mesmo alterar esta cotação?"               
               RETURN .F.
            ENDIF
         ELSE
            IF !MSGYESNO(STR0029) //"Esta cotação já está aprovada para este item, deseja mesmo alterar esta cotação?.Após esta alteração a mesma continuará aprovada."
               RETURN .F.
            ENDIF
         ENDIF   
      ENDIF   
            
   ENDIF
ENDIF 

Return lRet

/*
FUNCAO  : AddGatilhos(oStruct,aCampos,cFuncao)
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: ADICIONAR GATILHOS NA ESTRUTURA DA SWT
*/
*-------------------------------------------*
STATIC Function AddGatilhos(oStruct,aCampos,cFuncao)
*-------------------------------------------*
Local nI        := 1
LOCAL oModel   := FWModelActive()

For nI := 1 To Len(aCampos)
    cCodBlock := "{ |oModel| " + cFuncao + "(oModel,'"+aCampos[nI][1]+"','"+aCampos[nI][2]+"')}"
    oStruct:AddTrigger( aCampos[nI][1] ,; // [01] Id do campo de origem
                        aCampos[nI][2] ,; // [02] Id do campo de destino
                       {|| .T. } ,; 	  // [03] Bloco de codigo de validação da execução do gatilho
                       &(cCodBlock) )     // [04] Bloco de codigo de execução do gatilho
Next

Return oStruct

/*
FUNCAO  :  EICQ400CAL
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: EXECUTAR GATILOS PARA AS COTACOES
*/
*---------------------*
FUNCTION EICQ400CAL(oModelx,cCampoOrigem,cCampoDest)
*---------------------*
Local cRet 
Local nJ                        
LOCAL oView    := FWViewActive()                 
LOCAL oModel   := FWModelActive()
LOCAL aValues  := aClone(oModel:GetErrorMessage())
LOCAL oModelSWT := oModel:GetModel("SWTDETAIL")
LOCAL oModelSWS := oModel:GetModel("SWSDETAIL")

DO CASE
 
   CASE cCampoDest =='WT_ORIGEM'
      cRet:= POSICIONE('SYR',2,XFILIAL('SYR')+M->WR_VIA+M->WR_DESTINO,'YR_ORIGEM')

   CASE cCampoDest =='WT_STATUS' 
      IF !oModelSWT:GetValue("WT_STATUS")  $ '3/4' //SE NAO FOR APROVADA E REPROVADA
         IF Empty(oModelSWT:GetValue("WT_VL_UNIT")) .OR. Empty(oModelSWT:GetValue("WT_TOTRS")) .OR.;
         Empty(oModelSWT:GetValue("WT_COD_PAG")) .OR. Empty(oModelSWT:GetValue("WT_DT_FORN")) .OR.;
         Empty(oModelSWT:GetValue("WT_MOEDA")) .OR. Empty(oModelSWT:GetValue("WT_INCOTER"))
            cRet:='1'//AGUARDANDO COTACAO
         ELSE
            cRet:='2'//AGUARDANDO AVALIACAO
         ENDIF
      ELSE
         cRet:=oModelSWT:GetValue("WT_STATUS")
      ENDIF
   
   CASE cCampoDest =='WT_MOE_FRE'
       cRet:=Posicione("SYR",2,xFilial("SYR")+M->WR_VIA+ M->WR_DESTINO,"YR_MOEDA")

   CASE cCampoDest == 'WT_TOTMVC' //OK
       cRet := oModelSWT:GetValue("WT_VL_UNIT") * oModelSWT:GetValue("WT_QTDE") 

   CASE cCampoDest == 'WT_CIFRS' //ok quando tem valor
      IF EMPTY(oModelSWT:GetValue("WT_TOTMVC"))
         cRet:=0
      ELSE                          
         //IF  BuscaTaxa(oModel:GetValue('WT_MOEDA'),M->WR_DT_CONC,.T.,.F.,.T.) //SYE->(DBSEEK(xFilial('SYE')+DTOS(M->WR_DT_CONC)+oModel:GetValue('WT_MOEDA')  )) 
           // nTaxa:=SYE->YE_VLCON_C
         //ELSE
            nTaxa:=BuscaTaxa(oModelSWT:GetValue('WT_MOEDA'),M->WR_DT_CONC,,.F.,.T.,,'1')//0
         //ENDIF
        
         //IF  //SYE->(DBSEEK(xFilial('SYE')+DTOS(M->WR_DT_CONC)+oModel:GetValue('WT_MOE_FRE')  )) 
            nTaxaFre:=BuscaTaxa(oModelSWT:GetValue('WT_MOE_FRE'),M->WR_DT_CONC,,.F.,.T.,,'1')
         //ELSE
          //  nTaxaFre:=0
        // ENDIF        
         
         cRet:=( oModelSWT:GetValue("WT_TOTMVC")* nTaxa )+ (oModelSWT:GetValue("WT_DESPIN") * nTaxa)+(oModelSWT:GetValue("WT_FRE_KG")*nTaxaFre)+(oModelSWT:GetValue("WT_SEGURO")*nTaxa)
      ENDIF         
   
   CASE cCampoDest == 'WT_TOTRS'  //OK QUANDO NAO TA ZERO        
      IF EMPTY(oModelSWT:GetValue("WT_TOTMVC"))
         cRet:=0
      ELSE 
         cRet:=oModelSWT:GetValue("WT_CIFRS") + oModelSWT:GetValue("WT_DESPRS")
      ENDIF   
   
  
   CASE cCampoDest == 'WT_TOTURS'  //OK
       cRet := oModelSWT:GetValue("WT_TOTRS") /  oModelSWT:GetValue("WT_QTDE") 
   
   CASE cCampoDest == 'WT_FRE_KG'  //OK
       
       IF AvRetInco(oModelSWT:GetValue("WT_INCOTER"),"CONTEM_FRETE")
          cRet  := 0
       ELSE      
          nPeso:= B1Peso(oModelSWT:GetValue("WT__CC") , oModelSWT:GetValue("WT_SI_NUM"),oModelSWT:GetValue("WT_COD_I") ,oModelSWT:GetValue("WT_REG") ,oModelSWT:GetValue("WT_FABR") , oModelSWT:GetValue("WT_FORN") )
          cRet := TabFre(nPeso,.T.) * oModelSWT:GetValue("WT_QTDE")
       ENDIF  


   CASE cCampoDest == 'WT_SEGURO' //OK QUANDO NAO TA ZERO
    
       IF AvRetInco(oModelSWT:GetValue("WT_INCOTER"),"CONTEM_SEG")
          cRet  := 0
       ELSEIF M->WR_PER_SEG > 0
	      If AvRetInco(oModelSWT:GetValue("WT_INCOTER"),"CONTEM_FRETE")
             cRet  := (M->WR_PER_SEG/100) *  (oModelSWT:GetValue("WT_TOTMVC") - oModelSWT:GetValue("WT_DESPIN") - oModelSWT:GetValue("WT_FRE_KG"))   
          ELSE        
             cRet  := (M->WR_PER_SEG/100) *  (oModelSWT:GetValue("WT_TOTMVC") - oModelSWT:GetValue("WT_DESPIN") )  
          ENDIF
	   Else
	      cRet := oModelSWT:GetValue("WT_SEGURO")
       EndIf
ENDCASE

IF cCampoOrigem $ ' WT_VL_UNIT WT_DESPRS WT_FRE_KG WT_SEGURO WT_DESPIN' .AND. oModelSWT:GetValue("WT_STATUS") == '3' .AND. !oModelSWT:IsDeleted() //se estiver aprovado e alterar valor todos devem fica rcomo aguardando
   IF aValues[9]<aValues[8]   //VALOR 9= ANTIGO E VALOR 8=NOVO OU SEJA ESTA AUMENTANDO     
      cCC  := oModelSWT:GetValue("WT__CC")
      cSI  := oModelSWT:GetValue("WT_SI_NUM")
      cItem:= oModelSWT:GetValue("WT_COD_I")
      
      IF ASCAN(aAtuStatus,{|X| X[1]== cSi .AND.  X[2] == cItem .AND.  X[3]== cCC}) ==0
         AADD(aAtuStatus,{cSi,cItem,cCC}) 
      ENDIF
      
      For nJ:=1 to oModelSWT:Length()
         oModelSWT:GoLine( nJ , .F.)                                                           
         IF cCC == oModelSWT:GetValue("WT__CC") .AND. cSI == oModelSWT:GetValue("WT_SI_NUM") .AND.  cItem == oModelSWT:GetValue("WT_COD_I")
            oModelSWT:Loadvalue('WT_STATUS','2')//aguardando avaliação  
            oModelSWT:Loadvalue('WT_STATUS',EICQ400CAL(,'WT_STATUS','WT_STATUS')) //AAF 29/09/2014 - Rodar atualização de status (pode ser que esteja aguardando cotação).
         ENDIF   
      NEXT 
      oView:Refresh()           
   ENDIF
ENDIF
         
RETURN cRet

/*
FUNCAO  : GERQRY()
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: PESQUISAR APENAS AS COTAÇÕES QUE POSSUEM O ITEM DO PARAMETRO
*/
*---------------------------*
Static Function GERQRY(cItem,cFil,cCC,cSi)
*---------------------------*
Local cQry     := "" 
Local aConcorre:= {}

IF SELECT('TMP') <> 0
   TMP->(DBCLOSEAREA())
ENDIF

cQry := " SELECT DISTINCT(WS_NR_CONC) FROM " + RetSqlName("SWS") + " where D_E_L_E_T_ = '' AND WS_FILIAL = '"+cFil
cQry += "' AND WS_COD_I ='"+cItem+"'AND WS__CC = '"+cCC+"' AND WS_SI_NUM ='"+cSI+"' ORDER BY WS_NR_CONC"
cQry := ChangeQuery(cQry)
DBUseArea(.T., "TopConn", TCGenQry(,, cQry), "TMP", .T., .T.) 

TMP->(DBGOTOP())
DO WHILE TMP->(!EOF())
   aAdd(aConcorre,TMP->WS_NR_CONC)
   TMP->(DBSKIP())
ENDDO

TMP->(dbCloseArea())

RETURN aClone(aConcorre)

*--------------------------*
STATIC FUNCTION EICQCCOM(oModel)
*--------------------------*
LOCAL cUnReq   := "99999" // Unidade Requisitante Padrão
LOCAL nJ
LOCAL oModelSWS  := oModel:GetModel('SWSDETAIL')
LOCAL oModelSWT  := oModel:GetModel('SWTDETAIL')
LOCAL nI
Local aWT:= SWT->({IndexOrd(),RecNo()})

SW1->(DBSETORDER(1))
For nI:=1 to oModelSWS:Length()
   oModelSWS:GoLine( nI )
   
   For nJ:=1 to oModelSWT:Length()
      oModelSWT:GoLine( nJ )
   
      IF oModelSWT:ISDELETED() .OR. oModel:GetOperation() == 5
         //atualizar sw1 para A-PENDENTE
         IF SW1->(DBSEEK(xFilial("SW1")+AvKey(cUnReq,"W1_CC")+AvKey(oModelSWT:GetValue('WT_SI_NUM'),"W1_SI_NUM")+AvKey(oModelSWT:GetValue('WT_COD_I'),"W1_COD_I")    ))
            SW1->(MSUNLOCK())           
            SW1->(RECLOCK('SW1',.F.))
            SW1->W1_STATUS:= 'A' 
            SW1->(MSUNLOCK())
         ENDIF
      ELSE                            
         //atualizar sw1 para B-EM PROCESSO DE COTAÇÃO
         SWT->(dbSetOrder(4))
         
         IF SW1->(DBSEEK(xFilial("SW1")+AvKey(cUnReq,"W1_CC")+AvKey(oModelSWT:GetValue('WT_SI_NUM'),"W1_SI_NUM")+AvKey(oModelSWT:GetValue('WT_COD_I'),"W1_COD_I")    ))
            IF SW1->W1_STATUS == 'A'
               SW1->(RECLOCK('SW1',.F.))
               SW1->W1_STATUS:= 'B'
               SW1->(MSUNLOCK())
            ElseIf oModelSWT:GetValue('WT_STATUS') <> "3" .AND. !Empty(oModelSWT:GetValue('WT_ID')) .AND.;
            SWT->(dbSeek(xFilial("SWT")+oModelSWT:GetValue('WT_ID'))) .AND. SWT->WT_STATUS == "3"
               SW1->(RECLOCK('SW1',.F.))
               SW1->W1_STATUS  := 'B'
      	       SW1->W1_NR_CONC := ""
               SW1->(MSUNLOCK())
            ENDIF
         ENDIF             
      ENDIF
   Next nJ
NEXT nI

SWT->(dbSetOrder(aWT[1]),dbGoTo(aWT[2]))

//APESAR DA FUNCAO SE CHAMAR REJEITA , ESTA ATUALIZANDO TODAS AS COTACOES PARA 2-AGUARDANDO AVALIAÇÃO
For nI:=1 to len(aAtuStatus)
   RejeitaSWT(aAtuStatus[nI][1],aAtuStatus[nI][2],'','','2',aAtuStatus[nI][3])
NEXT
aAtuStatus:={}

RETURN .T.       

*--------------------------------*
STATIC FUNCTION BUSCANEC(cAlias)
*--------------------------------*
LOCAL cNecess := '' 
LOCAL cFil    := xFilial('ELD')
    
ELD->(DBSETORDER(1))
IF cAlias == 'TEMP'
   IF ELD->(DBSEEK(cFil+AVKEY(TEMP->W1_CC,'ELD_CC') +AVKEY(TEMP->W1_SI_NUM,'ELD_SI_NUM')))
      DO WHILE ELD->(!EOF()) .AND. ELD->(ELD_FILIAL+ELD_CC+ELD_SI_NUM) == cFil+AVKEY(TEMP->W1_CC,'ELD_CC') +AVKEY(TEMP->W1_SI_NUM,'ELD_SI_NUM')
         IF !EMPTY(cNecess)
            cNecess+= ','
         ENDIF
         cNecess+= ALLTRIM(STR(ELD->ELD_QTSOLI)) + '-' + DTOC(ELD->ELD_DTPREV)
         ELD->(DBSKIP())
      ENDDO 
   ENDIF              
ELSE 
   IF ELD->(DBSEEK(cFil+AVKEY(SWS->WS__CC,'ELD_CC') +AVKEY(SWS->WS_SI_NUM,'ELD_SI_NUM')))
      DO WHILE ELD->(!EOF()) .AND. ELD->(ELD_FILIAL+ELD_CC+ELD_SI_NUM) == cFil+AVKEY(SWS->WS__CC,'ELD_CC') +AVKEY(SWS->WS_SI_NUM,'ELD_SI_NUM')
         IF !EMPTY(cNecess)
            cNecess+= ','
         ENDIF
         cNecess+= ALLTRIM(STR(ELD->ELD_QTSOLI)) + '-' + DTOC(ELD->ELD_DTPREV)
         ELD->(DBSKIP())
      ENDDO 
   ENDIF              
ENDIF

RETURN cNecess       

*--------------------------------*
Static Function AtivaTrig(cCpo)
*--------------------------------*
LOCAL nJ, nI
LOCAL oModel    := FWModelActive()
LOCAL oView     := FWViewActive()
LOCAL oModelSWS:=oModel:GetModel('SWSDETAIL')
LOCAL oModelSWT:=oModel:GetModel('SWTDETAIL') 

oView:Refresh()
For nI:=1 to oModelSWS:Length()
   oModelSWS:GoLine(nI)
   
   For nJ:=1 to oModelSWT:Length()  
      oModelSWT:GoLine(nJ)
      IF !oModelSWT:IsDeleted()  
         IF cCPO $ 'WR_VIA WR_DESTINO'
            cRet:=EICQ400CAL(oModel,cCPO,'WT_ORIGEM')
            oModelSWT:SETVALUE('WT_ORIGEM',cRet)
         ELSEIF cCPO == 'WR_PER_SEG'
            cRet:= EICQ400CAL(oModel,cCpo,'WT_SEGURO')
            oModelSWT:SETVALUE('WT_SEGURO',cRet)        
         ELSEIF cCPO == 'WR_DT_CONC'
            cRet:= EICQ400CAL(oModel,cCpo,'WT_CIFRS')
            oModelSWT:SETVALUE('WT_CIFRS',cRet)   
         ENDIF
      ENDIF
   Next nJ
Next nI
oView:Refresh()

RETURN .T.

*--------------------------------*
Static Function AtuView(oView)
*--------------------------------*
Local lRet := .T.
Local oModel  := FWModelActive()
oView:aUserButtons := {} 

If ALTERA .OR. INCLUI//VARIAVEIS PUBLICAS
   oView:addUserButton( "Itens"      ,"",{ |oModel| Itens_Conc(oModel)},"")
   oView:addUserButton( "Fornecedor" ,"",{ |oModel| Forne_Conc(oModel)},"")
EndIf

Return .T.

/*
FUNCAO  : SWSLINE(cAction,nLine)
AUTOR   : IGOR CHIBA
DATA    : 03/06/14
OBJETIVO: VALID DO DELETAR E DO RETORNAR LINHA DO ITEM SWS
*/
*-------------------------------------*
STATIC FUNCTION SWTLINE(cAction,nLine,cField)
*-------------------------------------*
LOCAL oModel    := FWModelActive()
LOCAL oModelSWT := oModel:GetModel('SWTDETAIL') 

If ALLTRIM(cAction) $ 'DELETE/UNDELETE' .AND. !(IsInCallStack("ForceAddLine") .OR. IsInCallStack("SWSLINE"))
   IF ALLTRIM(cAction) ==  'DELETE'  .AND. oModelSWT:GetValue('WT_STATUS') == '3' 
      EasyHelp("Item não pode ser deletado, possui cotações aprovadas.","Atenção")
      RETURN .F.
   ENDIF  
ENDIF

RETURN.T.

Static Function QC400Commit(oMdl)
Local lRet := .T.

Begin Transaction

EICQCCOM(oMdl)

lRet := FWFormCommit(oMdl)
If lRet .AND. Type("aFilConc")=="A"
   aConcorr := GerQry(aFilConc[1],aFilConc[2],aFilConc[3],aFilConc[4])
EndIf

End Transaction

Return lRet