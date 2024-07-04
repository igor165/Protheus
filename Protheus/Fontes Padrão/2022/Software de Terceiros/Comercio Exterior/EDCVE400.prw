#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "EDCVE400.CH"


/*
Programa   : EDCVE400
Objetivo   : Manutenção da rotina de Vendas p/ Exportadores utilizando MVC
Retorno    : Nil
Autor      : Felipe Sales Martinez
Data/Hora  : 26/09/2011
Obs.       :
*/
Function EDCVE400(xRotAuto,nOpcAuto)

Local oBrowse
Local cFilter := ""
Local cAlias  := "ED9"
Local cDescription := STR0001 //"Vendas para Exportadores"
Local lTemFiltro := .F.
Local cFonte := "EDCVE400"
 
//Variaveis utilizadas em outro fonte para tratamento de comprovação de Ato Concessorio
Private lVEPrevia    := .F. //Sempre falso
Private lAcaoVincula := .F. //Habilita a ação de vinculação/desvincução de ato.
Private lVincula     := .T. //.T. ->Vincula / .F. ->Desvincula ato concessorio.
Private lRevincula   := .F. //Desvincula o ato anterior e vincula o novo ato.
Private lVendasExp   := .T. //Manutenção de Vendas p/ Exportadores

Private lVeAuto := ValType(xRotAuto) == "A" .And. ValType(nOpcAuto) == "N"

Begin Sequence

	//Verifica se a tabela já possui filtro
	lTemFiltro := !Empty( (cAlias)->( DBFilter() ) )


	cFilter := cAlias+"_PEDIDO # '" + space(AVSX3("ED9_PEDIDO",AV_TAMANHO)) + "' .And." +;
	           cAlias+"_CODEXP # '" + space(AVSX3("ED9_CODEXP",AV_TAMANHO)) + "'"

	//Adiciona um novo filtro junto com que já existia
	If lTemFiltro
		cFilter := "("+(cAlias)->(DbFilter())+") .And. ("+cFilter+")"
		(cAlias)->(DbClearFilter())
	EndIf

End Sequence


//CRIAÇÃO DA MBROWSE
If xRotAuto == NIL
   oBrowse := FWMBrowse():New() //Instanciando a Classe
   oBrowse:SetAlias(cAlias) //Informando o Alias
   oBrowse:SetMenuDef(cFonte) //Nome do fonte do MenuDef
   oBrowse:SetDescription(cDescription) //Descrição a ser apresentada no Browse
   oBrowse:SetFilterDefault(cFilter)
   oBrowse:Activate()
Else
   aRotina := MenuDef()
   FWMVCRotAuto(ModelDef(),"ED9",nOpcAuto,{{"ED9MASTER",xRotAuto}})
EndIf

Return Nil


*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EDCVE400" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EDCVE400" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EDCVE400" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EDCVE400" OPERATION 5 ACCESS 0

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruED9 :=  MontaEstrutura(1) //Monta a estrutura da tabela ED9
Local bCommit  := { |oMdl| .T. /*DEMUCOMMIT(oMdl)*/ }
Local bPosValidacao := { |oMdl| If(VE400ValOK(oMdl),VE400VinculaAto(oMdl),.F.) }

/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
//	oModel := MPFormModel():New( "EDCVE", /*bGridValidacao*/, bPosValidacao, bCommit, /*bCancel*/ )
oModel := MPFormModel():New( "EDCVE", /*bGridValidacao*/,  bCommit, bPosValidacao, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EEI
oModel:AddFields( "ED9MASTER",/*nOwner*/,oStruED9, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001) //"Vendas para Exportadores"

//Utiliza a chave primaria
oModel:SetPrimaryKey( { "ED9_FILIAL", "ED9_PEDIDO", "ED9_POSICA"/*, "ED9_AC"*/ } )

Return oModel


*------------------------*
Static Function ViewDef()
*------------------------*
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EDCVE400")

// Cria a estrutura a ser usada na View
Local oStruED9 := MontaEstrutura(2)

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("ED9MASTER", oStruED9)

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "ENCHOICE"  , 100 /*,,,"IDFOLDER","IDSHEET01"*/)

// Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView( "ED9MASTER" , "ENCHOICE"  )

// Liga a identificação do componente
oView:EnableTitleView( "ED9MASTER", STR0001  , RGB(240, 248, 255 )) //##"Vendas para Exportadores" 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)


