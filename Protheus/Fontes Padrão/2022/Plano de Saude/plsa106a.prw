#INCLUDE "plsa106a.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'  
#include "PLSMGER.CH" 

#DEFINE PLS_MODELO_ITENS "VIEWDEF.PLSA106A"
#DEFINE PLS_ALIAS_ITENS  "B23"
#DEFINE PLS_TITULO 		 STR0001 //"Tabela de Preços para Valorização"
#DEFINE PLS_CORLIN 		 "#D6E4EA"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
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
AaDd( aRotina, { STR0002, 	PLS_MODELO_ITENS, 0, K_Visualizar } ) // //"Visualizar"
AaDd( aRotina, { STR0003, 	PLS_MODELO_ITENS, 0, K_Incluir} ) // //"Incluir"
AaDd( aRotina, { STR0004, 	PLS_MODELO_ITENS, 0, K_Alterar} ) // //"Alterar"
AaDd( aRotina, { STR0005, 	PLS_MODELO_ITENS, 0, K_Excluir} ) // //"Excluir"
AaDd( aRotina, { STR0006, "PLS106EXCP", 0, 8} ) // //"Excluir Todos"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB23 := FWFormStruct( 1, 'B23', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   := MPFormModel():New('PLSA106MA', /*bPreValidacao*/, {|oX|ValDtB23(oX)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B23DETAIL', /*cOwner*/, oStruB23, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0007) //"Procedimentos da Tabela de Preços"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B23DETAIL' ):SetDescription(STR0007) //"Procedimentos da Tabela de Preços"

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB23 := FWFormStruct( 2, 'B23' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA106A' )

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B23', oStruB23, 'B23DETAIL' )  

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B23', 'SUPERIOR' )

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
Function PLS106EXCP()

Local cSql      := ""
Local lRet		:= .T.
Local aArea		:= GetArea()

If MsgYesNo(STR0008) //"Deseja realmente excluir todos os procedimentos dessa Tabela de Preços ?"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os itens da tabela de preço.										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := " SELECT R_E_C_N_O_ REGISTRO FROM "+RetSQLName("B23")+" "
	cSql += " WHERE B23_FILIAL = '"+xFilial("B23")+"'"//Filial
	cSql += "   AND B23_CODINT = '"+Alltrim(B22->B22_CODINT)+"'"//Operadora
	cSql += "   AND B23_CODTAB = '"+Alltrim(B22->B22_CODTAB)+"'"//Tabela
	cSql += "   AND D_E_L_E_T_ <> '*' "
	PlsQuery(cSql,'Trb106')
	
	While !Trb106->( Eof() )                                
		B23->( dbGoto(Trb106->REGISTRO) )
		If !B23->( Eof() )
			B23->( Reclock("B23", .F.) )
				B23->( dbDelete() )
			B23->( MsUnlock() )
		Endif
		
		Trb106->( dbSkip() )
	Enddo
	
	Trb106->( dbCloseArea() )
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
Function PlsVldB23(cCodPad,cCodPro)
local lRet := .T.
default cCodPad := ''
default cCodPro := ''

if (!empty(cCodPro) .and. 'Z' $ upper(cCodPro)) .or. (!empty(cCodPad) .and. 'Z' $ upper(cCodPad))
	return lRet
endIf  

if readVar() <> "M->B23_CDPRO1" .and. readVar() <> "M->B23_CDPRO2" 
	lRet := !vazio() .and. existCpo("BR4",cCodPad,1)
else 
	lRet := vazio() .or. existCpo("BR8",cCodPad+cCodPro,1) .and. PLSGATNIV(cCodPad,cCodPro,"B23")
endIf	  
 
if lRet .and. !empty(M->B23_CDPAD1) .and. !empty(M->B23_CDPRO1) .and. !empty(M->B23_CDPAD2) .and. !empty(M->B23_CDPRO2)
	if M->B23_CDPAD1+M->B23_CDPRO1 > M->B23_CDPAD2+M->B23_CDPRO2
		Help(" ",1,'PLSA112G')
		lRet := .f.
	endIf
endIf

return(lRet)

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
Static Function ValDtB23(oModel)
Local lRet		:= .T.
Local nOperation:= oModel:GetOperation()
Local aArea 	:= GetArea()
LOCAL cSql		:= ""
LOCAL aProcs	:= {}
LOCAL nFor 		:= ""
LOCAL cProIniLi	:= ""
LOCAL cProFimLi	:= ""
LOCAL cProIni	:= ""
LOCAL cProFim	:= ""

if empty(M->B23_CDTBUC) .and. empty(M->B23_CDPTAN) .and. empty(M->B23_CDTBFM) .and. empty(M->B23_CDTBUS) .and. empty(M->B23_CODTDE) .and. ( M->B23_VRRPP + M->B23_VRPPP + M->B23_VRRCO + M->B23_VRPCO ) == 0 
    Help( ,, 'HELP',, 'Não é possível confirmar esta parametrização! TDE ou Tabela de Preço ou Valores devem ser informados.', 1, 0) 
    lRet := .F.
endIf

if lRet

    If nOperation == 3

        //³ Valida se ja existe tabela com a mesma faixa de procedimentos/regime de atendimento/finalidade de atendimento.
        cSql := "SELECT * FROM "+RetSqlName("B23")+" Where B23_FILIAL = '"+xFilial("B23")+"' "
        cSql += "AND B23_CODINT = '"+M->B23_CODINT+"' "
        cSql += "AND B23_CODTAB = '"+M->B23_CODTAB+"' "
        cSql += "AND B23_CDPAD1 = '"+M->B23_CDPAD1+"' "
        cSql += "AND B23_CDPRO1 = '"+M->B23_CDPRO1+"' "
        cSql += "AND B23_CDPAD2 = '"+M->B23_CDPAD2+"' "
        cSql += "AND B23_CDPRO2 = '"+M->B23_CDPRO2+"' "
        cSql += "AND B23_REGATE = '"+M->B23_REGATE+"' "
        cSql += "AND B23_FINATE = '"+M->B23_FINATE+"' "
        cSql += "AND D_E_L_E_T_ = ' '"
        PlsQuery(cSql,'Trb106')

        If B23->(FieldPos("B23_VIGINI")) > 0	

            While !TRB106->(Eof())
                TRB106->( dbEval({||Aadd(aProcs, {TRB106->B23_VIGINI,TRB106->B23_VIGFIM})} ) )
                
                TRB106->(dbSkip())
            Enddo	
        
            If Len(aProcs) > 0			
                lRet := PLSVLDVIG("B23",nOperation,nil,"B23_VIGINI","B23_VIGFIM",nil,.T.,aProcs)
            Endif
            
            // Por lógica, se esta validação deu certo, precisa retornar porque não tem mais nada para ser verificado.
            If lRet
                Trb106->( dbCloseArea() )
                Return lRet
            Endif	

        Else
            If !TRB106->( Eof() ) .and. TRB106->CONTADOR > 0
                Help(" ",1,'PLSA106C')
                lRet := .F.
            Endif	
        Endif

        TRB106->( dbCloseArea() )
    Endif

    If (nOperation == 3 .or. nOperation == 4) .and. lRet

        //³ Valida se ja existe faixa de procedimentos que contemple o intervalo que esta sendo digitado/regime de atendimento/finalidade de atendimento.
        aProcs  := {}
        cProIni	:= M->B23_CDPAD1 + M->B23_CDPRO1
        cProFim := M->B23_CDPAD2 + M->B23_CDPRO2
        
        cSql := "SELECT * FROM "+RetSqlName("B23")+" Where B23_FILIAL = '"+xFilial("B23")+"' "
        cSql += "AND B23_CODINT = '"+M->B23_CODINT+"' "
        cSql += "AND B23_CODTAB = '"+M->B23_CODTAB+"' "
        cSql += "AND B23_REGATE = '"+M->B23_REGATE+"' "
        cSql += "AND B23_FINATE = '"+M->B23_FINATE+"' "
        cSql += "AND B23_VIGINI >= '"+DTOS(M->B23_VIGINI)+"' "
        cSql += "AND B23_VIGFIM <= '"+DTOS(M->B23_VIGFIM)+"' "
        
        If nOperation == 4
            cSql += "AND R_E_C_N_O_ <> "+Alltrim(Str(B23->(Recno())))"
        Endif
        
        cSql += " AND D_E_L_E_T_ = ' '"
        PlsQuery(cSql,'Trb106')
        
        TRB106->( dbEval({||Aadd(aProcs, {TRB106->B23_CDPAD1+TRB106->B23_CDPRO1, TRB106->B23_CDPAD2+TRB106->B23_CDPRO2, TRB106->B23_VIGINI})} ) )	
        
        
        For nFor := 1 To Len(aProcs) 

            // Recupero as informacoes das outras linhas
            cProIniLi	:= aProcs[nFor][1]
            cProFimLi	:= aProcs[nFor][2]
            dDatIniLi   := aProcs[nFor][3]
                                                                        
            // Valida o intevalo de procedimentos
            If 	( (cProIni >= cProIniLi .And. cProIni <= cProFimLi) .Or.;
                (cProFim >= cProIniLi .And. cProFim <= cProFimLi ) ) .AND. ;
                ( dDatIniLi <= M->B23_VIGFIM .OR. Empty(M->B23_VIGFIM) ) //Adicionando esse tratamento pq caso a vigência fincal do outro B23 esteja aberta, ele vem na query.
                                
                Help( ,, 'HELP',, STR0009, 1, 0) //"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo. Verifique os eventos das faixas!"
                lRet := .F.
                exit 
            EndIf

            If  ( (cProIniLi >= cProIni .And. cProIniLi <= cProFim) .Or.;
                (cProFimLi >= cProIni .And. cProFimLi <= cProFim) )  .AND. ;
                ( dDatIniLi <= M->B23_VIGFIM .OR. Empty(M->B23_VIGFIM) ) //Adicionando esse tratamento pq caso a vigência fincal do outro B23 esteja aberta, ele vem na query.
                
                Help( ,, 'HELP',, STR0009, 1, 0) //"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo. Verifique os eventos das faixas!"
                lRet := .F.
                exit 
            EndIf

        Next

        TRB106->( dbCloseArea() )
        
    Endif

    // Restaura area.
    RestArea(aArea)

endIf

Return(lRet)	

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
Function WhenB23(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)
Local lRet		:= .T.
Local aArea 	:= GetArea()

If NOPTION <> 3
	lRet := OB23:BEFOREEXECUTE(CFUNCTION,NOPTION,NVERIFY,CTITLE,NREALOPC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a tabela esta vinculada a alguma RDA.								+
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf B22->( Eof() ) .or. B22->( RecCount() ) == 0
	Help(" ",1,'PLSA106D')
	lRet := .F.
	
Elseif Empty(B22->B22_CODINT	) .or. Empty(B22->B22_CODTAB)
	Help(" ",1,'PLSA106D')
	lRet := .F.
	
Endif
	
// Restaura area.
RestArea(aArea)
Return(lRet)	


//-------------------------------------------------------------------
/*/{Protheus.doc} plsa106a
Função com o nome do fonte, para considerar no MILE
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
function plsa106a()
return
