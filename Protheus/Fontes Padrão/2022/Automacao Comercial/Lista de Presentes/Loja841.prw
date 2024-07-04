#INCLUDE "Loja841.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE VISUALIZAR	2
#DEFINE INCLUIR		3
#DEFINE ALTERAR	 	4
#DEFINE EXCLUIR	  	5

Static aAlias			:= {"ME3","MEG"}  // Array das tabelas
Static aLstCmp01		:= {}								//Lista de campos da enchoice
Static aLstCmp01Ob		:= {}								//Lista de campos da enchoice obrigatorios
Static aLstCmp02		:= {}								//Lista de campos da getdados
Static aLstCmp02Ob		:= {}								//Lista de campos da getdados obrigatorios

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA841   บAutor  ณPablo Gollan Carreras บ Data ณ16/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de cadastro de tipos de eventos e seus tipos de atores     บฑฑ
ฑฑบ          ณpossiveis relacionados.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Loja841()

Local bErro			:= {}								//Bloco de codigo para tratamento de erro
Local cErro			:= ""								//Mensagem de erro
Local lErro			:= .F.								//Aponta existencia de erro no processamento
Local lLstPre		:= SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)  // Verifica aplicacao FNC lista
Local lExecuta		:= .T.	// Indica se a funcao pode ser executada

Private cCadastro	:= OemToAnsi(STR0021)           
Private aRotina 	:= MenuDef()

If !lLstPre
	Help('',1,'LISTPREINVLD') //"O recurso de lista de presente nใo estแ ativo ou nใo foi devidamente aplicado e/ou configurado, impossํvel continuar!"
	lExecuta := .F.
Endif

If !AliasInDic("ME3") .and. lExecuta
	Help('',1,'TABELAINVLD',,STR0022,1,0) //"A tabela ME3 nใo pode ser encontrada no dicionแrio de dados!"
	lExecuta := .F.
EndIf

If !AliasInDic("MEG") .and. lExecuta
	Help('',1,'TABELAINVLD',,STR0023,1,0) //"A tabela MEG nใo pode ser encontrada no dicionแrio de dados!"
	lExecuta := .F.
EndIf

//Bloco de tratamento de erro
bErro := ErrorBlock({|e| VerErro(e,@lErro,@cErro)})
//Definicao da MBrowse
DbSelectArea("ME3")
ME3->(DbSetOrder(1))
ME3->(DbGoTop())

Begin Sequence
	If lExecuta
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('ME3')
		oBrowse:SetDescription(OemToAnsi(STR0021))
		oBrowse:Activate()
	EndIf
	Recover
End Sequence

If lErro
	Alert(cErro)
Endif

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Definicao do Modelo de dados.

@author 	Vendas & CRM
@since 		10/08/2012
@version 	11
@return  	oModel - Retorna o model com todo o conteudo dos campos preenchido

*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructME3 	:= FWFormStruct(1,"ME3") 	// Estrutura da tabela ME3
Local oStructMEG 	:= FWFormStruct(1,"MEG") 	// Estrutura da tabela MEG
Local oModel 		:= Nil						// Objeto com o modelo de dados

// Seta a propriedade como nao obrigatoria
oStructMEG:SetProperty("MEG_CODEVE",MODEL_FIELD_OBRIGAT,.F.)

//-----------------------------------------
//Monta o modelo do formulแrio 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA841",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ME3MASTER", Nil/*cOwner*/, oStructME3 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("ME3MASTER"):SetDescription(STR0021) //"Cadastro de Tipos de Eventos"