Return oView


/*
Programa   : CpoOut
Objetivo   : Retira campos da estrutura da tela.
Retorno    : Logico
Autor      : Felipe Sales Martinez
Data/Hora  : 26/09/2011
Obs.       :
*/
*-------------------------------*
Static Function CpoOut( cCampo , nMvc )
*-------------------------------*
Local lRet := .T.

//Campos a serem excluidos da estrutura:
If AllTrim(cCampo) $ "ED9_RE/ED9_EXPORT/ED9_DTRE/ED9_DT_INT/ED9_DTAVRB/ED9_VALORI" .Or.;
   (nMvc == 2 .And. AllTrim(cCampo) $ "ED9_DTEMB/ED9_VAL_SE/ED9_SALISE/ED9_VALCOM")  
	lRet := .F.
EndIf

Return lRet


/*
Programa   : MontaEstrutura
Objetivo   : Monta a Estrutura de campos a ser exibida na manutenção
Retorno    : Objeto
Autor      : Felipe Sales Martinez
Data/Hora  : 26/09/2011
Obs.       :
*/
*-------------------------------------*
Static Function MontaEstrutura( nMvc )
*-------------------------------------*
//Com base no dicionario monta a estrutura dos campos, exceto pelo campos da função 'CpoOut':
Local oStruct :=  FWFormStruct( nMvc , "ED9", { |cCampo| CpoOut(cCampo,nMvc) })
//campo extras a serem adicionados a estrutura:
Local aCampos := {/*"ED9_PEDIDO","ED9_CODEXP","ED9_EXPLOJ",*/"ED9_DESEXP"}  //NCF - 06/08/2019
Local i := 0
//Array para tratamento de gatilho dos campos adicionados:
Local aGatilho := {} 
Local cValid := ""

dbSelectArea("SX3")
SX3->( dbsetorder(2) )

dbSelectArea("SX7")
SX7->( dbsetorder(1) )


For i := 1 To Len(aCampos)

	If SX3->( dbseek(aCampos[i]) )

		If nMvc == 1 //Estrutura do Modelo

			oStruct:AddField( SX3->X3_TITULO  ,; //Titulo do Campo
			                  ""              ,; //ToolTip do Campo
			                  aCampos[i]      ,; //Id do Campo
			                  SX3->X3_TIPO    ,; //Tipo do campo
			                  SX3->X3_TAMANHO ,; //Tamanho do campo
			                  SX3->X3_DECIMAL ,; //Decimal do campo
			                  FwBuildFeature( 1/*STRUCT_FEATURE_VALID*/ , AllTrim( cValToChar( SX3->X3_VALID ) )),; //Valid do Campo
			                  FwBuildFeature( 2/*STRUCT_FEATURE_WHEN*/  , AllTrim( cValToChar( SX3->X3_WHEN ) )) ,; //When do campo
			                  /*aValues*/,; //Lista de valores permitido do campo
			                  UPPER(AllTrim(SX3->X3_OBRIGAT)) == "S",; //Obrigatoriedade do campo
			                  FwBuildFeature( 3/*STRUCT_FEATURE_INIPAD*/, AllTrim( cValToChar( SX3->X3_RELACAO ) ) ) ,; //inicializador do Campo
			                  /*lKey*/        ,; //
			                  /*lNoUpd*/      ,; //
			                  UPPER(AllTrim(SX3->X3_CONTEXT)) == "V" ) //Indica se o campo é virtual

            //Se o campo possui gatilho:
            If AllTrim(Upper(SX3->X3_TRIGGER)) == "S" .And. SX7->( dbseek(aCampos[i]) ) 
               
               Do while AllTrim(Upper(SX7->X7_CAMPO)) == aCampos[i]
				  
				  //Montando a estrutura do gatilho
				  aGatilho := FwStruTrigger( AllTrim(SX7->X7_CAMPO) ,; //Campo Domínio
											 AllTrim(SX7->X7_CDOMIN),; //Campo de Contradomínio;
											 AllTrim(SX7->X7_REGRA) ,; //Regra de Preenchimento;
											 Upper(AllTrim(SX7->X7_SEEK)) == "S",; //Se posicionara ou não antes da execução do gatilhos;
											 AllTrim(SX7->X7_ALIAS) ,; //Alias da tabela a ser posicionada;
    										 SX7->X7_ORDEM          ,; //Ordem da tabela a ser posicionada;
											 AllTrim(SX7->X7_CHAVE) ) //Chave de busca da tabela a ser posicionada;
					
				  //Adicionando gatilho ao campo											  
				  oStruct:AddTrigger( aGatilho[1],; //Nome (ID) do campo de origem
				                      aGatilho[2],; //Nome (ID) do campo de destino
				                      aGatilho[3],; //Bloco de código de validação da execução do gatilho
				                      aGatilho[4] ) //Bloco de código de execução do gatilho
               	  SX7->( dbskip() )

               EndDo
               
			EndIf

		ElseIf nMvc == 2 //Estrutura da View

			oStruct:AddField( aCampos[i]       ,; //Nome do Campo
			                  Alltrim(SX3->X3_ORDEM)             ,; //Ordem do Campo
			                  SX3->X3_TITULO                     ,; //Titulo do Campo
			                  SX3->X3_DESCRIC                    ,; //Descricao do campo
			                  /*aHelp*/                          ,; //Help do Campo
			                  SX3->X3_TIPO                       ,; //Tipo
			                  If(!Empty(SX3->X3_PICTURE) ,SX3->X3_PICTURE ,""),; //Picture do campo
				              /*bPictVar*/                       ,; //PictureVar
				              SX3->X3_F3                         ,; //F3
				              AllTrim(Upper(SX3->X3_VISUAL)) # "V" ,; //Editavel
				              AllTrim(SX3->X3_FOLDER)            ,; //Folder do campo
				              /*cGroup*/                         ,; //Agrupamento do Campo
				              /*aComboValues*/                   ,; //Combo
				              /*nMaxLenCombo*/                   ,; //Tamanho Maximo da maior opção do combo
				              /*cIniBrow*/                       ,; //IniBrowser
				              AllTrim(UPPER(SX3->X3_CONTEXT)) == "V" ,; //Indica se o campo é virtual
				              /*cPictVar*/ )                        // PictureVar
			EndIf

		EndIf

	Next

