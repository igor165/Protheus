#INCLUDE "LOJA840.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"

Static lR7		:= GetRpoRelease("R7")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA840    บAutor  ณVendas Clientes       บ Data ณ14/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para cadastro de tipos de atores da lista de presentes ME5 บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA840()
Local lExecuta			:= .T.	// Indica se a funcao pode ser executada
Local lLstPre			:= SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)   // Verifica aplicacao da FNC de Lista de Eventos

Private cCadastro		:= OemToAnsi(STR0009)      /// Nome do Modulo
Private aRotina 		:= MenuDef()    /// Rotina de manipulacao dos dados

If !lLstPre
	Help('',1,'LISTPREINVLD') /// O recurso de lista de presente nใo estแ ativo ou nใo foi devidamente aplicado e/ou configurado, impossํvel continuar!
	lExecuta := .F.
Endif

If !AliasInDic("ME5")
	Help('',1,'TABELAINVLD',,STR0001,1,0) //"A tabela ME5 nใo pode ser encontrada no dicionแrio de dados!"
	lExecuta := .F.
Endif

If lR7 .and. lExecuta
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ME5')
	oBrowse:SetDescription(OemToAnsi(STR0009))
	oBrowse:Activate()	
ElseIf lExecuta
	mBrowse(6,1,22,75,"ME5")
EndIf

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
Local oStructME5 := FWFormStruct(1,"ME5")	// Estrutura da tabela ME5
Local oModel := Nil							// Objeto do modelo de dados

//-----------------------------------------
//Monta o modelo do formulแrio 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA840",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ME5MASTER", Nil/*cOwner*/, oStructME5 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("ME5MASTER"):SetDescription(STR0009)

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
Local oView  		:= Nil						// Objeto da interface
Local oModel  		:= FWLoadModel("LOJA840")	// Objeto do modelo de dados
Local oStructME5 	:= FWFormStruct(2,"ME5")	// Estrutura da tabela ME5

//-----------------------------------------
//Monta o modelo da interface do formulแrio
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "ME5MASTER" , oStructME5 )
oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "ME5MASTER" , "HEADER" )
                
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj840Exc   บAutor  ณVendas Clientes       บ Data ณ14/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para exclusao                                              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj840Exc()
Local aParam			:= {{|| Nil},{|| Lj840VldExc(.T.)},{|| Nil},{|| Nil}}   // array com o bloco para execucao 

AxDeleta("ME5",ME5->(Recno()),aScan(aRotina,{|x| x[2] == "Lj840Exc"}),,,,aParam)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj840VldExcบAutor  ณVendas Clientes       บ Data ณ14/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validar a exclusao de tipo de atores                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[L] : Apresentar mensagem de alerta                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L] : Determinar se o registro pode ser excluido              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj840VldExc(lMens)

Local lRet				:= .T.      /// Variavel logica - retorno da funcao
Local cFiltro			:= ""       /// variavel para filtro da tabela quando for CodBase
Local aArea				:= {}       /// array que armazena as tabelas usadas na funcao
Local aTabs				:= {{"MEE","MEE_CODATO"},{"MEG","MEG_CODATO"}}   /// array com campos das tabelas para o filtro
Local ni				:= 0        /// campo para contagem no For
Local cChave			:= ""       /// chave para procura
Local cAlias02			:= ""       /// Alias para busca de dados
Local cAliasTMP			:= GetNextAlias()  /// Alias temporario para o select
Local cQry				:= ""              /// variavel para select
Local cMens				:= STR0002        //"Este registro nใo pode ser apagado pois possui registros associados com a tabela "

Default lMens			:= .F.            // Para impressao na tela de mensagem

If Select("ME5") == 0 .OR. ME5->(Eof()) .OR. Empty(ME5->ME5_CODIGO)
	lRet := !lRet
Endif
CursorWait()
For ni := 1 to Len(aTabs)
	aAdd(aArea,(aTabs[ni][1])->(GetArea()))
Next ni
cChave := ME5->ME5_CODIGO
#IFNDEF TOP
	For ni := 1 to Len(aTabs)
		cAlias02 := aTabs[ni][1]
		cFiltro := aTabs[ni][2] + " == '" + cChave + "'"
		DbSelectArea(cAlias02)
		(cAlias02)->(DbSetOrder(1))
		(cAlias02)->(DbSetFilter({|| &cFiltro},cFiltro))
		(cAlias02)->(DbGoTop())
		If !(cAlias02)->(Eof())
			lRet := !lRet
			If lMens
				MsgAlert(cMens + cAlias02) 
			Endif
			Exit
		Endif
		(cAlias02)->(DbClearFilter())
	Next ni
#ELSE
	For ni := 1 to Len(aTabs)
		cAlias02 := aTabs[ni][1]
		cQry := "SELECT COUNT(" + cAlias02 + "." + aTabs[ni][2] + ") AS TOTAL "
		cQry += "FROM " + RetSQLName(cAlias02) + " " + cAlias02 + " "
		cQry += "WHERE " + RetSQLDel(cAlias02) + " AND " + cAlias02 + "." + aTabs[ni][2] + " = '" + cChave + "' "
		DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasTMP,.T.,.F.)
		(cAliasTMP)->(DbGoTop())
		If !(cAliasTMP)->(Eof())
			If (cAliasTMP)->(FieldGet(1)) > 0
				lRet := !lRet
				If lMens
					MsgAlert(cMens + cAlias02) 
				Endif
				Exit
			Endif
		Endif
		FechaArqT(cAliasTMP)
	Next ni
#ENDIF
CursorArrow()
aEval(aArea,{|x| RestArea(x)})

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef    บAutor  ณVendas Clientes       บ Data ณ14/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao de menu                                                 บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRotina[A] : Array com funcoes                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

Local aRotina := {}    /// array com as rotinas a serem executadas

If lR7
	ADD OPTION aRotina TITLE STR0004 ACTION "PesqBrw"			OPERATION 0                                                                                                     ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA840"	OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA840"	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.LOJA840"	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.LOJA840" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"
Else
	aAdd(aRotina,{STR0004, "AxPesqui" 						, 0, 1 , ,.F.})	//Pesquisar
	aAdd(aRotina,{STR0005, "AxVisual"						, 0, 2})			//"Visualizar"
	aAdd(aRotina,{STR0006, "AxInclui"						, 0, 3})			//"Incluir"
	aAdd(aRotina,{STR0007, "AxAltera"						, 0, 4})			//"Alterar"
	aAdd(aRotina,{STR0008, "Lj840Exc"						, 0, 5})			//"Excluir"
EndIf

Return(aRotina)