oModel:AddGrid("MEGDETAIL","ME3MASTER"/*cOwner*/,oStructMEG,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:SetRelation("MEGDETAIL",{{"MEG_FILIAL",'xFilial("MEG")'} , {"MEG_CODEVE","ME3_CODIGO"}}, MEG->(IndexKey(1)))
oModel:GetModel("MEGDETAIL"):SetUniqueLine({"MEG_CODATO"})

Return oModel

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Definicao da Interface do programa.

@author		Vendas & CRM
@version	11
@since 		10/08/2012
@return		oView - Retorna o objeto que representa a interface do programa

*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil																	// Objeto da interface
Local oModel     := FWLoadModel("LOJA841")												// Objeto com o modelo de dados
Local oStructME3 := FWFormStruct(2,"ME3")												// Estrutura da tabela ME3
Local oStructMEG := FWFormStruct(2,"MEG",{|cCampo|AllTrim(cCampo) != "MEG_CODEVE"})	// Estrutura da tabela MEG

//-----------------------------------------
//Monta o modelo da interface do formulแrio
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_ME3" , oStructME3,"ME3MASTER" )
oView:CreateHorizontalBox( "HEADER" , 60 )
oView:SetOwnerView( "VIEW_ME3" , "HEADER" )

oView:AddGrid( "VIEW_MEG" , oStructMEG,"MEGDETAIL" )
oView:CreateHorizontalBox( "ITENS" , 40 )
oView:SetOwnerView( "VIEW_MEG" , "ITENS" )
                
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerErro    บAutor  ณPablo Gollan Carreras บ Data ณ16/02/11     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento de erro                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerErro(e,lErro,cErro)

Local lRet 		:= .F.		//Retorno

Default e       := 0        // objeto
Default lErro	:= .T.		// retorno do erro
Default cErro	:= ""		// mensagem do erro

If e:Gencode > 0  
	If InTransaction()
		cErro := STR0008 //"Houve um erro no processamento de gravacao : "
	Else
		cErro := STR0009 //"Houve um erro no levantamento de registros : "
	Endif
    cErro += STR0010 + e:Description + CHR(13) + CHR(10)  //"Descri็ใo : "
    cErro += e:ErrorStack
    lErro := .T.
	lRet := .T.
	Break
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja841TOKบAutor  ณPablo Gollan Carreras บ Data ณ16/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao da GetDados                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Mensagem de alerta                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Loja841TOK(lHelp)

Local lRet				:= .T.		// retorno da funcao
Local ni               	:= 0		// variavel para contagem no for
Local nLinhas			:= 0		// contagem de linhas da tabela

Default lHelp			:= .T. 		// retorno do help

nLinhas := 0
For ni := 1 to Len(aCols)
	If !aCols[ni,Len(aCols[ni])]
		If !Loja841LOK(ni)
			lRet := !lRet
			Exit
		Else
			nLinhas++
		Endif
	Endif
Next ni
If lRet
	If nLinhas == 0
		If lHelp
			Help(" ",1,"NVAZIO",,STR0011,4,0) //"Lista de tipos de atores"
		Endif
		lRet := !lRet
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja841LOKบAutor  ณPablo Gollan Carreras บ Data ณ16/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao de linha da getdados                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Linha atual                                            บฑฑ
ฑฑบ          ณExp02[L] : Apresentar help                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Loja841LOK(nLinha,lHelp)

Local lRet			:= .T.		// retorno da funcao
Local ni            := 0		// contagem do for
Local nPosCmpChv	:= aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "MEG_CODATO"})  // posicionamento na tabela MEG do campo

Default nLinha		:= n		// numero de linhas na tabela
Default lHelp		:= .T.		// retorno do help

If !aCols[nLinha][Len(aHeader) + 1]
	//Validar campos obrigatorios
	For ni := 1 to Len(aCols[nLinha]) - 1
		If aScan(aLstCmp02Ob,{|x| AllTrim(Upper(x)) == AllTrim(Upper(aHeader[ni][2]))}) > 0 .AND. Empty(aCols[nLinha][ni])
			If lHelp
				Help(" ",1,"OBRIGAT",,RetTitle(aHeader[ni][2]),4,0)
				lRet := !lRet
				Exit
			Endif
		Else
		Endif
	Next ni
	//Validar registros duplicados ou codigo de supervisor igual ao usuario
	If lRet
		For ni := 1 to Len(aCols)
			If !aCols[ni][Len(aHeader) + 1] .AND. ni # nLinha .AND. AllTrim(aCols[ni][nPosCmpChv]) == AllTrim(aCols[nLinha][nPosCmpChv])
				If lHelp
					Help( " ",1,"JAGRAVADO")
				Endif
				lRet := !lRet
				Exit
			Endif
		Next ni
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja841ETOKบAutor  ณPablo Gollan Carreras บ Data ณ16/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao total, da enchoice e da getdados            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Loja841ETOK(lHelp)

Local lRet				:= .T.		//retorno da funcao
Local ni				:= 0		// contagem do for

Default lHelp			:= .T.		// retorno do help

For ni := 1 to Len(aLstCmp01Ob)
	If Empty(M->&(aLstCmp01Ob[ni]))
		If lHelp
			Help(" ",1,"OBRIGAT",,RetTitle(aHeader[nPosTaxa][2]),4)
		Endif
		lRet := !lRet
		Exit
	Endif
Next ni

//Fazer validacao das linhas
If lRet
	lRet := Loja841TOK()
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณPablo Gollan Carreras บ Data ณ16/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para definicao de menu da MBrowse                          บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

Local aRot				:= {}		// array com as rotinas a serem executadas

ADD OPTION aRot TITLE STR0013 ACTION "PesqBrw"                                          OPERATION 0                                                                                                     ACCESS 0 //"Pesquisar"
ADD OPTION aRot TITLE STR0014 ACTION "VIEWDEF.LOJA841"     OPERATION MODEL_OPERATION_VIEW         ACCESS 0 //"Visualizar"
ADD OPTION aRot TITLE STR0015 ACTION "VIEWDEF.LOJA841"     OPERATION MODEL_OPERATION_INSERT      ACCESS 0 //"Incluir"
ADD OPTION aRot TITLE STR0016 ACTION "VIEWDEF.LOJA841"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRot TITLE STR0017 ACTION "VIEWDEF.LOJA841"     OPERATION MODEL_OPERATION_DELETE     ACCESS 0 //"Excluir"

Return aRot