Return oStruct

/*
Programa   : DEMUCOMMIT
Objetivo   : Ação do botão confirmar
Retorno    : .T.
Autor      : Felipe Sales Martinez
Data/Hora  : 26/09/2011
Obs.       :
*/
Static Function DEMUCOMMIT(oMdl)
Local nVlFob := 0
Local nOperation := oMdl:GetOperation()
 
nVlFob := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_VL_FOB" ) //Valor FOB

//Salva as alterações efetuadas   
FWFormCommit(oMdl)
  
//Salvando campos que nao são tratados em tela:
If nOperation <> MODEL_OPERATION_DELETE
   If ED9->( RECLOCK("ED9",.F.) )
      ED9->ED9_FILIAL := xFilial("ED9")
      ED9->ED9_VALORI := nVlFob
      ED9->(MSUNLOCK())
   EndIf
EndIf

Return .T.

/*
Programa   : VE400ValOK
Objetivo   : Valida a Tela para gravação
Retorno    : Logico
Autor      : Felipe Sales Martinez
Data/Hora  : 29/09/2011
Obs.       :
*/

Static Function VE400ValOK(oMdl)
Local lRet := .T.
Local nOperation := oMdl:GetOperation()

Begin Sequence
    
    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
       lRet := VE400Valid(oMdl) .And. VE400PreparaAto(oMdl)
    EndIf
    
End Sequence
 
Return lRet


/*
Programa   : VE400PreparaAto
Objetivo   : Verificar o que deve ser feito com a comprovação do ato concessorio.
Retorno    : Logico
Autor      : Felipe Sales Martinez
Data/Hora  : 29/09/2011
Obs.       :
*/
Static Function VE400PreparaAto(oMdl)
Local lRet := .T.
Local cAc := "", cSeqSis := "", cMsg :=""
Local nOperation := oMdl:GetOperation()

//Preparando variaveis de flag para vinculação de ato concessorio
lVEPrevia    := .F.  //Sempre falso   
lAcaoVincula := .F.  //Habilita a ação de vinculação/desvincução de ato.
lVincula     := .T.  //.T. ->Vincula / .F. ->Desvincula ato concessorio.
lRevincula   := .F.  //Desvincula o ato anterior e vincula o novo ato.
lVendasExp   := .T.  //Manutenção de Vendas p/ Exportadores

FWModelActive(oMdl) //Ativa o Modelo

