#INCLUDE "plsa3X.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'  
#include "PLSMGER.CH" 
#include "TOPCONN.CH"

#DEFINE PLS_MODELO_ITENS "VIEWDEF.PLSA3X"
#DEFINE PLS_ALIAS_ITENS  "B1L"
#DEFINE PLS_TITULO 		 STR0001 //"Faixa etária da tabela de reembolso patronal"
#DEFINE PLS_CORLIN 		 "#D6E4EA"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ MenuDef ³ Autor ³ Totvs                  ³ Data ³ 16.02.11 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ MenuDef													  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
PRIVATE aRotina := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Opcoes de menu															 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AaDd( aRotina, { STR0002, 	PLS_MODELO_ITENS, 0, K_Visualizar } )  //"Visualizar"
AaDd( aRotina, { STR0003, 	PLS_MODELO_ITENS, 0, K_Incluir} )  //"Incluir"
AaDd( aRotina, { STR0004, 	PLS_MODELO_ITENS, 0, K_Alterar} )  //"Alterar"
AaDd( aRotina, { STR0005, 	PLS_MODELO_ITENS, 0, K_Excluir} )  //"Excluir"
AaDd( aRotina, { STR0006, "PLS3XEXCP", 0, 8} )  //"Excluir Todos"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB1L := FWFormStruct( 1, 'B1L', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   := MPFormModel():New('PLSA3XMA', /*bPreValidacao*/, {|oX|ValDtB1L(oX)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B1LDETAIL', /*cOwner*/, oStruB1L, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0007)  //"Faixa Salarial"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B1LDETAIL' ):SetDescription(STR0007) //"Faixa Salarial"

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB1L := FWFormStruct( 2, 'B1L' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA3X' )

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B1L', oStruB1L, 'B1LDETAIL' )  

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B1L', 'SUPERIOR' )

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ValDtBC5    ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida data na digitacao da tabela de preco				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS3XEXCP()

Local cSql      := ""
Local lRet		:= .T.
Local aArea		:= GetArea()

If MsgYesNo(STR0008) //"Deseja realmente excluir todas as faixas etárias da faixa salárial selecionada ?"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os itens da tabela de preço.										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := " SELECT R_E_C_N_O_ REGISTRO FROM "+RetSQLName("B1L")+" "
	cSql += " WHERE B1L_FILIAL = '"+xFilial("B1L")+"'"//Filial
	cSql += "   AND B1L_CODOPE = '"+Alltrim(B1J->B1J_CODOPE)+"'"//Operadora
	cSql += "   AND B1L_CODTAB = '"+Alltrim(B1J->B1J_CODIGO)+"'"//Tabela
	cSql += "   AND B1L_CDFXSL = '"+Alltrim(B1J->B1J_CODFAI)+"'"//Tabela	
	cSql += "   AND D_E_L_E_T_ <> '*' "
	PlsQuery(cSql,'Trb3X')
	
	While !Trb3x->( Eof() )                                
		B1L->( dbGoto(Trb3X->REGISTRO) )
		If !B1L->( Eof() )
			B1L->( Reclock("B1L", .F.) )
				B1L->( dbDelete() )
			B1L->( MsUnlock() )
		Endif
		
		Trb3X->( dbSkip() )
	Enddo
	
	Trb3X->( dbCloseArea() )
EndIf

// Restaura area.
RestArea(aArea)
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA106A  ºAutor  ³Microsiga           º Data ³  05/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldB1L()
Local lRet := .T.

If !Empty(M->B23_CDPAD1) .and. !Empty(M->B23_CDPRO1) .and. !Empty(M->B23_CDPAD2) .and. !Empty(M->B23_CDPRO2)
	If M->B23_CDPAD1+M->B23_CDPRO1 > M->B23_CDPAD2+M->B23_CDPRO2
		Help(" ",1,'PLSA112G')
		lRet := .F.
	Endif
Endif

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ValDtBC5    ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida data na digitacao da tabela de preco				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValDtB1L(oModel)

Local lRet := .T.
Local cSql := ""   

If oModel:nOperation <> 3 .And. oModel:nOperation <> 4 //Valida apenas inclusao e alteracao
	Return .T.
EndIf	

If oModel:GetValue("B1LDETAIL","B1L_IDAFIN") < oModel:GetValue("B1LDETAIL","B1L_IDAINI")
	Help( ,, 'HELP',,STR0009, 1, 0) //"A idade final deve ser maior ou igual à idade inicial."
	Return  .F.
EndIf
                       
cSql := "SELECT B1L_CODFAI FROM "+RetSqlName("B1L")+" Where B1L_FILIAL = '"+xFilial('B1L')+"' "
cSql += "AND B1L_CODOPE = '"+B1J->B1J_CODOPE+"' "
cSql += "AND B1L_CODTAB = '"+B1J->B1J_CODIGO+"' "
cSql += "AND B1L_CDFXSL = '"+B1J->B1J_CODFAI+"' "

If Empty(oModel:GetValue("B1LDETAIL","B1L_IDAINI")) //Validacao de Idade
	cSql += "AND B1L_IDAINI <= "+CValToChar(oModel:GetValue("B1LDETAIL","B1L_IDAFIN"))+" "
Else
	cSql += "AND ((B1L_IDAINI <= "	+ CValToChar(oModel:GetValue("B1LDETAIL","B1L_IDAFIN")) + " AND B1L_IDAFIN >= " + CValToChar(oModel:GetValue("B1LDETAIL","B1L_IDAINI")) + ") "
	cSql += "OR (B1L_IDAFIN >= "	+ CValToChar(oModel:GetValue("B1LDETAIL","B1L_IDAINI")) + " AND B1L_IDAINI <= " + CValToChar(oModel:GetValue("B1LDETAIL","B1L_IDAFIN")) + ")) "
EndIf

//Validacao de Vigencia
If !Empty(oModel:GetValue("B1LDETAIL","B1L_VIGINI")) .And. !Empty(oModel:GetValue("B1LDETAIL","B1L_VIGFIN"))

	If oModel:GetValue("B1LDETAIL","B1L_VIGFIN") < oModel:GetValue("B1LDETAIL","B1L_VIGINI")
		Help( ,, 'HELP',,STR0010, 1, 0) //"A vigência final deve ser maior ou igual à vigência inicial."
		Return  .F.
	EndIf
	cSql += "AND ( B1L_VIGINI = ' ' AND B1L_VIGFIN = ' ' "
	cSql += "OR (B1L_VIGINI <= '"	+ DToS(oModel:GetValue("B1LDETAIL","B1L_VIGFIN")) + "' AND B1L_VIGFIN = ' ' ) "
	cSql += "OR (B1L_VIGFIN >= '"	+ DToS(oModel:GetValue("B1LDETAIL","B1L_VIGINI")) + "' AND B1L_VIGINI = ' ' ) "
	cSql += "OR (B1L_VIGINI <= '"	+ DToS(oModel:GetValue("B1LDETAIL","B1L_VIGFIN")) + "' AND B1L_VIGFIN >= '" + DToS(oModel:GetValue("B1LDETAIL","B1L_VIGINI")) + "') "
	cSql += "OR (B1L_VIGFIN >= '"	+ DToS(oModel:GetValue("B1LDETAIL","B1L_VIGINI")) + "' AND B1L_VIGINI <= '" + DToS(oModel:GetValue("B1LDETAIL","B1L_VIGFIN")) + "') ) "

ElseIf !Empty(oModel:GetValue("B1LDETAIL","B1L_VIGFIN"))

	cSql += "AND ( B1L_VIGINI = ' ' "
	cSql += "OR B1L_VIGINI <= '"+DToS(oModel:GetValue("B1LDETAIL","B1L_VIGFIN"))+"') "

ElseIf !Empty(oModel:GetValue("B1LDETAIL","B1L_VIGINI"))

	cSql += "AND ( B1L_VIGFIN = ' ' "
	cSql += "OR B1L_VIGFIN >= '"+DToS(oModel:GetValue("B1LDETAIL","B1L_VIGINI"))+"') "

EndIf

If oModel:nOperation == 4 // Na alteracao desconsidera o registro que esta sendo alterado
	cSql += "AND B1L_CODFAI <> '" + oModel:GetValue("B1LDETAIL","B1L_CODFAI") + "' "
EndIf

cSql += "AND D_E_L_E_T_ = ' ' "
                                       
cSQL := ChangeQuery(cSQL)
TCQUERY cSQL New ALIAS "TrbB1L"

If !TrbB1L->( Eof() )		
	Help( ,, 'HELP',,STR0011 +Chr(10)+Chr(13)+ STR0012 + TrbB1L->B1L_CODFAI, 1, 0) //"As informações digitadas conflitam com uma(ou mais) faixa(s) já registrada(s)." //"Código da Faixa: "
	lRet :=  .F.
Endif

// Encerra area de trabalho.
TrbB1L->( dbCloseArea() )
                            
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ValDtBC5    ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida data na digitacao da tabela de preco				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WhenB1L(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC )
Local lRet		:= .T.
Local aArea 	:= GetArea()

If NOPTION <> 3
	lRet := oB1L:BEFOREEXECUTE(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a tabela esta vinculada a alguma RDA.								+
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf B1J->( Eof() ) .or. B1J->( RecCount() ) == 0
	Help(" ",1,'PLSA106D')
	lRet := .F.
	
Elseif Empty(B1J->B1J_CODOPE) .or. Empty(B1J->B1J_CODIGO)
	Help(" ",1,'PLSA106D')
	lRet := .F.
	
Endif
	
// Restaura area.
RestArea(aArea)
Return(lRet)