cAc     := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_AC" ) //Ato concessorio
cSeqSis := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_SEQSIS" ) //Sequencia do ato

If nOperation == MODEL_OPERATION_INSERT
   If !Empty(cAc) .And. !Empty(cSeqSis)
      lAcaoVincula := lVincula := .T.
      cMsg := STR0002 //"Deseja vincular o Ato Concessorio?"
   EndIf

ElseIf nOperation == MODEL_OPERATION_UPDATE
   
   If ( Empty(cAc) .And. Empty(cSeqSis) ) .And. ( !Empty(ED9->ED9_AC) .And. !Empty(ED9->ED9_SEQSIS) ) //Desvincular
      lAcaoVincula := .T.
      lVincula := .F.
      cMsg := STR0003 //"Deseja desvincular o Ato Concessorio?"
   
   ElseIf ( !Empty(cAc) .And. !Empty(cSeqSis) ) .And. ( Empty(ED9->ED9_AC) .And. Empty(ED9->ED9_SEQSIS) ) //Vincular
      lAcaoVincula := .T.
      lVincula := .T.
      cMsg := STR0002 //"Deseja vincular o Ato Concessorio?"
      
   ElseIf AllTrim(cAc) # AllTrim(ED9->ED9_AC)//Desvincula ato antigo e Vincula novo ato
      lAcaoVincula := .T.
      lRevincula   := .T.
      lVincula := .F.
      cMsg := STR0004 //"Deseja desvincular o antigo Ato Concessorio e vincular o novo o Ato Concessorio?"
   EndIf

ElseIf nOperation == MODEL_OPERATION_DELETE
       lAcaoVincula := !Empty(cAc)
       lVincula := .F.
       cMsg := STR0005 //"Deseja Realmente Excluir o Registro?"
EndIf

lRet := If(!Empty(cMsg) .And. !(Type("lVeAuto") == "L" .And. lVeAuto),MsgYesNo(cMsg,STR0007) , .T.) //## Aviso

Return lRet 

/*
Programa   : VE400VinculaAto
Objetivo   : Vincular e desvicular o ato concessorio e salvar a telaba ED9.
Retorno    : Logico
Autor      : Felipe Sales Martinez
Data/Hora  : 29/09/2011
Obs.       :
*/
Static Function VE400VinculaAto(oMdl)
Local aStruct   := {}
Local aEstDados := {} 
Local aDados    := {}
Local xDado
Local lOk       := .T.
Local i         := 0
Private lMsErroAuto := .F.

// Obtemos a estrutura de dados
aStruct := oMdl:GetModel( "ED9MASTER" ):GetStruct():GetFields()

Begin Transaction 

If lAcaoVincula  .And. !lVincula
   
   //Montando a estrutura do Ato a ser desvinculado:
   For i:= 1 to Len(aStruct)
     xDado := ED9->&(aStruct[i][3])   
     Aadd(aEstDados,{aStruct[i][3] , xDado })
   Next
   
   //Desvinculando o antigo Ato Concessorio   
   MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aEstDados,lVEPrevia,.F.,6)
   
   //tratamento para exeção de vinculação de ato:   
   If lMsErroAuto 
      lOk := .F.
      Break
   EndIf
   
EndIf

//Montando a estrutura do Ato a ser vinculado ou desvinculado:
For i:= 1 to Len(aStruct)
  xDado := oMdl:GetModel():GetValue( "ED9MASTER" ,aStruct[i][3] ) 
  Aadd(aDados,{aStruct[i][3] , xDado })	
Next

//Salvando ED9.... 
DEMUCOMMIT(oMdl)

//Montando a estrutura do Ato a ser vinculado ou desvinculado:
If lAcaoVincula .And. (lVincula .Or. lRevincula)  
   
   //Vinculando ou Desvinculando o antigo Ato Concessorio   
   MSExecAuto({|a,b,c,d| EDCRE400(a,b,c,d)}, aDados,lVEPrevia,.T.,6)
   
   //tratamento para exeção de vinculação de ato:
   If lMsErroAuto 
         lOk := .F.
         
         //Desfaz a transação (rollBack)
         DisarmTransaction()
         
         //Vincula o antigo ato pois ocorreu erro:
         If lRevincula
            MSExecAuto({|a,b,c,d| EDCRE400 (a,b,c,d)}, aEstDados,lVEPrevia,.F.,6)
         EndIf
         
         Break
         
   EndIf

EndIf

End Transaction

If lMsErroAuto .And. ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog()))
   EECVIEW(FormatTxtAuto(MemoRead(NomeAutoLog())))
   FErase(NomeAutoLog())
EndIf

Return lOk


/*
Programa   : VE400ProdAto
Objetivo   : Valida se a relação do produto com o ato esta correta
Retorno    : Logico
Autor      : Felipe Sales Martinez
Data/Hora  : 29/09/2011
Obs.       :
*/
Function VE400ProdAto(oMdl)
Local lRet    := .T.
Local cAc     := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_AC" )
Local cSeqSis := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_SEQSIS" )
Local cProd   := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_PROD" )

Begin Sequence

   ED3->(DbSetOrder(2)) 
   If ED3->(DbSeek(xFilial("ED3") + AvKey(cAc,"ED3_AC") + AvKey(cSeqSis,"ED3_SEQSIS")))
      If !Empty(cProd) .and. AllTrim(cProd) <> AllTrim(ED3->ED3_PROD)
         EasyHelp(STR0006 , STR0007) //##"O produto do Ato Concessório deve ser o mesmo que o informado." # Aviso
         lRet := .F.
      EndIf
   EndIf

End Sequence

Return lRet


/*
Programa   : VE400Valid
Objetivo   : Possui todas as validações necessario para a persistencia da tabela em banco.
Retorno    : Logico
Autor      : Felipe Sales Martinez
Data/Hora  : 29/09/2011
Obs.       :
*/
Static Function VE400Valid(oMdl)
Local lRet    := .T.
Local dDtNota := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_EMISSA" )
Local cAc     := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_AC" )
Local nOperation := oMdl:GetOperation()

Begin Sequence

   //Verificando integridade da chave da tabela
   If nOperation == MODEL_OPERATION_INSERT .And. VE400ExistChave(oMdl)
      lRet := .F.
      Break
   EndIf
   
   //Validando se o ato possui o produto
   If !VE400ProdAto(oMdl)
      lRet := .F.
      Break
   EndIf 

   //Verificando data da nota fiscal
   If !empty(cAc) .and. empty(dDtNota)

      lRet := MsgYesNo(STR0008 ,STR0007) // "As comprovações de anterioridade serão feitas com a data atual do sistema, pois a data da Nota Fiscal não esta preenchida, deseja continuar?" ## Aviso
      Break   
   EndIf
  
   //RRC - 19/06/2012 - Verifica se os campos "ED9_PEDIDO" ou "ED9_CODEXP" estão preenchidos  
   If Empty(M->ED9_PEDIDO) .Or. Empty(M->ED9_CODEXP)
      lRet := .F. 
       EasyHelp(STR0010 ,STR0007) //"Os campos 'NºPedido' e 'Cod. Expo' necessitam de preenchimento.","Aviso"
  EndIf 


End Sequence

Return lRet


/*
Programa   : VE400ExistChave
Objetivo   : Verificar se o registro ja existe.
Retorno    : .T. -> chave existe / .F. ->Chave nao existe 
Autor      : Felipe Sales Martinez
Data/Hora  : 29/09/2011
Obs.       :
*/
Static Function VE400ExistChave(oMdl)
Local lRet := .F.
Local cAc     := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_AC" )
Local cPedido := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_PEDIDO" )
Local cPosica := oMdl:GetModel():GetValue( "ED9MASTER" ,"ED9_POSICA" )

Begin sequence

    ED9->( dbSetOrder(5) )
    If (lRet := ED9->( dbSeek(xFilial("ED9")+cPedido+cPosica+cAc ) ))
       EasyHelp(STR0009 ,STR0007) //##"Nº de pedido, posição e Ato concessorio já informados anteriormente!" # Aviso
    EndIf

End sequence

Return lRet

Static Function FormatTxtAuto(cMensagem)
Local cTexto := ""
Local cAux := ""
Local nPos := 0

Begin Sequence

   cAux := cMensagem
   If Empty(cAux)
      Break
   EndIf
   
   nPos := At(".",cAux)
   Do While nPos > 0
      cTexto += AllTrim(SubStr(cAux,1,nPos)) + CHR(10) + CHR(13)
      cAux := SubStr(cAux,nPos+1,Len(cAux))
      nPos := At(".",cAux)
   EndDo

   If !Empty(cAux)
      cTexto += cAux
   EndIf
   
End Sequence

Return cTexto
