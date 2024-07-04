#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "plsa955.ch"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "hat-actions.ch"

//Define
#define TOT_DENTES 70
#define TOT_DENTDE 70 - 38
#define TOT_FACES 5

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³plsa955 ³ Autor ³  Anderson Tomé        ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Vidas                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static nEpochVida := Set(_SET_EPOCH)

function plsa955(lAutoma) 
Local oBrowse
Default lAutoma :=  iif( valtype(lAutoma) <> "L", .f., lAutoma ) 	
Private aRotina    		:= MenuDef(lAutoma)

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Definição da tabela do Browse
oBrowse:SetAlias('BTS')

// Titulo da Browse
oBrowse:SetDescription('Vidas')

oBrowse:setMainProc("PLSA955")


// Ativação da Classe
Iif(!lAutoma, oBrowse:Activate(),"")

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef ³ Autor ³  Anderson Tomé        ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Vidas                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef(lAutoma)
Local aSubMenu	:= {}
Local aRotina 	:= {}	

//Menu da rotina 
ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.PLSA955' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir' 		ACTION 'VIEWDEF.PLSA955' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar' 		ACTION 'VIEWDEF.PLSA955' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir' 		ACTION 'VIEWDEF.PLSA955' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir' 	ACTION 'VIEWDEF.PLSA955' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar' 		ACTION 'VIEWDEF.PLSA955' OPERATION 9 ACCESS 0

If ExistBlock("PL955INC")
   aSubMenu := ExecBlock("PL955INC",.F.,.F.)
   aadd(aRotina,{ aSubMenu[1]	, aSubMenu[2] , 0 , 2 , 0, Nil,Nil,Nil})
Endif

If SuperGetMv("MV_BIOCONF",,.T.) 
	AaDd (ARotina, { STR0024 , If(lAutoma, 'PLSA955BIO(.T.)','PLSA955BIO(.F.)') , 0 , 4 , 0, Nil,Nil,Nil})
EndIf

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ModelDef ³ Autor ³  Anderson Tomé        ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Vidas                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel // Modelo de dados que será construído
Local oStruBTSA := FWFormStruct( 1, 'BTS'/*, { |cCampo| PLSBTSCPA(cCampo) }*/ )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('PLSA955', /*bPreValidacao*/, { || PLSA955POS( oModel ) } , /*bCommit*/ , { || PlSetEpoch(nEpochVida)})

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'BTSMASTER' ,             /*cOwner*/, oStruBTSA ) 

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Cadastro de Vidas' )

// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'BTSMASTER' ):SetDescription( 'Cadastro de Vidas' )

// Executa a Função PlSetEpoch()
oModel:SetVldActivate({ ||PlSetEpoch()} )

// Retorna o Modelo de dados
Return oModel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ViewDef ³ Autor ³  Anderson Tomé        ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Vidas                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ViewDef()
Local oView
Local oModel 	:= FWLoadModel( 'PLSA955' )
Local oStruBTS	:= FWFormStruct( 2, 'BTS', )



// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado na View
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário
oView:AddField( 'VIEW_BTS', oStruBTS, 'BTSMASTER' )



// Criar "box" Principal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA'  , 100 )

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'TELA' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL'  , 100,,, 'PASTAS' )


//Cria botão
oView:AddUserButton('Foto' , "", {|| PLSA955FOTO(oModel)  } )

// Retorna o objeto de View criado
Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA955POS ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valid Bloco Pós do Cadastro de Vidas                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLSA955POS(oModel)

Local oModelBTSA := oModel:GetModel( 'BTSMASTER' )
Local lRet 		:= .T.
Local nOperation:= oModel:GetOperation()
Local cNome  	:= oModelBTSA:GetValue('BTS_NOMUSR')
Local cNasc  	:= oModelBTSA:GetValue('BTS_DATNAS')
Local cEsCiv 	:= oModelBTSA:GetValue('BTS_ESTCIV')
Local lEstCiv	:= !(EmpTy(GetSx3Cache('BTS_ESTCIV', 'X3_OBRIGAT'))) //Caso o estado civil não seja obrigatório, não obrigo a preencher
local lLayGen	:= iif( FwIsInCallStack("PLGRVLWEB"), .t., .f.)

Set(_SET_EPOCH, nEpochVida)

//verifico pois podem estar vindo da inclusão de fotos e commit não valida campos obrigatorios 
If empty(cNome) .Or. empty(cNasc) .Or. (empty(cEsCiv) .AND. lEstCiv)
	Return .F.
Endif

Do case

	// Inclusão
  	Case nOperation == MODEL_OPERATION_INSERT
  		
		If !EMPTY(M->BTS_DRGUSR) .AND. (EMPTY(M->BTS_ORGEM) .OR. EMPTY(M->BTS_RGEST)) 
			
			Help( ,, 'Help',, STR0035, 1, 0 ) //"Cadastro incompleto, é necessário concluir o cadastro referente ao RG (orgão emissor e estado emissor)"
			Return .F.
		EndIf  
		
		lRet := PLSA955IN() .and. PLS955Obg('I')
  
		If lRet .And. GetNewPar("MV_PLSHAT","0") == "1"
			PLHATPedPD(MODEL_OPERATION_INSERT,_persons_inc,"BTS",M->BTS_MATVID)
		EndIf
  	// Exclusão
	case nOperation == MODEL_OPERATION_DELETE 
		lRet := PLSA955EXC()
	
	//Alteração
	Case nOperation == MODEL_OPERATION_UPDATE

		If !EMPTY(M->BTS_DRGUSR) .AND. (EMPTY(M->BTS_ORGEM) .OR. EMPTY(M->BTS_RGEST)) 
			
			Help( ,, 'Help',, STR0035, 1, 0 ) //Cadastro incompleto#É necessário concluir o cadastro referente ao RG (orgão emissor e estado emissor)
			Return .F.
		EndIf   

	   lRet := PLS955Obg('A', lLayGen) .and. PLSA955ALT(lLayGen) 
	   
	OtherWise
		lRet := .T.
EndCase

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA955FOTO ³ Autor ³  Anderson Tomé    ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusão de Foto na Vida                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLSA955FOTO(oModel, lAutoma)
Local lRet 			:= .T.
Local nOperation 	:= iif((!Empty(lAutoma) .And. !lAutoma) .Or. Empty(lAutoma),oModel:GetOperation(),4)
Local oView 		:= iif((!Empty(lAutoma) .And. !lAutoma) .Or. Empty(lAutoma),FWViewActive(),nil)
Local lFoto			:= .F.
Default lAutoma     := .F.


// Verifico se e inclusão ou alteração para não permitir a tentativa de inclusaõ de fotos
If nOperation == 3 .Or. nOperation == 4 
	
	//Caso se cancelada a inclusão volta falso 
	 lFoto:= Iif(!lAutoma,HS_CapFoto(M->BTS_MATVID, oView, "M->BTS_BITMAP",nil),.T.)
	 lRet := lFoto
	 
Else
	// Caso seja só vizualização ou exclusão
	Return lRet 
	
Endif

//Verifico se não foi cancelada ou erro 
If lFoto 

	//Colocando o valor da foto vindo do HSP
	Iif(!lAutoma,oModel:SetValue( "BTSMASTER", "BTS_BITMAP", Alltrim(M->BTS_BITMAP) ), "")
	
	//Refresh do Oview para mostrar a foto
	Iif(!lAutoma,oView:Refresh(),"") 
	
	If  nOperation <> 3  .and. (Iif(!lAutoma,lRet := PLSA955POS(oModel),lRet))
	
		 //Realiza o Commit para a Gravação do model
		Iif(!lAutoma, lRet := FwFormCommit(oModel),lRet := .T.) 
	
	Endif
	
	// Caso o passe pela validação do PLSA955POS e o commit seja correto
	If lRet
	
		//Apresenta Mensagem caso tenha ocorrido certo o Commit
		Iif(!lAutoma,ApMsgInfo( 'Imagem Cadastrada no Beneficiario com sucesso.' ) ,"")
	
	Endif
	
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Plsa955Pic ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Plsa955Pic()
Local cPict

	If !Empty(M->BTS_TIPPES)
 		cPict := PicPes(M->BTS_TIPPES)
 	Else
 		cPict := PicPes("F")
 	EndiF

Return cPict

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA955EXC ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Exclusão e integração GH                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA955EXC()
Local lEspelhar:=GetNewPar("MV_INTBTGB",.F.)
Local lRet :=.T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina de Exclusão dos dados nas Tabelas de Gestão Hospitalar            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetorder(7))
If !BA1->(MsSeek(xFilial("BA1")+BTS->BTS_MATVID))
	If lEspelhar
		DbSelectarea ("GBH")
		GBH->(DbSetOrder(8))
		If GBH->(MsSeek(xFilial("GBH")+BTS->BTS_MATVID))
			iF FS_VldExc(GBH->GBH_CODPAC)//Chama a Validação do HSP verificando se Registro pode ser Sincronizado
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If BBL->(MsSeek(xFilial("BBL")+"PLSA955   "+"BTS"+"GBH"))
					RecLock("GBH", .F.)
					DbDelete()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0029)) //"Arquivo de sincronismo entre BTS x GBH nao esta integro. Verifique!"
					Endif
				Endif
			eLSE
				lRet := .F.
			Endif
		Endif
	Endif
Else
	Help( ,, 'HELP',, STR0033, 1, 0)
	lRet := .F.
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA955IN ³ Autor ³  Anderson Tomé      ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Inclusão e integração GH                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLSA955IN()
Local lEspelhar:=GetNewPar("MV_INTBTGB",.F.)
local lNovGBH:=.F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Antes de Espelhar vou verificar Função  padrão de Validação  do Cadast. paciente		          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lEspelhar
		If  ! Empty(BTS->BTS_MATVID)
			DbSelectarea ("GBH")
			GBH->(DbSetOrder(8))
			lNovGBH := (GBH->(MsSeek(xFilial("GBH")+BTS->BTS_MATVID)))
		Else
			lNovGBH := .T.
		Endif

		If  ! lNovGBH
			DbSelectarea ("BBL")
			BBL->(DbSetOrder(2))
			If 	BBL->(MsSeek(xFilial("BBL")+"PLSA955   "+"BTS"+"GBH"))
				RecLock("GBH", .T.)
				GBH->GBH_FILIAL := xFilial("GBH")
				GBH->GBH_CODPAC := GETSX8NUM("GBH","GBH_CODPAC")
				GBH->GBH_MATVID	:=BTS->BTS_MATVID

				Do Case
					Case BTS->BTS_SEXO  == "1"
						GBH->GBH_SEXO:="0"
					Case BTS->BTS_SEXO == "2"
						GBH->GBH_SEXO:= "1"
				EndCase

				Do Case
					Case BTS->BTS_ESTCIV  == "C"
						GBH->GBH_ESTCIV :="0"
					Case BTS->BTS_ESTCIV == "S"
						GBH->GBH_ESTCIV:= "1"
					Case  BTS->BTS_ESTCIV== "D"
						GBH->GBH_ESTCIV:= "2"
					Case  BTS->BTS_ESTCIV== "M"
						GBH->GBH_ESTCIV:= "3"
					Case  BTS->BTS_ESTCIV== "V"
						GBH->GBH_ESTCIV:= "4"

				EndCase

				Replace GBH->GBH_USRCAD	With cUserName
				Replace GBH->GBH_LOGARQ	With HS_LOGARQ()
				PlsSinc("PLSA955   ","BTS","GBH",.T.)
				MsUnlock()

			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0029)) //"Arquivo de sincronismo entre BTS x GBH nao esta integro. Verifique!"
				Endif
			Endif

		Endif

	Endif

RETURN(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA955Bio ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Biometria                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA955Bio(lAutoma)
Default lAutoma := .F.

	Iif(!lAutoma,PLSBIOMET("BTS",BTS->BTS_MATVID),"")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS955Obg ³ Autor ³  Anderson Tomé      ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS955Obg(cOpcPE,lAutoma)
Local lGrava  := .T.
Local lRet	  := .T.

Default lAutoma := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa P.E. para manter a integridade com o Call Center            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PLS955GV" )
	lGrava := ExecBlock( "PLS955GV", .F., .F., {cOpcPE} )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente inclui se houver integridade com o call center    			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGrava
	If cPaisLoc == "BRA" .And. Type("lPrim260") <> "U" .And. lPrim260 .And. M->BA1_INFANS = "1"
		If 	Empty(M->BTS_CEPUSR) .Or. Empty(M->BTS_ENDERE) .Or. Empty(M->BTS_NR_END) .Or.;
			Empty(M->BTS_BAIRRO) .Or. Empty(M->BTS_MUNICI) .Or. Empty(M->BTS_ESTADO)
			ApMsgAlert(STR0007) //"Preenchimento obrigatorio dos dados do endereco para usuario titular. Preencha os campos !"
			lRet :=  .F.
		Endif

	    If M->BTS_NACION > "20" .and. lRet
	    
	    	If Empty(M->BTS_DRGUSR)
				ApMsgAlert(STR0008) //"Preenchimento obrigatorio do RG usuario titular estrangeiro. Preencha o campo !"
				lRet :=  .F.
			Else
				lRet :=  .T.
			Endif
			
	    ElseIf lRet
			
			lRet :=  .t.
			
		Endif
	Else
		lRet :=  .T.
	Endif

	If M->BTS_IDADE >= GetNewPar("MV_PLSCPFM", 14)
		If  Empty(M->BTS_CPFUSR)
			Help( ,, 'HLPCPF',,STR0031, 1, 0 ) //"Preenchimento obrigatorio do CPF/CNPJ. Preencha o campo !"
			Return .F.				
		Else
			lRet := .T.			
		EndIf
	Endif
	
	If M->BTS_TIPEND == "1" .AND. (Empty(M->BTS_MUNRES) .OR. Alltrim(M->BTS_MUNRES) == '0')
		lRet := .F.
		ApMsgAlert(STR0032)
	EndIf
	

	If cOpcPE == "I" .And. Empty(M->BTS_BITMAP)
		BTS->(ConfirmSx8())
		BTS->(DbSetOrder(1))
		If BTS->(MsSeek(xFilial("BTS")+M->BTS_MATVID))
			lRet := MsgYesNo(STR0025)
		EndIf
	EndIf

Else
	lRet := .F.  
Endif

If lRet .And. SuperGetMV("MV_PLSHOMO",,.F.) .And. cOpcPE == "A"
	PLSAAtuTab("BTS",.F.,M->BTS_MATVID,lAutoma)
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PlsHomoni ³ Autor ³  Anderson Tomé      ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Homonimos                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PlsHomoni(cNomeUsu,cCpfUsu,cCrmUsu,cCnesUsu,cInsEst,cInsMun,dDatNasc,cAlias,cMatvid,Inclui, lAutomato)
Local	cSQL		:=""
Local	nPos		:= 0
Local	cAux		:= ""
Local	aDahomo		:={}
Local	nI			:=0
Local	adados		:={}
Local	aRes		:={}
Local	lRet		:=.t.
Local	lMatv		:=.F.
Local 	aSQL		:= {}
Local lAtuTab		:= .T.
Local lCnpjDupli	:= IIF(GetNewPar("MV_VALCNPJ","1")=="1",.F.,.T.) // 1 = Permite incluir CPF/CNPJ igual | 2 = Não permite incluir CPF/CNPJ igual 
Default cNomeUsu	:=""
Default cCpfUsu		:=""
Default cCrmUsu		:=""
Default cCnesUsu	:=""
Default cInsEst		:=""
Default cInsMun		:=""
Default dDatNasc	:=""
Default cMatvid		:=""
Default lAutomato   := .F.

If Empty(cMatvid)
	lMatv:=.T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica  Atraves do Nome do usuario a possivel Existencia de Homonimos    ³
//³ `Para isto foi utilizado a Sequencia das Tres Primeiras letras do Nome     ³
//³  e Sobrenome do Paciente Retirando do Nome paciente os seguintes pseudonome³
//³  DA/DE/DI/DO/DU/JR/I/II/III/DOS/DAS/E/. 								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lMatv
	While (nPos := AT(" ", UPPER(cNomeUsu) +" ")) > 0 .and. !Empty(cNomeUsu)
		cAux   := Substr(UPPER(cNomeUsu), 1,nPos-1)
		cNomeUsu := UPPER(substr(cNomeUsu,nPos+1,len(cNomeUsu)))
		If !Empty(cAux) .and. !UPPER(cAux) $ "DA/DE/DI/DO/DU/JR/I/II/III/DOS/DAS/E/."
			Aadd(aDahomo,UPPER(Substr(cAux,1,3)))
		Endif
	End
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realizando a Consulta de Possiveis  Homonimos na Tabela BTS Vidas        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BTS_NOMUSR, BTS_DATNAS, BTS_CPFUSR, BTS_NUMECR, BTS_CNESPE, BTS_INSCES, "
cSQL += "BTS_INSCMU, BTS_SIGLCR, BTS_ESTACR, BTS_DTINSC, BTS_SIGCR2, BTS_ESTCR2, BTS_NUMCR2, "
cSQL += "BTS_DTINS2, BTS_MATVID, BTS_NOMRED, BTS_SEXO, BTS_ESTCIV, BTS_TIPPES, BTS_DRGUSR, "
cSQL += "BTS_CEPUSR, BTS_ENDERE, BTS_NR_END, BTS_COMEND, BTS_BAIRRO, BTS_MUNICI, BTS_ESTADO, "
cSQL += "BTS_TELEFO, BTS_DATNAS, BTS_DTINSC, BTS_NOMFAN, BTS_NUMFAX, BTS_PAGWEB, BTS_CODMUN, "
cSQL += "R_E_C_N_O_ Rec FROM " + RetSQLName("BTS") + " WHERE "
cSQL += "BTS_FILIAL = '" + xFilial("BTS") + "' "

If !lMatv
	If len(aDahomo) > 0
		For ni :=1 to len(aDahomo)
			If ni==1
				cSQL += " AND BTS_NOMUSR LIKE '" + AllTrim(aDahomo[ni]) + "%'  "
			Else
				cSQL += " AND BTS_NOMUSR LIKE '%" + AllTrim(aDahomo[ni]) + "%'  "
			Endif
		Next ni
	Endif
	If !Empty(dDatNasc)    // Se não tiver data de Nascimento não é filtrado
		cSQL += " AND BTS_DATNAS = '" + AllTrim(DTOS(dDatNasc)) + "'  "
	Endif
	If !Empty(cCpfUsu)    // Se não tiver Cpf não é filtrado
		aAdd(aSQL, " BTS_CPFUSR = '" + AllTrim(cCpfUsu) + "'  ")
	Endif
	If !Empty(cCrmUsu)    // Se não tiver Crm não é filtrado
		aAdd(aSQL, " BTS_NUMECR = '" + AllTrim(cCrmUsu) + "'  ")
	Endif
	If !Empty(cCnesUsu)    // Se não tiver CNES não é filtrado
		aAdd(aSQL, " BTS_CNESPE = '" + AllTrim(cCnesUsu) + "'  ")
	Endif
	If !Empty(cInsEst)    // Se não tiver InsEstadual não é filtrado
		aAdd(aSQL, " BTS_INSCES = '" + AllTrim(cInsEst) + "'  ")
	Endif
	If !Empty(cInsMun)    // Se não tiver InscMuni não é filtrado
		aAdd(aSQL, " BTS_INSCMU = '" + AllTrim(cInsMun) + "'   ")
	Endif
	If Len(aSQL) > 0
		cSQL += "AND ("
		For nI := 1 to Len(aSQL)
			cSQL += aSQL[nI]
			If nI < Len(aSQL)
				cSQL += " OR "
			EndIf
		Next nI
		cSQL += ")"
	EndIf
Else
	cSQL += " AND BTS_MATVID = '" + AllTrim(cMatvid) + "'  "
Endif
cSQL += " AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBTS",.F.,.T.)

If ! TrbBTS->(Eof())

	aadd(adados,{TrbBTS->BTS_NOMUSR ,TrbBTS->BTS_DATNAS ,TrbBTS->BTS_CPFUSR  ,TrbBTS->BTS_NUMECR ,;
				 TrbBTS->BTS_CNESPE ,TrbBTS->BTS_INSCES ,TrbBTS->BTS_INSCMU })

	cMatvid := TrbBTS->BTS_MATVID
Endif
TrbBTS->(DbCloseArea())


If lMatv
	lAtuTab := PLSAAtuTab(cAlias,Inclui,cMatvid)
	Return(lAtuTab)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe em Tela possiveis Homonimos                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(adados) 

	If !lAutomato
		aRes:=PLSCRIGEN(adados,{ {"Nome","@C",TamSx3("BTS_NOMUSR")[1]},{"DataNasc","@D",TamSx3("BTS_DATNAS")[1]},{"CPF","@C",TamSx3("BTS_CPFUSR")[1]},{"CRM","@C",TamSx3("BTS_NUMECR")[1]},{"CNES","@C",TamSx3("BTS_CNESPE")[1]},{"Ins.Est","@c",TamSx3("BTS_INSCES")[1]},{"Ins.Muni","@D",TamSx3("BTS_INSCMU")[1]} },"Homonimos na Tabela de Vidas")
	Else
		aRes := {.T.} 
	EndIf
	
	If FunName() == "MATA020"
		If !lCnpjDupli .And. CNPJDUPLI(cCpfUsu)
			PLSAAtuTab(cAlias,Inclui,cMatvid, lAutomato)
		ElseIf !lCnpjDupli .And. !CNPJDUPLI(cCpfUsu)
			PLSAAtuTab(cAlias,Inclui,cMatvid, lAutomato)
		ElseIf lCnpjDupli .And. !CNPJDUPLI(cCpfUsu)
			PLSAAtuTab(cAlias,Inclui,cMatvid, lAutomato)
		EndIf
	Else
		If lAutomato .Or. aRes[1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se confirmou o Homonimo Realiza aTualização da Tabela                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			PLSAAtuTab(cAlias,Inclui,cMatvid, lAutomato)
		Endif
	Endif	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se não Confirmado o Homonimo Sistema Gera Uma Nova Vida na BTS           ³
	//³ Conforme Alias Passado BAU/BK6/SA2/BB0						             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FunName() == "MATA020"
		If !lCnpjDupli .And. CNPJDUPLI(cCpfUsu) .And. !ExisMatVid(cMatVid)
			PLSA955Vid(cAlias)
		ElseIf !lCnpjDupli .And. !CNPJDUPLI(cCpfUsu) .And. !ExisMatVid(cMatVid)
			PLSA955Vid(cAlias)
		ElseIf lCnpjDupli .And. !CNPJDUPLI(cCpfUsu) .And. !ExisMatVid(cMatVid)
			PLSA955Vid(cAlias)
		Endif
	Else
		PLSA955Vid(cAlias)
	EndIf
Endif

Return(lret)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSAAtuTab ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLSAAtuTab(cAlias,Inclui,cMatvid,lAutoma)
LOCAL nI        := 0
LOCAL nJ        := 0
LOCAL nInd      := 0
LOCAL aAlias 	:= {"BTS","SA2","BK6","BB0","BAU"}
LOCAL aArea     := GetArea()
LOCAL lAtuTab   := .T.
Local cSQLBid 	:=""
Local aSX5		:= {} 
Local nLenSX5   := 0

Default lAutoma := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclusao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If Inclui .Or. (!Inclui .And. Empty(&("M->"+IIF(cAlias =="SA2","A2",cAlias)+"_MATVID")))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na Vida							                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BTS->(dbsetorder(1))//Filial + MATVID
	BTS->(dbseek (xFilial("BTS")+cMatvid))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a Atualizacao da Tabela em Memoria	                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:= 1 To &(cAlias+"->( fCount() )")

		cCpoAlias := &(cAlias)->( Field(nI) )

		If !SubStr(cCpoAlias,4,Len(cCpoAlias)) $ "_FILIAL,_CODIGO,_CODBB0,_CODBK6,_COD,_LOJA"

			cCpoBTS := StrTran(cCpoAlias, IIF(cAlias =="SA2","A2",cAlias), "BTS")
			If &( "BTS->(FieldPos('"+cCpoBTS+"'))" ) > 0 .And. !Empty( &("BTS->"+cCpoBTS) )
				&("M->"+cCpoAlias) := &("BTS->"+cCpoBTS)
			EndIf

		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica outros campos 						                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(BTS->BTS_NOMUSR)
		&("M->"+IIF(cAlias =="SA2","A2",cAlias)+"_NOME" ) := BTS->BTS_NOMUSR
	Endif

	If cAlias =="SA2"

		If !Empty(BTS->BTS_NOMRED)
			M->A2_NREDUZ  := BTS->BTS_NOMRED
		Endif
		If !Empty(BTS->BTS_TIPPES)
			M->A2_TIPO    := BTS->BTS_TIPPES
		Endif
		If !Empty(BTS->BTS_DRGUSR)
			M->A2_PFISICA := BTS->BTS_DRGUSR
		Endif
		If !Empty(BTS->BTS_CEPUSR)
			M->A2_CEP     := BTS->BTS_CEPUSR
		Endif
		If !Empty(BTS->BTS_ENDERE)
			M->A2_END     := BTS->BTS_ENDERE
		Endif
		If !Empty(BTS->BTS_CODMUN)
			M->A2_COD_MUN := BTS->BTS_CODMUN
		Endif
		If !Empty(BTS->BTS_COMEND)
			M->A2_ENDCOMP := BTS->BTS_COMEND
		Endif
		If !Empty(BTS->BTS_MUNICI)
			M->A2_MUN     := BTS->BTS_MUNICI
		Endif
		If !Empty(BTS->BTS_ESTADO)
			M->A2_EST	  := BTS->BTS_ESTADO
		Endif
		If !Empty(BTS->BTS_TELEFO)
			M->A2_TEL     := BTS->BTS_TELEFO
		Endif
		If !Empty(BTS->BTS_NUMFAX)
			M->A2_FAX     := BTS->BTS_NUMFAX
		Endif
		If !Empty(BTS->BTS_PAGWEB)
			M->A2_HPAGE	  := BTS->BTS_PAGWEB
		Endif
		If !Empty(BTS->BTS_CPFUSR)
			M->A2_CGC     := BTS->BTS_CPFUSR
		Endif
		If !Empty(BTS->BTS_NUMECR)
			M->A2_CONREG  := BTS->BTS_NUMECR
		Endif
		If !Empty(BTS->BTS_INSCES)
			M->A2_INSCR   := BTS->BTS_INSCES
		Endif
		If !Empty(BTS->BTS_INSCMU)
			M->A2_INSCRM  := BTS->BTS_INSCMU
    	Endif
    ElseIf cAlias =="BK6"
	   	If !Empty(BTS->BTS_CPFUSR)
		   	M->BK6_CGC   	:= BTS->BTS_CPFUSR
		Endif
		If !Empty(BTS->BTS_NUMECR)
			M->BK6_CONREG	:= BTS->BTS_NUMECR
		Endif
		If !Empty(BTS->BTS_SIGLCR)
			M->BK6_SIGLA 	:= BTS->BTS_SIGLCR
		Endif
		If !Empty(BTS->BTS_ESTACR)
			M->BK6_ESTCR 	:= BTS->BTS_ESTACR
		Endif
		If !Empty(BTS->BTS_TELEFO)
			M->BK6_TEL  	:= BTS->BTS_TELEFO
		Endif
	ElseIf cAlias =="BB0"
		If !Empty(BTS->BTS_CPFUSR)
			M->BB0_CGC		:= BTS->BTS_CPFUSR
		Endif
		If !Empty(BTS->BTS_NUMECR)
			M->BB0_NUMCR 	:= BTS->BTS_NUMECR
		Endif
		If !Empty(BTS->BTS_SIGLCR)
			M->BB0_CODSIG 	:= BTS->BTS_SIGLCR
		Endif
		If !Empty(BTS->BTS_CEPUSR)
			M->BB0_CEP	    := BTS->BTS_CEPUSR
		Endif
		If !Empty(BTS->BTS_NR_END)
			M->BB0_NUMERO	:= BTS->BTS_NR_END
		Endif
		If !Empty(BTS->BTS_COMEND)
			M->BB0_COMPLE	:= BTS->BTS_COMEND
		Endif
		If !Empty(BTS->BTS_MUNICI)
			M->BB0_CIDADE	:= BTS->BTS_MUNICI
		Endif
		If !Empty(BTS->BTS_ESTADO)
			M->BB0_UF	    := BTS->BTS_ESTADO
		Endif
		If !Empty(BTS->BTS_ESTACR)
			M->BB0_ESTADO	:= BTS->BTS_ESTACR
	    Endif
	ElseIf cAlias =="BAU"
		If !Empty(BTS->BTS_DATNAS)
			M->BAU_NASFUN	:= BTS->BTS_DATNAS
		Endif
		If !Empty(BTS->BTS_CPFUSR)
			M->BAU_CPFCGC	:= BTS->BTS_CPFUSR
		Endif
		If !Empty(BTS->BTS_NUMECR)
			M->BAU_CONREG	:= BTS->BTS_NUMECR
		Endif
		If !Empty(BTS->BTS_CNESPE)
			M->BAU_CNES		:= BTS->BTS_CNESPE
		Endif
		If !Empty(BTS->BTS_INSCES)
			M->BAU_INSCR 	:= BTS->BTS_INSCES
		Endif
		If !Empty(BTS->BTS_INSCMU)
			M->BAU_INSCRM	:= BTS->BTS_INSCMU
		Endif
		If !Empty(BTS->BTS_ESTACR)
			M->BAU_ESTCR 	:= BTS->BTS_ESTACR
		Endif
		If !Empty(BTS->BTS_NUMCR2)
			M->BAU_CONRE2 	:= BTS->BTS_NUMCR2
		Endif
		If !Empty(BTS->BTS_NOMRED)
			M->BAU_NREDUZ 	:= BTS->BTS_NOMRED
		Endif
		If !Empty(BTS->BTS_TIPPES)
			M->BAU_TIPPE  	:= BTS->BTS_TIPPES
		Endif
		If !Empty(BTS->BTS_DRGUSR)
			M->BAU_RG     	:= BTS->BTS_DRGUSR
		Endif
		If !Empty(BTS->BTS_CEPUSR)
			M->BAU_CEP    	:= BTS->BTS_CEPUSR
		Endif
		If !Empty(BTS->BTS_ENDERE)
			M->BAU_END    	:= BTS->BTS_ENDERE
		Endif
		If !Empty(BTS->BTS_NR_END)
			M->BAU_NUMERO 	:= BTS->BTS_NR_END
		Endif
		If !Empty(BTS->BTS_COMEND)
	    	M->BAU_COMPL  	:= BTS->BTS_COMEND
		Endif
		If !Empty(BTS->BTS_CODMUN)
	    	M->BAU_MUN    	:= BTS->BTS_CODMUN
		Endif
		If !Empty(BTS->BTS_MUNICI)
	    	M->BAU_DESMUN   := BTS->BTS_MUNICI
		Endif
		If !Empty(BTS->BTS_ESTADO)
	    	M->BAU_EST    	:= BTS->BTS_ESTADO
		Endif
		If !Empty(BTS->BTS_TELEFO)
	    	M->BAU_TEL    	:= BTS->BTS_TELEFO
		Endif
		If !Empty(BTS->BTS_DTINSC)
	    	M->BAU_DTINCL 	:= BTS->BTS_DTINSC
		Endif
		If !Empty(BTS->BTS_NOMFAN)
	    	M->BAU_NFANTA 	:= BTS->BTS_NOMFAN
		Endif
		If !Empty(BTS->BTS_NUMFAX)
	    	M->BAU_FAX    	:= BTS->BTS_NUMFAX
		Endif
		If !Empty(BTS->BTS_PAGWEB)
			M->BAU_WEB    	:= BTS->BTS_PAGWEB
	    Endif
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajusta Sexo BAU, pois 0-Masculino e 1-Feminino                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !Empty(BTS->BTS_SEXO)
			If M->BAU_SEXO  == "1" // 1 - Masculino na Vida
		    	M->BAU_SEXO := '0' // Masculino BAU
		    Else
		    	M->BAU_SEXO := '1'
		    Endif
		Endif
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Alteracao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Else
	
	For nI:= 1 To Len(aAlias)
		// O Alias Atual nao é atualizado
		If aAlias[nI] <> cAlias
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se encontrar vinculo com a Vida				                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecno:= ExistVida(aAlias[nI],cMatvid, lAutoma)

			If nRecno > 0

				&(aAlias[nI])->(dbGoTo(nRecno))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Realiza a gravacao das Tabelas especificas		                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				&( aAlias[nI]+"->(RecLock('"+aAlias[nI]+"',.F.))" )

					For nJ:= 1 To &(aAlias[nI]+"->( fCount() )")

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ As caracteristicas dos campos Naiconalide são diferentes nas tabelas.    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
						If (aAlias[nI])->( Field(nJ) ) <> 'BTS_NACION' .And. (aAlias[nI])->( Field(nJ) ) <> 'BAU_NACION'

							cCpo_aAlias := &(aAlias[nI])->( Field(nJ) )

							If !SubStr(cCpo_aAlias,4,Len(cCpo_aAlias)) $ "_FILIAL,_CODIGO,_MATVID,_CODBB0,_CODBK6,_COD,_LOJA"

								cCpoAlias   := StrTran(cCpo_aAlias, IiF(aAlias[nI] =="SA2","A2",aAlias[nI]),IiF(cAlias =="SA2","A2",cAlias))

								If &(cAlias+"->( FieldPos('"+cCpoAlias+"') )") > 0  .And. !Empty(&("M->"+cCpoAlias))

									cCpo_aAlias  := aAlias[nI]+"->"+cCpo_aAlias
									&cCpo_aAlias := &("M->"+cCpoAlias)

								EndIf
							EndIf
						
						ElseIf (aAlias[nI])->( Field(nJ) ) == 'BTS_NACION'
							
							If cAlias == "BAU" 
							
								aSX5    := FWGetSX5("34") 
								nLenSX5 := LEN(aSX5) 

								FOR nInd := 1 TO nLenSX5
									
									If AllTrim( aSX5[nInd][4] ) $ M->BAU_NACION
											BTS->BTS_NACION := AllTrim( aSX5[nInd][3] )
											EXIT
									EndIf
								NEXT
							EndIf 
							
						ElseIf cAlias <> "SA2"
								BAU->BAU_NACION:= Iif(!lAutoma,TABELA( "34", M->BTS_NACION,.T.),BAU->BAU_NACION)
						EndIf								
						
					Next nJ

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica outros campos 						                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aAlias[nI] =="SA2"
						If cAlias == "BTS"
							If !Empty(M->BTS_NOMUSR)
								SA2->A2_NOME    := M->BTS_NOMUSR
							Endif
							If !Empty(M->BTS_NOMRED)
								SA2->A2_NREDUZ  := M->BTS_NOMRED
							Endif
							If !Empty(M->BTS_TIPPES)
								SA2->A2_TIPO    := M->BTS_TIPPES
							Endif
							If !Empty(M->BTS_DRGUSR)
								SA2->A2_PFISICA := M->BTS_DRGUSR
							Endif
							If !Empty(M->BTS_CEPUSR)
								SA2->A2_CEP     := M->BTS_CEPUSR
							Endif
							If !Empty(M->BTS_ENDERE)
								SA2->A2_END     := M->BTS_ENDERE
							Endif
							If !Empty(M->BTS_CODMUN)
								SA2->A2_COD_MUN := M->BTS_CODMUN
							Endif
							If !Empty(M->BTS_COMEND)
								SA2->A2_ENDCOMP := M->BTS_COMEND
							Endif
							If !Empty(M->BTS_MUNICI)
								SA2->A2_MUN     := M->BTS_MUNICI
							Endif
							If !Empty(M->BTS_ESTADO)
								SA2->A2_ESTADO  := M->BTS_ESTADO
								SA2->A2_EST  	:= M->BTS_ESTADO
							Endif
							If !Empty(M->BTS_TELEFO)
								SA2->A2_TEL     := M->BTS_TELEFO
							Endif
							If !Empty(M->BTS_NUMFAX)
								SA2->A2_FAX     := M->BTS_NUMFAX
							Endif
							If !Empty(M->BTS_PAGWEB)
								SA2->A2_HPAGE   := M->BTS_PAGWEB
							Endif
							If !Empty(M->BTS_CPFUSR)
								SA2->A2_CGC     := M->BTS_CPFUSR
							Endif
							If !Empty(M->BTS_NUMECR)
								SA2->A2_CONREG  := M->BTS_NUMECR
							Endif
							If !Empty(M->BTS_INSCES)
								SA2->A2_INSCR   := M->BTS_INSCES
							Endif
							If !Empty(M->BTS_INSCMU)
								SA2->A2_INSCRM  := M->BTS_INSCMU
							Endif
						ElseIf cAlias == "BK6"
							If !Empty(M->BK6_CGC)
								SA2->A2_CEP		:= M->BK6_CGC
							Endif
						ElseIf cAlias =="BB0"
							If !Empty(M->BB0_NUMCR)
								SA2->A2_CONREG  := M->BB0_NUMCR
							Endif
							If !Empty(M->BB0_NUMERO)
								SA2->A2_NR_END  := M->BB0_NUMERO
							Endif
							If !Empty(M->BB0_COMPLE)
								SA2->A2_ENDCOMP := M->BB0_COMPLE
							Endif
							If !Empty(M->BB0_CIDADE)
								SA2->A2_MUN     := M->BB0_CIDADE
							Endif
							If !Empty(M->BB0_UF)
								SA2->A2_EST     := M->BB0_UF
							Endif
						ElseIf cAlias =="BAU"
							If !Empty(M->BAU_CPFCGC)
								SA2->A2_CGC     := M->BAU_CPFCGC
							Endif
							If !Empty(M->BAU_TIPPE)
								SA2->A2_TIPO    := M->BAU_TIPPE
							Endif
							If !Empty(M->BAU_RG)
								SA2->A2_PFISICA := M->BAU_RG
							Endif
							If !Empty(M->BAU_NUMERO)
								SA2->A2_NR_END  := M->BAU_NUMERO
							Endif
							If !Empty(M->BAU_COMPL)
								SA2->A2_ENDCOMP := M->BAU_COMPL
							Endif
							If !Empty(M->BAU_NFANTA)
								SA2->A2_NREDUZ  := M->BAU_NFANTA
							Endif
							If !Empty(M->BAU_WEB)
								SA2->A2_HPAGE   := M->BAU_WEB
							Endif
					Endif

					ElseIf aAlias[nI] =="BTS"
						If cAlias == "SA2"
							If !Empty(M->A2_NOME)
								BTS->BTS_NOMUSR  := M->A2_NOME
								BTS->BTS_NOMCAR  := M->A2_NOME
							Endif
							If !Empty(M->A2_NREDUZ)
								BTS->BTS_NOMRED  := M->A2_NREDUZ
							Endif
							If !Empty(M->A2_TIPO)
								BTS->BTS_TIPPES  := M->A2_TIPO
							Endif
							If !Empty(M->A2_PFISICA)
								BTS->BTS_DRGUSR  := M->A2_PFISICA
							Endif
							If !Empty(M->A2_CEP)
								BTS->BTS_CEPUSR  := M->A2_CEP
							Endif
							If !Empty(M->A2_END)
								BTS->BTS_ENDERE  := M->A2_END
							Endif
							If !Empty(M->A2_COD_MUN)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³REALIZA CONSULTA NA TABELA BID PARA OBTER CÓDIGO MUNICIPIO 7 POSIÇÕES.
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

								cSQLBid := "SELECT BID_CODMUN FROM " + RetSQLName("BID") + " WHERE BID_CODMUN LIKE '%" + AllTRIM(M->A2_COD_MUN) + "%'"
								cSQLBid := ChangeQuery(cSQLBid)
								dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLBid),"TrbBID",.F.,.T.)

								If ! TrbBID->(Eof())
									BTS->BTS_CODMUN  := TrbBID->BID_CODMUN //M->A2_COD_MUN
								Endif
								TrbBID->(DbCloseArea())
							Endif
							If !Empty(M->A2_ENDCOMP)
								BTS->BTS_COMEND  := M->A2_ENDCOMP
							Endif
							If !Empty(M->A2_MUN)
								BTS->BTS_MUNICI  := M->A2_MUN
							Endif
							If !Empty(M->A2_EST)
								BTS->BTS_ESTADO  := M->A2_EST
							Endif
							If !Empty(M->A2_TEL)
								BTS->BTS_TELEFO  := M->A2_TEL
							Endif
							If !Empty(M->A2_FAX)
								BTS->BTS_NUMFAX	 := M->A2_FAX
							Endif
							If !Empty(M->A2_HPAGE)
								BTS->BTS_PAGWEB	 := M->A2_HPAGE
							Endif
							If !Empty(M->A2_CGC)
								BTS->BTS_CPFUSR	 := M->A2_CGC
							Endif
							If !Empty(M->A2_CONREG)
								BTS->BTS_NUMECR	 := M->A2_CONREG
							Endif
							If !Empty(M->A2_INSCR)
								BTS->BTS_INSCES	 := M->A2_INSCR
							Endif
							If !Empty(M->A2_INSCRM)
								BTS->BTS_INSCMU	 := M->A2_INSCRM
							Endif
						ElseIf cAlias == "BK6"
							If !Empty(M->BK6_NOME)
								BTS->BTS_NOMUSR := M->BK6_NOME
							Endif
							If !Empty(M->BK6_CGC)
								BTS->BTS_CPFUSR := M->BK6_CGC
							Endif
							If !Empty(M->BK6_CONREG)
								BTS->BTS_NUMECR := M->BK6_CONREG
							Endif
							If !Empty(M->BK6_SIGLA)
								BTS->BTS_SIGLCR := M->BK6_SIGLA
							Endif
							If !Empty(M->BK6_ESTCR)
								BTS->BTS_ESTACR := M->BK6_ESTCR
							Endif
							If !Empty(M->BK6_TEL)
								BTS->BTS_TELEFO := M->BK6_TEL
							Endif
						ElseIf cAlias =="BB0"
							If !Empty(M->BB0_NOME)
								BTS->BTS_NOMUSR  := M->BB0_NOME
							Endif
							If !Empty(M->BB0_CGC)
								BTS->BTS_CPFUSR  := M->BB0_CGC
							Endif
							If !Empty(M->BB0_NUMCR)
								BTS->BTS_NUMECR  := M->BB0_NUMCR
							Endif
							If !Empty(M->BB0_NUMERO)
								BTS->BTS_NR_END  := M->BB0_NUMERO
							Endif
							If !Empty(M->BB0_COMPLE)
								BTS->BTS_COMEND  := M->BB0_COMPLE
							Endif
							If !Empty(M->BB0_CIDADE)
								BTS->BTS_MUNICI  := M->BB0_CIDADE
							Endif
						ElseIf cAlias =="BAU"
							If !Empty(M->BAU_NOME)
								BTS->BTS_NOMUSR  := M->BAU_NOME
							Endif
							If !Empty(M->BAU_CPFCGC)
								BTS->BTS_CPFUSR  := M->BAU_CPFCGC
							Endif
							If !Empty(M->BAU_CONREG)
								BTS->BTS_NUMECR  := M->BAU_CONREG
							Endif
							If !Empty(M->BAU_TIPPE)
								BTS->BTS_TIPPES  := M->BAU_TIPPE
							Endif
							If !Empty(M->BAU_RG)
								BTS->BTS_DRGUSR  := M->BAU_RG
							Endif
							If !Empty(M->BAU_NUMERO)
								BTS->BTS_NR_END  := M->BAU_NUMERO
							Endif
							If !Empty(M->BAU_COMPL)
								BTS->BTS_COMEND  := M->BAU_COMPL
							Endif
							If !Empty(M->BAU_WEB)
								BTS->BTS_PAGWEB  := M->BAU_WEB
							Endif
							If !Empty(M->BAU_NASFUN)
								BTS->BTS_DATNAS  := M->BAU_NASFUN
							Endif
							If !Empty(M->BAU_CNES)
								BTS->BTS_CNESPE  := M->BAU_CNES
							Endif
							If !Empty(M->BAU_INSCR)
								BTS->BTS_INSCES  := M->BAU_INSCR
							Endif
							If !Empty(M->BAU_INSCRM)
								BTS->BTS_INSCMU  := M->BAU_INSCRM
							Endif
							If !Empty(M->BAU_ESTCR)
								BTS->BTS_ESTACR  := M->BAU_ESTCR
							Endif
							If !Empty(M->BAU_CONRE2)
								BTS->BTS_NUMCR2  := M->BAU_CONRE2
							Endif
							If !Empty(M->BAU_NREDUZ)
								BTS->BTS_NOMRED  := M->BAU_NREDUZ
							Endif
							If !Empty(M->BAU_CEP)
								BTS->BTS_CEPUSR  := M->BAU_CEP
							Endif
							If !Empty(M->BAU_END)
								BTS->BTS_ENDERE  := M->BAU_END
							Endif
							If !Empty(M->BAU_MUN)
								BTS->BTS_CODMUN  := M->BAU_MUN
							Endif
							If !Empty(M->BAU_DESMUN)
								BTS->BTS_MUNICI  := M->BAU_DESMUN
							Endif
							If !Empty(M->BAU_EST)
								BTS->BTS_ESTADO  := M->BAU_EST
							Endif
							If !Empty(M->BAU_TEL)
								BTS->BTS_TELEFO  := M->BAU_TEL
							Endif
							If !Empty(M->BAU_DTINCL)
								BTS->BTS_DTINSC  := M->BAU_DTINCL
							Endif
							If !Empty(M->BAU_NFANTA)
								BTS->BTS_NOMFAN  := M->BAU_NFANTA
							Endif
							If !Empty(M->BAU_FAX)
								BTS->BTS_NUMFAX  := M->BAU_FAX
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ajusta Sexo BAU, pois 0-Masculino e 1-Feminino                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(M->BAU_SEXO)
								If BTS->BTS_SEXO  == "1" // 1 - Feminino no BAU
									BTS->BTS_SEXO := '2' // Feminino Vida
								Else
									BTS->BTS_SEXO := '1'
								Endif
							Endif
						Endif

					ElseIf aAlias[nI] =="BK6"
						If cAlias == "SA2"
							If !Empty(M->A2_SIGLCR)
								BK6->BK6_SIGLA 	:= M->A2_SIGLCR
						Endif
						ElseIf cAlias == "BTS"
							If !Empty(M->BTS_NOMUSR)
								BK6->BK6_NOME  	:= M->BTS_NOMUSR
							Endif
							If !Empty(M->BTS_CPFUSR)
								BK6->BK6_CGC   	:= M->BTS_CPFUSR
							Endif
							If !Empty(M->BTS_NUMECR)
								BK6->BK6_CONREG	:= M->BTS_NUMECR
							Endif
							If !Empty(M->BTS_SIGLCR)
								BK6->BK6_SIGLA 	:= M->BTS_SIGLCR
							Endif
							If !Empty(M->BTS_ESTACR)
								BK6->BK6_ESTCR := M->BTS_ESTACR
							Endif
							If !Empty(M->BTS_TELEFO)
								BK6->BK6_TEL  	:= M->BTS_TELEFO
							Endif
						ElseIf cAlias == "BB0"
							If !Empty(M->BB0_NUMCR)
								BK6->BK6_CONREG := M->BB0_NUMCR
							Endif
							If !Empty(M->BB0_CODSIG)
								BK6->BK6_SIGLA  := M->BB0_CODSIG
							Endif
						ElseIf cAlias == "BAU"
							If !Empty(M->BAU_CPFCGC)
								BK6->BK6_CGC   	:=  M->BAU_CPFCGC
							Endif
							If !Empty(M->BAU_SIGLCR)
								BK6->BK6_SIGLA 	:=	M->BAU_SIGLCR
							Endif
						Endif

					ElseIf aAlias[nI] =="BB0"
						If cAlias == "SA2"
							If !Empty(M->A2_CONREG)
								BB0->BB0_NUMCR 	:= M->A2_CONREG
							Endif
							If !Empty(M->A2_NR_END)
								BB0->BB0_NUMERO	:= M->A2_NR_END
							Endif
							If !Empty(M->A2_ENDCOMP)
								BB0->BB0_COMPLE	:= M->A2_ENDCOMP
							Endif
							If !Empty(M->A2_MUN)
								BB0->BB0_CIDADE	:= M->A2_MUN
							Endif
							If !Empty(M->A2_EST)
								BB0->BB0_UF	    := M->A2_EST
							Endif
						ElseIf cAlias == "BTS"
							If !Empty(M->BTS_NOMUSR)
								BB0->BB0_NOME	:= M->BTS_NOMUSR
							Endif
							If !Empty(M->BTS_CPFUSR)
								BB0->BB0_CGC	:= M->BTS_CPFUSR
							Endif
							If !Empty(M->BTS_NUMECR)
								BB0->BB0_NUMCR 	:= M->BTS_NUMECR
							Endif
							If !Empty(M->BTS_SIGLCR)
								BB0->BB0_CODSIG := M->BTS_SIGLCR
							Endif
							If !Empty(M->BTS_CEPUSR)
								BB0->BB0_CEP	:= M->BTS_CEPUSR
							Endif
							If !Empty(M->BTS_NR_END)
								BB0->BB0_NUMERO	:= M->BTS_NR_END
							Endif
							If !Empty(M->BTS_COMEND)
								BB0->BB0_COMPLE	:= M->BTS_COMEND
							Endif
							If !Empty(M->BTS_MUNICI)
								BB0->BB0_CIDADE	:= M->BTS_MUNICI
							Endif
							If !Empty(M->BTS_ESTADO)
								BB0->BB0_UF	    := M->BTS_ESTADO
							Endif
							If !Empty(M->BTS_ESTACR)
								BB0->BB0_ESTADO	:= M->BTS_ESTACR
							Endif
						ElseIf cAlias == "BK6"
							If !Empty(M->BK6_CONREG)
								BB0->BB0_NUMCR := M->BK6_CONREG
							Endif
							If !Empty(M->BK6_SIGLA)
								BB0->BB0_CODSIG:= M->BK6_SIGLA
							Endif
							If !Empty(M->BK6_ESTCR)
								BB0->BB0_ESTADO := M->BK6_ESTCR
							Endif
						ElseIf cAlias == "BAU"
							If !Empty(M->BAU_CPFCGC)
								BB0->BB0_CGC   	:=  M->BAU_CPFCGC
							Endif
							If !Empty(M->BAU_SIGLCR)
								BB0->BB0_CODSIG	:=	M->BAU_SIGLCR
							Endif
							If !Empty(M->BAU_NASFUN)
								BB0->BB0_DATNAS	:=	M->BAU_NASFUN
							Endif
							If !Empty(M->BAU_ESTCR)
								BB0->BB0_ESTADO := M->BAU_ESTCR
							Endif
							If !Empty(M->BAU_CONREG)
								BB0->BB0_NUMCR := M->BAU_CONREG
							Endif
							If !Empty(M->BAU_END)
								BB0->BB0_ENDERE := M->BAU_END
							Endif
							If !Empty(M->BAU_COMPL)
								BB0->BB0_COMPLE := M->BAU_COMPL
							Endif
							If !Empty(M->BAU_MUN)
								BB0->BB0_CODMUN := M->BAU_MUN
							Endif
							If !Empty(M->BAU_EST)
								BB0->BB0_UF := M->BAU_EST
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ajusta Sexo BAU, pois 0-Masculino e 1-Feminino                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(M->BAU_SEXO)
								If BB0->BB0_SEXO  == "1" // 1 - Feminino no BAU
									BB0->BB0_SEXO := '2' // Feminino Profissional
								Else
									BB0->BB0_SEXO := '1'
								Endif
							Endif
						Endif

					ElseIf aAlias[nI] =="BAU"
						If cAlias == "SA2"
							If !Empty(M->A2_TIPO)
								BAU->BAU_TIPPE := M->A2_TIPO
							Endif
							If !Empty(M->A2_PFISICA)
								BAU->BAU_RG := M->A2_PFISICA
							Endif
							IF !Empty(M->A2_CGC)
								BAU->BAU_CPFCGC := M->A2_CGC
							Endif
							If !Empty(M->A2_END)
								BAU->BAU_END := M->A2_END
							Endif
							If !Empty(M->A2_COD_MUN)

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³REALIZA CONSULTA NA TABELA BID PARA OBTER CÓDIGO MUNICIPIO 7 POSIÇÕES.
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

								cSQLBid := "SELECT BID_CODMUN FROM " + RetSQLName("BID") + " WHERE BID_CODMUN LIKE '%" + AllTRIM(M->A2_COD_MUN) + "%'"
								cSQLBid := ChangeQuery(cSQLBid)
								dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLBid),"TrbBID",.F.,.T.)

								If ! TrbBID->(Eof())
									BAU->BAU_MUN := TrbBID->BID_CODMUN //M->A2_COD_MUN
								Endif
								TrbBID->(DbCloseArea())

							Endif
							If !Empty(M->A2_ENDCOMP)
								BAU->BAU_COMPL  := M->A2_ENDCOMP
							Endif
							If !Empty(M->A2_HPAGE)
								BAU->BAU_WEB	:= M->A2_HPAGE
							Endif
						ElseIf cAlias == "BK6"
							If !Empty(M->BK6_CGC)
								BAU->BAU_CPFCGC := M->BK6_CGC
							Endif
							If !Empty(M->BK6_SIGLA)
								BAU->BAU_SIGLCR := M->BK6_SIGLA
							Endif
						ElseIf cAlias =="BB0"
							If !Empty(M->BB0_CGC)
								BAU->BAU_CPFCGC  := M->BB0_CGC
							Endif
							If !Empty(M->BB0_NUMCR)
								BAU->BAU_INSCR   := M->BB0_NUMCR
							Endif
							If !Empty(M->BB0_COMPLE)
								BAU->BAU_COMPL   := M->BB0_COMPLE
							Endif
							If !Empty(M->BB0_CODMUN)
								BAU->BAU_MUN     := M->BB0_CODMUN
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ajusta Sexo BAU, pois 0-Masculino e 1-Feminino                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(M->BB0_SEXO)
								If BAU->BAU_SEXO  == "1" // 1 - Masculino no profissional
									BAU->BAU_SEXO := '0' // Masculino BAU
								Else
									BAU->BAU_SEXO := '1'
								Endif
							Endif
						ElseIf cAlias =="BTS"
							If !Empty(M->BTS_NOMUSR)
								BAU->BAU_NOME   := M->BTS_NOMUSR
							Endif
							If !Empty(M->BTS_CPFUSR)
								BAU->BAU_CPFCGC := M->BTS_CPFUSR
							Endif
							If !Empty(M->BTS_NUMECR)
								BAU->BAU_CONREG := M->BTS_NUMECR
							Endif
							If !Empty(M->BTS_TIPPES)
								BAU->BAU_TIPPE  := M->BTS_TIPPES
							Endif
							If !Empty(M->BTS_DRGUSR)
								BAU->BAU_RG     := M->BTS_DRGUSR
							Endif
							If !Empty(M->BTS_NR_END)
								BAU->BAU_NUMERO := M->BTS_NR_END
							Endif
							If !Empty(M->BTS_COMEND)
								BAU->BAU_COMPL  := M->BTS_COMEND
							Endif
							If !Empty(M->BTS_PAGWEB)
								BAU->BAU_WEB    := M->BTS_PAGWEB
							Endif
							If !Empty(M->BTS_DATNAS)
								BAU->BAU_NASFUN := M->BTS_DATNAS
							Endif
							If !Empty(M->BTS_CNESPE)
								BAU->BAU_CNES   := M->BTS_CNESPE
							Endif
							If !Empty(M->BTS_INSCES)
								BAU->BAU_INSCR  := M->BTS_INSCES
							Endif
							If !Empty(M->BTS_INSCMU)
								BAU->BAU_INSCRM := M->BTS_INSCMU
							Endif
							If !Empty(M->BTS_ESTACR)
								BAU->BAU_ESTCR  := M->BTS_ESTACR
							Endif
							If !Empty(M->BTS_NUMCR2)
								BAU->BAU_CONRE2 := M->BTS_NUMCR2
							Endif
							If !Empty(M->BTS_NOMRED)
								BAU->BAU_NREDUZ := M->BTS_NOMRED
							Endif
							If !Empty(M->BTS_CEPUSR)
								BAU->BAU_CEP    := M->BTS_CEPUSR
							Endif
							If !Empty(M->BTS_ENDERE)
								BAU->BAU_END    := M->BTS_ENDERE
							Endif
							If !Empty(M->BTS_CODMUN)
								BAU->BAU_MUN    := M->BTS_CODMUN
							Endif
							If !Empty(M->BTS_ESTADO)
								BAU->BAU_EST    := M->BTS_ESTADO
							Endif
							If !Empty(M->BTS_TELEFO)
								BAU->BAU_TEL    := M->BTS_TELEFO
							Endif
							If !Empty(M->BTS_DTINSC)
								BAU->BAU_DTINCL := M->BTS_DTINSC
							Endif
							If !Empty(M->BTS_NOMFAN)
								BAU->BAU_NFANTA := M->BTS_NOMFAN
							Endif
							If !Empty(M->BTS_NUMFAX)
								BAU->BAU_FAX    := M->BTS_NUMFAX
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ajusta Sexo BAU, pois 0-Masculino e 1-Feminino                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(M->BTS_SEXO)
								If BAU->BAU_SEXO  == "1" // 1 - Masculino na Vida
									BAU->BAU_SEXO := '0' // Masculino BAU
								Else
									BAU->BAU_SEXO := '1'
								Endif
							Endif
						Endif
					Endif

				&(aAlias[nI])->(MsUnlock())
			Endif
		Endif
	Next nI
Endif

RestArea(aArea)

Return(lAtuTab)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA955Vid ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA955Vid(cAlias)
LOCAL cCodVid := ''
LOCAL nI 	  := 0
LOCAL aArea   := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o novo codigo de vida...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodVid := BTS->(GetSx8Num("BTS","BTS_MATVID"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a gravacao das Tabelas				                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BTS->(RecLock("BTS",.T.))
	For nI:= 1 To &(cAlias+"->( fCount() )")

		cCpoAlias := &(cAlias)->( Field(nI) )
		cCpoBTS   := StrTran(cCpoAlias, IIF(cAlias =="SA2","A2",cAlias), "BTS")

		If BTS->( FieldPos(cCpoBTS) ) > 0
			cCpoBTS  := "BTS->"+cCpoBTS
			&cCpoBTS := &("M->"+cCpoAlias)
		EndIf

	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Filial		 						                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BTS->BTS_FILIAL  := xFilial("BTS")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Outros Campos 						                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAlias =="SA2"
		BTS->BTS_NOMUSR  := M->A2_NOME
		BTS->BTS_NOMCAR  := M->A2_NOME
		BTS->BTS_NOMRED  := M->A2_NREDUZ
		BTS->BTS_TIPPES  := M->A2_TIPO
		BTS->BTS_DRGUSR  := M->A2_PFISICA
		BTS->BTS_CEPUSR  := M->A2_CEP
		BTS->BTS_ENDERE  := M->A2_END
		BTS->BTS_CODMUN  := M->A2_COD_MUN
		BTS->BTS_COMEND  := M->A2_ENDCOMP
		BTS->BTS_MUNICI  := M->A2_MUN
		BTS->BTS_ESTADO  := M->A2_EST
		BTS->BTS_TELEFO  := M->A2_TEL
		BTS->BTS_INTERD  := "0"
		BTS->BTS_CORNAT  := "6"
		BTS->BTS_NUMFAX	 := M->A2_FAX
		BTS->BTS_PAGWEB	 := M->A2_HPAGE
		BTS->BTS_CPFUSR	 := M->A2_CGC
		BTS->BTS_NUMECR	 := M->A2_CONREG
		BTS->BTS_INSCES	 := M->A2_INSCR
		BTS->BTS_INSCMU	 := M->A2_INSCRM

    ElseIf cAlias =="BK6"
		BTS->BTS_NOMUSR := M->BK6_NOME
		BTS->BTS_NOMCAR := M->BK6_NOME
		BTS->BTS_NOMRED := M->BK6_NOME
		BTS->BTS_CPFUSR := M->BK6_CGC
		BTS->BTS_TELEFO := M->BK6_TEL
		BTS->BTS_INTERD := "0"
		BTS->BTS_CORNAT := "6"
		BTS->BTS_NUMECR	:= M->BK6_CONREG
		BTS->BTS_SIGLCR	:= M->BK6_SIGLA
		BTS->BTS_ESTACR	:= M->BK6_ESTCR

	ElseIf cAlias =="BB0"
		BTS->BTS_NOMUSR := M->BB0_NOME
		BTS->BTS_NOMCAR := M->BB0_NOME
		BTS->BTS_NOMRED := M->BB0_NOME
		BTS->BTS_CPFUSR := M->BB0_CGC
		BTS->BTS_CEPUSR := M->BB0_CEP
		BTS->BTS_NR_END := M->BB0_NUMERO
		BTS->BTS_COMEND := M->BB0_COMPLE
		BTS->BTS_MUNICI := M->BB0_CODMUN
		BTS->BTS_ESTADO := M->BB0_UF
		BTS->BTS_INTERD := "0"
		BTS->BTS_CORNAT := "6"
		BTS->BTS_NUMECR	:= M->BB0_NUMCR
		BTS->BTS_SIGLCR	:= M->BB0_CODSIG
		BTS->BTS_ESTACR	:= M->BB0_ESTADO

	ELseIf cAlias =="BAU"
		BTS->BTS_NOMUSR := M->BAU_NOME
		BTS->BTS_NOMCAR := M->BAU_NREDUZ
		BTS->BTS_NOMRED := M->BAU_NREDUZ
		BTS->BTS_CPFUSR := M->BAU_CPFCGC
		BTS->BTS_TIPPES := M->BAU_TIPPE
		BTS->BTS_DRGUSR := M->BAU_RG
		BTS->BTS_CEPUSR := M->BAU_CEP
		BTS->BTS_ENDERE := M->BAU_END
		BTS->BTS_NR_END := M->BAU_NUMERO
		BTS->BTS_COMEND := M->BAU_COMPL
		BTS->BTS_CODMUN := M->BAU_MUN
		BTS->BTS_MUNICI := M->BAU_DESMUN
		BTS->BTS_ESTADO := M->BAU_EST
		BTS->BTS_TELEFO := M->BAU_TEL
		BTS->BTS_DATNAS := M->BAU_NASFUN
		BTS->BTS_INTERD := "0"
		BTS->BTS_CORNAT := "6"
		BTS->BTS_NUMECR	:= M->BAU_CONREG
		BTS->BTS_CNESPE	:= M->BAU_CNES
		BTS->BTS_INSCES	:= M->BAU_INSCR
		BTS->BTS_INSCMU	:= M->BAU_INSCRM
		BTS->BTS_ESTACR	:= M->BAU_ESTCR
		BTS->BTS_DTINSC	:= M->BAU_DTINCL
		BTS->BTS_NUMCR2	:= M->BAU_CONRE2
		BTS->BTS_NOMFAN	:= M->BAU_NFANTA
		BTS->BTS_NUMFAX	:= M->BAU_FAX
		BTS->BTS_DTINC 	:= M->BAU_DTINCL
		BTS->BTS_PAGWEB	:= M->BAU_WEB
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o Codigo Vida 						                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BTS->( FieldPos("BTS_MATVID") ) > 0
		BTS->BTS_MATVID  := cCodVid
	Endif
	BTS->(ConfirmSX8())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vincula a Vida no Cadastro Atual.			                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&("M->"+IIF(cAlias =="SA2","A2",cAlias)+"_MATVID") := cCodVid

BTS->( MsUnlock() )

RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ExistVida  ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ExistVida(cAlias,cMatVid)
Local nRecno := 0
Local aArea  := GetArea()
Local cSQL   := ""

If &(cAlias+"->( FieldPos('"+IIF(cAlias =="SA2","A2",cAlias)+"_MATVID'))") > 0
	cSQL:= "SELECT R_E_C_N_O_ RECNOVIDA  FROM  "
	cSQL+= RetSQlName(cAlias)+ " WHERE "
	cSQL+= IIF(cAlias =="SA2","A2",cAlias)+"_FILIAL = '" + xFilial(cAlias) + "' AND "
	cSQL+= IIF(cAlias =="SA2","A2",cAlias)+"_MATVID = '"+cMatVid+"' AND "
	cSQL+= " D_E_L_E_T_ = '' "
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QrVida",.F.,.T.)
	If QrVida->(!EOF())
		nRecno := QrVida->(RECNOVIDA)
	Endif
	QrVida->(dbCloseArea())
Endif

RestArea(aArea)

Return nRecno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PL955VALCNS³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PL955VALCNS(cAliCNS) 
Local lRet := .T.

Default cAliCNS := "BTS"

If !Empty(alltrim(M->&(cAliCNS+"_NRCRNA")))
	 lRet := HS_VldCns(M->&(cAliCNS+"_NRCRNA"))
	 If !lRet
	 	Help( ,, 'BTS_NRCRNA')
	else 
		
		If cAliCNS == "BTS"
			
			SIX->(DbSetOrder(1))
		 	IF SIX->( MsSeek("BTS7") ) .And. cPaisLoc == "BRA"       
		 		lRet:= ExistChav("BTS",M->BTS_NRCRNA,7)
		 	EndIf
	 	EndIf 
	 EndIf    
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA955CON ³ Autor ³  Anderson Tomé     ³ Data ³ 02.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA955CON(nTipo) 

LOCAL nRecBTS := BTS->(Recno())
LOCAL nOrdBTS := BTS->(IndexOrd())
LOCAL cAlias1 := ""
LOCAL cAlias2 := ""

LOCAL lRet := .T.

//verificando se M->BTS_CPFUSR é diferente do cpf do pai, da mãe e do preposto
If AllTrim(M->BTS_CPFUSR) == M->BTS_CPFMAE .Or. AllTrim(M->BTS_CPFUSR) == M->BTS_CPFPAI .Or. AllTrim(M->BTS_CPFUSR) == M->BTS_CPFPRE

	lRet := .F.
	Return lRet
	
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nTipo == 1 ; a validacao esta no CPF                                          ³
	//³ nTipo == 2 ; a validacao esta ou no Numero do CR, Estado CR ou Sigla CR       ³
	//³ nTipo == 3 ; a validacao esta ou no Numero2 do CR, Estado2 CR ou Sigla2 CR    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nTipo == 1 .and. ! Empty(M->BTS_CPFUSR)
	
	   SA2->(DBSetOrder(3))
	   
	   If SA2->(MsSeek(xFilial("SA2")+M->BTS_CPFUSR))
	   
	      cAlias1 := "SA2"
	      cAlias2 := "BTS"
	      
	   Endif
	   
	Endif
	
	If nTipo == 2 .And. ! Empty(M->BTS_ESTACR) .And. ! Empty(M->BTS_SIGLCR) .And. ! Empty(M->BTS_NUMECR)
	
	   BB0->(DBSetOrder(4))
	   
	   If BB0->(MsSeek(xFilial("BB0")+M->(BTS_ESTACR+BTS_SIGLCR+BTS_NUMECR)))
	   
	      cAlias1 := "BB0"
	      cAlias2 := "BTS"
	      
	   Endif
	   
	Endif
	
	If nTipo == 3 .And. ! Empty(M->BTS_ESTCR2) .And. ! Empty(M->BTS_SIGCR2) .And. ! Empty(M->BTS_NUMCR2)
	
	   BB0->(DBSetOrder(4))
	   
	   If BB0->(MsSeek(xFilial("BB0")+M->(BTS_ESTCR2+BTS_SIGCR2+BTS_NUMCR2)))
	   
	      cAlias1 := "BB0"
	      cAlias2 := "BTS"
	      
	   Endif
	   
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura dados salvados...                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	BTS->(DbSetOrder(nOrdBTS))
	BTS->(DbGoTo(nRecBTS))
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA955ALT

Alteração de registros no arquivo de vidas

@author Pls Team
@since 22/10/2012
/*/
//--------------------------------------------------------------------------------------------------

Function PLSA955ALT(lAutoma)
Local lEspelhar:=GetNewPar("MV_INTBTGB",.F.)
Local lAchou	:=.T.
Local lSinc:=.F.
	
Local lCentralObr := GetNewPar("MV_PLSEXCO",.F.)//Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
Local lUsaSIP := "1" $ GetNewPar("MV_PLSTIPO","")
Local lUsaSIB := "2" $ GetNewPar("MV_PLSTIPO","")
Local lSIPSincrono := "1" $ GetNewPar("MV_PLOBRSI","1,2")
Local lSIBSincrono := "2" $ GetNewPar("MV_PLOBRSI","1,2")
LOCAL lCritSib := .F.

Local aCritSib := {}
Local oModel := nil
Local aOpcSip := {}
Local aDadCob := {}
Local aCmpSipAux := {}
Local aDadCobJob := {}
Local cTipTit := GetNewPar("MV_PLCDTIT","T")
Local nDadCol := 0
Local cSQL := ""
Local cEndSA1 	 := ""
Local cNumSA1    := ""
Local cCodMunSA1 :=""
Local lCliente := .F.

Local nQtdBenef := 0
Local aChave := {}
Local aBA1HAT := {} 
Local aBTSHAT := {}

Default lAutoma := .F.

aGAreaBTS := BTS->(GetArea())
aGAreaBA1 := BA1->(GetArea())
aGAreaBA3 := BA3->(GetArea())

	If GetNewPar("MV_PLSHAT",Iif(!lAutoma, "0", "1")) == "1"  //efetuado o desvio no fonte, pois o parâmetro não conta no único e na base congelada
	
		aadd(aBTSHAT,{"BTS_MATVID",M->BTS_MATVID })
		aadd(aBTSHAT,{"BTS_CPFUSR",M->BTS_CPFUSR })
		aadd(aBTSHAT,{"BTS_NOMUSR",M->BTS_NOMUSR })
		aadd(aBTSHAT,{"BTS_DATNAS",M->BTS_DATNAS })
		aadd(aBTSHAT,{"BTS_SEXO"  ,M->BTS_SEXO   })
		aadd(aBTSHAT,{"BTS_NRCRNA",M->BTS_NRCRNA })
		aadd(aBTSHAT,{"BTS_CEPUSR",M->BTS_CEPUSR })
		aadd(aBTSHAT,{"BTS_CODMUN",M->BTS_CODMUN })
		aadd(aBTSHAT,{"BTS_EMAIL" ,M->BTS_EMAIL })
		aadd(aBTSHAT,{"BTS_NOMSOC",M->BTS_NOMSOC })
		Iif(!lAutoma, PLHATPedPD(MODEL_OPERATION_UPDATE,_persons_alt,"BTS",M->BTS_MATVID,aBTSHAT,1), "")
		
		aadd(aBA1HAT,{"BA1_MATVID",M->BTS_MATVID })
		aadd(aBA1HAT,{"BA1_CPFUSR",M->BTS_CPFUSR })
		aadd(aBA1HAT,{"BA1_NOMUSR",M->BTS_NOMUSR })
		aadd(aBA1HAT,{"BA1_DATNAS",M->BTS_DATNAS })
		aadd(aBA1HAT,{"BA1_SEXO"  ,M->BTS_SEXO   })
		aadd(aBA1HAT,{"BA1_CEPUSR",M->BTS_CEPUSR })
		aadd(aBA1HAT,{"BA1_CODMUN",M->BTS_CODMUN })
		aadd(aBA1HAT,{"BA1_NOMSOC",M->BTS_NOMSOC })
		
		Iif(!lAutoma,PLHATBenef(MODEL_OPERATION_UPDATE,nil,nil,nil,nil,nil,.T.,aBA1HAT),"")
	EndIf
	
	If lEspelhar
		DbSelectarea ("GBH")
		GBH->(DbSetOrder(8))
		
		If !Empty(M->BTS_MATVID) .and. GBH->(MsSeek(xFilial("GBH")+M->BTS_MATVID))
			lAchou:=.T.
		Else
			lAchou:= GBH->(MsSeek(xFilial("GBH")+M->BTS_MATVID))
		Endif
		If lAchou
			DbSelectarea ("BBL")
			BBL->(DbSetOrder(2))
			If 	BBL->(MsSeek(xFilial("BBL")+"PLSA955   "+"BTS"+"GBH"))
				RecLock("GBH", .F.)
				
				Do Case
				Case M->BTS_SEXO  == "1"
					GBH->GBH_SEXO:="0"
				Case M->BTS_SEXO == "2"
					GBH->GBH_SEXO:= "1"
				EndCase
				
				Do Case
				Case M->BTS_ESTCIV  == "C"
					GBH->GBH_ESTCIV :="0"
				Case M->BTS_ESTCIV == "S"
					GBH->GBH_ESTCIV:= "1"
				Case  M->BTS_ESTCIV== "D"
					GBH->GBH_ESTCIV:= "2"
				Case  M->BTS_ESTCIV== "M"
					GBH->GBH_ESTCIV:= "3"
				Case  M->BTS_ESTCIV== "V"
					GBH->GBH_ESTCIV:= "4"
				EndCase
				PlsSinc("PLSA955   ","BTS","GBH")
				MsUnlock()
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0029)) //"Arquivo de sincronismo entre BTS x GBH nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	Endif
	
	BA3->( dbSetorder(01) )
	
	//O seek na BA1 estava sendo desposicionado em algumas situações
	//com a query não será necessário mexer nos outros pontos
	cSQL := " SELECT R_E_C_N_O_ Recno FROM "  + RetSQLName("BA1") 
	cSQL += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
	cSQL += " AND   BA1_MATVID = '" + M->BTS_MATVID  + "' "
	cSQL += " AND " + RetSQLName("BA1") + ".D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBA1",.F.,.T.)
		
	If !TrbBA1->(Eof())

		WHILE !TrbBA1->(Eof())
			
			BA1->(DbGoTo(TrbBA1->Recno))
			
			cMatFam := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
			If BA3->( MsSeek(xFilial("BA3")+cMatFam))
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If 	BBL->(MsSeek(xFilial("BBL")+"PLSA955   "+"BTS"+"BA1"))
					RecLock("BA1", .F.)
					PlsSinc("PLSA955   ","BTS","BA1")
					BA1->(MsUnlock())
					lSinc:=.T.
				Endif
				
				//Rotina que trata e envia os dados dos beneficiários para a Central de Obrigações
				If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB)
				
					If PlSibEnvANS(BA3->BA3_TIPOUS,BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,BA1->BA1_VERCON,;
									BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_INFANS)
						
						aAreaBA1 := BA1->(GetArea())
						aAreaBA3 := BA3->(GetArea())
						aAreaBTS := BTS->(GetArea())
						//Primeiro monto o array com os dados do beneficiário oModel
						oModel := PlPrDadNio(aDadCob,,,lUsaSIP)
						If M->BTS_DATNAS >= STOD("20070101") .AND. Len(Alltrim(M->BTS_DENAVI)) == 11
							cDn := M->BTS_DENAVI
						Else
							cDn := ""
						EndIf
						oModel:SetValue( "B3KMASTER", 'B3K_DN', cDn)
						
						//Verifico se a linha do beneficiário foi excluida para passar essa informação para o NIO
						oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','2')

						//Chamo a rotina genérica que atualiza o Núcleo de Informações da Central de Obrigações
						If lSIPSincrono .OR. lSIBSincrono 
							
							cB3KMat	:= oModel:GetValue( "B3KMASTER", 'B3K_MATRIC')
							cNomBen	:= oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN')
							aAdd(aCritSib,{cB3KMat,cNomBen,""})
							
							PLCGrvBen( oModel,.F.,aCritSib )
							DelClassInf()
						Else
							aAdd(aCmpSIPAux,oModel)
							aAdd(aOpcSip,K_Alterar)
							aAdd(aDadCobJob,aDadCob)
						EndIf
						
						RestArea(aAreaBA3)
						RestArea(aAreaBA1)
						RestArea(aAreaBTS)
						
					EndIf
					
				EndIf

				cCepUsr := M->BTS_CEPUSR
				cEndere := M->BTS_ENDERE
				cBairro := M->BTS_BAIRRO
				cMunici := M->BTS_MUNICI
				cEstado := M->BTS_ESTADO
				cCodMun := M->BTS_CODMUN
				cNrEnd :=  M->BTS_NR_END
				cComend := M->BTS_COMEND
				cTipEnd := M->BTS_TIPEND
				cResExt := M->BTS_RESEXT
				
				//Atualiza endereço de beneficiários que tem a vida como origem dos dados de endereço
				If BA1->BA1_ORIEND $ ' ,4' .OR. (M->(Recno()) == BA1->(Recno()) .AND. M->BA1_ORIEND <> Nil .AND. M->BA1_ORIEND $ " ,4" )//4=Vida
					
					RecLock("BA1", .F.)
						BA1->BA1_CEPUSR := cCepUsr 
						BA1->BA1_ENDERE := cEndere 
						BA1->BA1_BAIRRO := cBairro 
						BA1->BA1_MUNICI := cMunici 
						BA1->BA1_ESTADO := cEstado 
						BA1->BA1_CODMUN := cCodMun 
						BA1->BA1_NR_END := cNrEnd 
						BA1->BA1_COMEND := cComend
						// Quando esses campos BA1_TIPEND/BA1_RESEXT estão em branco, la na Central entende que branco é default,
						// Ou seja, "2" e "0" respectivamente. Foi feito esse tratamento para enviar para central a alteração somente
						// quando o valor default (Branco ou 2 e 0) for alterado. 
						If !Empty(BA1->BA1_TIPEND) .Or. (Empty(BA1->BA1_TIPEND) .And. cTipEnd <> "2") 
							BA1->BA1_TIPEND := cTipEnd
						EndIf
						If !Empty(BA1->BA1_RESEXT) .Or. (Empty(BA1->BA1_RESEXT) .And. cResExt <> "0")
							BA1->BA1_RESEXT := cResExt
						EndIf
					BA1->(MsUnlock())
					
					//Habilita o uso do conceito de responsável pela família
					lResFam	:= GetNewPar("MV_PLRESFA",.F.) .AND. BA1->( FieldPos("BA1_RESFAM") ) > 0
					lTitular := BA1->BA1_TIPUSU == cTipTit
					lRespon := lResFam .AND. ( (BA1->BA1_RESFAM == '1' .AND. Empty(BA1->BA1_DATBLO) ) .OR. ( Empty(BA1->BA1_RESFAM) .AND. lTitular ) ) 
		
					//Se for titular, busco em todos os dependentes que puxam o endereço do titular
					If lRespon .OR. lTitular
										
						PlAtuEndTi(cMatFam,cCepUsr,cEndere,cBairro,;
									cMunici,cEstado,cCodMun,cNrEnd,cComend,;
									cTipEnd,cResExt)
					EndIf
					
					//Copio o Nome Social
					BA1->(RecLock("BA1", .F.))
						BA1->BA1_NOMSOC := M->BTS_NOMSOC
					BA1->(MsUnlock())
				EndIf

				// Atualiza o endereço de cobrança caso a familiar seja pelo titular e o beneficiario alterado seja o titular
				If BA3->BA3_ENDCOB = "2" .AND. BA1->BA1_TIPUSU == cTipTit //Cobrança atraves do titular
					BA3->(RecLock("BA3", .F.))
					PlsSinc("PLSA955   ","BTS","BA3")
					BA3->(MsUnlock())
				EndIf
				
				nQtdBenef++
				TrbBA1->(DbSkip())
							
			Else
				lSinc := .T. //Não há o que sincronizar se não tem BA3
				TrbBA1->(DbSkip())
			EndIf
		EndDo

		// Atualizo os dados do SA1 , caso tenha cadastro do beneficiario alterado
		If !Empty(BA1->BA1_CPFUSR)	
			SA1->(DbSetOrder(3))
			If SA1->(DbSeek(xFilial("SA1")+BA1->BA1_CPFUSR))
				SA1->(RecLock("SA1", .F.))
				PlsSinc("PLSA955   ","BTS","SA1")							
				SA1->(MsUnlock())
				lCliente := .T. // Achou
			Endif
		Else	
			SA1->(DbSetOrder(2))
			
			IF SA1->(DbSeek(xFilial("SA1")+BA1->BA1_NOMUSR))
				SA1->(RecLock("SA1", .F.))
				PlsSinc("PLSA955   ","BTS","SA1")
				SA1->(MsUnlock())
				lCliente := .T. // Achou
			Endif
		Endif

		If !Empty(SA1->A1_COD) .AND. !Empty(SA1->A1_LOJA) .AND. lCliente						
			
			cEndSA1 := SA1->A1_END
			If AT( ",", SA1->A1_END)
				ba3Num := StrTokArr(SA1->A1_END, ",")
				cEndSA1:= ba3Num[1]
				cNumSA1:= ba3Num[2]							
			Else
				cNumSA1 := Space(TamSX3("BA3_NUMERO")[1]) // Se não tiver numero deixa em branco	
			Endif							
				
			BID->( dbSetorder(02) )
			If BID->( msSeek(xFilial("BID")+Alltrim(Upper(SA1->A1_MUN))) )
				cCodMunSA1 := BID->BID_CODMUN 
			Endif

			// Procura as famílias vinculadas a este cliente e nesta familia verifica os beneficiários com o BA1_ORIEND=2
			AtuEndFam(SA1->A1_COD,SA1->A1_LOJA,SA1->A1_CEP,cEndSA1,SA1->A1_BAIRRO,;
						SA1->A1_MUN,SA1->A1_EST,cCodMunSA1,cNumSA1,SA1->A1_COMPLEM)
		EndIf
		
		If !lAutoma // Automação
			If Len(aCmpSipAux) > 0
				StartJob("PLJOBNIO",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
							"B3K",aCmpSIPAux,nOpcx,.T./*lMult*/,aOpcSip,;
							dDataBase,aDadCobJob)
			Else
				lCritSib := Len(aCritSib) > nQtdBenef
				If lCritSib
					PLSCRIGEN(aCritSib,{ {"Codigo Crit.","@C",5} , {"Descrição","@C",200 } , {"Solução","@C",200 } }, "  Críticas de Beneficiários  ")
					//Se não permite gravar beneficiário criticados, sai da rotina.
					If lCritSib .AND. !GetNewPar("MV_PLGRCRI",.T.)
						MsgAlert("Foram encontradas críticas do SIB no cadastro. Não será possível realizar a gravação.") 
						Return(.F.)
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		lSinc := .T. //Não há o que sincronizar se não tem BA1
	EndIf
	
	TrbBA1->(DbCloseArea())

    If lSinc                                 
	   aadd(aChave,{"BTS_NRCRNA",BTS->BTS_NRCRNA})
	   
	   Store Header "BTS" TO aHeader For .T.
	         
	   aCols := {}
	
	   AADD(aCols, Array(Len(aHeader)+1) )
	   
	   For nDadCol := 1 To Len(aHeader)               	
		 If aHeader[nDadCol][10] <> "V"
			aCols[1,nDadCol] := &("M->" + AllTrim(aHeader[nDadCol][2]))
		 Endif
	   Next
	
	   aVetTrab:= {BTS->(RECNO())}
	   
	   PLUPTCOLS("BTS",aCols,aHeader,aVetTrab,4,aChave,.F.)

	EndIf
	
	IF !lSinc
		If GetNewPar("MV_PLSMSGS","1") == "1"
			MsgAlert(OemtoAnsi(STR0030)) //"Arquivo de sincronismo entre BTS x BA1 nao esta integro. Verifique!"
			Return(.F.)
		Endif
	Endif

BTS->(RestArea(aGAreaBTS))
BA1->(RestArea(aGAreaBA1))
BA3->(RestArea(aGAreaBA3))

Return(.T.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlAtuEndTi

Replica a informação para os dependentes que usam o endereço do titular ou Responsável

@param cMatFam		Matrícula da Família
@param cCepUsr		Cep
@param cEndere		Logradouro
@param cBairro		Bairro
@param cMunici		Municipio
@param cEstado		Estado
@param cCodMun		Município de Residência. Preenchido quando o tipo de endereço é profissional
@param cNrEnd		Número
@param cComend		Complemento
@param cTipEnd 	Tipo de Endereço (Comercial/Residencial)
@param cResExt		Reside no exterior (Sim / Não)

@author everton.mateus
@since 16/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlAtuEndTi(cMatFam,cCepUsr,cEndere,cBairro,cMunici,cEstado,cCodMun,cNrEnd,cComend,cTipEnd,cResExt)
Local lRet			:= .T.
Local lCentralObr	:= GetNewPar("MV_PLSEXCO",.F.)//Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
Local lUsaSIP		:= "1" $ GetNewPar("MV_PLSTIPO","")
Local lUsaSIB		:= "2" $ GetNewPar("MV_PLSTIPO","")
Local lSIPSincrono	:= "1" $ GetNewPar("MV_PLOBRSI","1,2")
Local lSIBSincrono	:= "2" $ GetNewPar("MV_PLOBRSI","1,2")
Local cTipTit		:= SuperGetMv("MV_PLCDTIT")
Local aCritSib		:= {}
Local aCmpSIP		:= {}
Local aOpcSip		:= {}
Local aDadCob		:= {}
Local aCmpSipAux	:= {}
Local aDadCobJob	:= {}

Default cMatFam	:= ""
Default cCepUsr	:= ""
Default cEndere	:= ""
Default cBairro	:= ""
Default cMunici	:= ""
Default cEstado	:= ""
Default cCodMun	:= ""
Default cNrEnd	:= ""
Default cComend	:= ""
Default cTipEnd := ""
Default cResExt	:= ""

//Habilita o uso do conceito de responsável pela família
lResFam	:= GetNewPar("MV_PLRESFA",.F.) .AND. BA1->( FieldPos("BA1_RESFAM") ) > 0

aBTSArea := BTS->(GetArea())
aBA1Area := BA1->(GetArea())
aBA3Area := BA3->(GetArea())

BA1->(DbSetOrder(1))
If BA1->(dbSeek(xFilial("BA1")+cMatFam ) )
	
	Do While !BA1->(Eof()) .AND. cMatFam == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
		
		lTitular := BA1->BA1_TIPUSU == cTipTit
		lRespon := lResFam .AND. ( (BA1->BA1_RESFAM == '1' .AND. Empty(BA1->BA1_DATBLO) ) .OR. ( Empty(BA1->BA1_RESFAM) .AND. lTitular ) ) 
		
		If (BA1->BA1_ORIEND == '1' .AND. !lTitular) .OR.  (BA1->BA1_ORIEND == '5' .AND. !lRespon )   

			BA1->(RecLock("BA1", .F.))
				BA1->BA1_CEPUSR := cCepUsr 
				BA1->BA1_ENDERE := cEndere 
				BA1->BA1_BAIRRO := cBairro 
				BA1->BA1_MUNICI := cMunici 
				BA1->BA1_ESTADO := cEstado 
				BA1->BA1_CODMUN := cCodMun 
				BA1->BA1_NR_END := cNrEnd 
				BA1->BA1_COMEND := cComend
				// Quando esses campos BA1_TIPEND/BA1_RESEXT estão em branco, la na Central entende que branco é default,
				// Ou seja, "2" e "0" respectivamente. Foi feito esse tratamento para enviar para central a alteração somente
				// quando o valor default (Branco ou 2 e 0) for alterado.
				If !Empty(BA1->BA1_TIPEND) .Or. (Empty(BA1->BA1_TIPEND) .And. cTipEnd <> "2")
					BA1->BA1_TIPEND := cTipEnd 
				EndIf
				If !Empty(BA1->BA1_RESEXT) .Or. (Empty(BA1->BA1_RESEXT) .And. cResExt <> "0")
					BA1->BA1_RESEXT := cResExt
				EndIf 
			BA1->(MsUnlock())
		
		EndIf
		
		//Rotina que trata e envia os dados dos beneficiários para a Central de Obrigações
		If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB)
			
			If PlSibEnvANS(BA3->BA3_TIPOUS,BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,BA1->BA1_VERCON,;
							BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_INFANS)
				
				aAreaBA1 := BA1->(GetArea())
				aAreaBA3 := BA3->(GetArea())
				aAreaBTS := BTS->(GetArea())
				//Primeiro monto o array com os dados do beneficiário oModel
				oModel := PlPrDadNio(aDadCob,,,lUsaSIP)
				
				//Verifico se a linha do beneficiário foi excluida para passar essa informação para o NIO
				nOpcSip := K_Alterar
				
				oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','2')
				
				//Chamo a rotina genérica que atualiza o Núcleo de Informações da Central de Obrigações
				If lSIPSincrono .OR. lSIBSincrono 
					cMatric	:= oModel:GetValue( "B3KMASTER", 'B3K_MATRIC')
					cNomBen	:= oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN')
					aAdd(aCritSib,{cMatric,cNomBen,""})
					PLCGrvBen( oModel,.F.,aCritSib )
					DelClassInf()
				Else
					aAdd(oModelAux,oModel)
					aAdd(aOpcSip,nOpcSip)
					aAdd(aDadCobJob,aDadCob)
				EndIf
				
				RestArea(aAreaBA3)
				RestArea(aAreaBA1)
				RestArea(aAreaBTS)
				
			EndIf
		
		EndIf
		
		BA1->(DbSkip())
	EndDo
	
EndIf

BTS->(RestArea(aBTSArea))
BA1->(RestArea(aBA1Area))
BA3->(RestArea(aBA3Area))

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuEndFam

Replico os dados do endereço aonde a forma de cobrança é pelo cliente alterado, e replico para
os beneficiarios que tem o cliente como endereço 

@param cCodCli		Codigo do cliente no SA1
@param cLjCli		Loja do cliente no SA1
@param cCepUsr		Cep
@param cEndere		Logradouro
@param cBairro		Bairro
@param cMunici		Municipio
@param cEstado		Estado
@param cCodMun		Município de Residência. Preenchido quando o tipo de endereço é profissional
@param cNrEnd		Número
@param cComend		Complemento
@param cTipEnd 		Tipo de Endereço (Comercial/Residencial)
@param cResExt		Reside no exterior (Sim / Não)

@author vinicius.queiros
@since 07/10/2019
/*/
//--------------------------------------------------------------------------------------------------
Function AtuEndFam(cCodCli,cLjCli,cCepUsr,cEndere,cBairro,cMunici,cEstado,cCodMun,cNrEnd,cComend,cTipEnd,cResExt)
Local lRet			:= .T.
Local lCentralObr	:= GetNewPar("MV_PLSEXCO",.F.)//Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
Local lUsaSIP		:= "1" $ GetNewPar("MV_PLSTIPO","")
Local lUsaSIB		:= "2" $ GetNewPar("MV_PLSTIPO","")
Local lSIPSincrono	:= "1" $ GetNewPar("MV_PLOBRSI","1,2")
Local lSIBSincrono	:= "2" $ GetNewPar("MV_PLOBRSI","1,2")
Local aCritSib		:= {}
Local aCmpSIP		:= {}
Local aOpcSip		:= {}
Local aDadCob		:= {}
Local aCmpSipAux	:= {}
Local aDadCobJob	:= {}
Local cMatriFam		:= ""
Local cSQL		

Default cCodCli		:= ""
Default cLjCli		:= ""
Default cCepUsr		:= ""
Default cEndere		:= ""
Default cBairro		:= ""
Default cMunici		:= ""
Default cEstado		:= ""
Default cCodMun		:= ""
Default cNrEnd		:= ""
Default cComend		:= ""
Default cTipEnd 	:= ""
Default cResExt		:= ""

aBTSArea := BTS->(GetArea())
aBA1Area := BA1->(GetArea())
aBA3Area := BA3->(GetArea())

cSQL := " SELECT R_E_C_N_O_ Recno FROM "  + RetSQLName("BA3") 
cSQL += " WHERE BA3_FILIAL = '" + xFilial("BA3") + "' "
cSQL += " AND BA3_CODCLI = '" + cCodCli  + "' "
cSQL += " AND BA3_LOJA = '" + cLjCli  + "' "
cSQL += " AND BA3_ENDCOB = '1' "
cSQL += " AND " + RetSQLName("BA3") + ".D_E_L_E_T_ = ' ' "
	
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TSqlBA3",.F.,.T.)

// Se achar alguma familia que tem esse cliente como endereço de cobrança
If !TSqlBA3->(Eof())
	WHILE !TSqlBA3->(Eof())

		BA3->(DbGoTo(TSqlBA3->Recno))
		// Altero o endereço que tem o cliente que foi alterado
		BA3->(RecLock("BA3", .F.))
			BA3->BA3_CEP	:= cCepUsr 
			BA3->BA3_END 	:= cEndere 
			BA3->BA3_BAIRRO := cBairro 
			BA3->BA3_MUN    := cMunici 
			BA3->BA3_ESTADO := cEstado 
			BA3->BA3_CODMUN := cCodMun 
			BA3->BA3_NUMERO := cNrEnd 
			BA3->BA3_COMPLE := cComend  
		BA3->(MsUnlock())

		// Busca nessa familia se tem algum beneficiario que tem o endereço do cliente
		cSQL := " SELECT R_E_C_N_O_ Recno FROM "  + RetSQLName("BA1") 
		cSQL += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
		cSQL += " AND   BA1_CODINT= '" + BA3->BA3_CODINT  + "' "
		cSQL += " AND   BA1_CODEMP= '" + BA3->BA3_CODEMP + "' "
		cSQL += " AND   BA1_MATRIC= '" + BA3->BA3_MATRIC  + "' "
		cSQL += " AND   BA1_ORIEND= '2' "
		cSQL += " AND " + RetSQLName("BA1") + ".D_E_L_E_T_ = ' ' "
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BA1Trb",.F.,.T.)
			
		If !BA1Trb->(Eof())
			WHILE !BA1Trb->(Eof())
				BA1->(DbGoTo(BA1Trb->Recno))
				
				// Altera o endereço 
				BA1->(RecLock("BA1", .F.))
					BA1->BA1_CEPUSR := cCepUsr 
					BA1->BA1_ENDERE := cEndere 
					BA1->BA1_BAIRRO := cBairro 
					BA1->BA1_MUNICI := cMunici 
					BA1->BA1_ESTADO := cEstado 
					BA1->BA1_CODMUN := cCodMun 
					BA1->BA1_NR_END := cNrEnd 
					BA1->BA1_COMEND := cComend 	
					// Quando esses campos BA1_TIPEND/BA1_RESEXT estão em branco, la na Central entende que branco é default,
					// Ou seja, "2" e "0" respectivamente. Foi feito esse tratamento para enviar para central a alteração somente
					// quando o valor default (Branco ou 2 e 0) for alterado.			
					If !Empty(BA1->BA1_TIPEND) .Or. (Empty(BA1->BA1_TIPEND) .And. cTipEnd <> "2")
						BA1->BA1_TIPEND := cTipEnd 
					EndIf
					If !Empty(BA1->BA1_RESEXT) .Or. (Empty(BA1->BA1_RESEXT) .And. cResExt <> "0")
						BA1->BA1_RESEXT := cResExt
					EndIf 
				BA1->(MsUnlock())	
				
				//Rotina que trata e envia os dados dos beneficiários para a Central de Obrigações
				If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB)
					
					If PlSibEnvANS(BA3->BA3_TIPOUS,BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,BA1->BA1_VERCON,;
									BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_INFANS)
						
						aAreaBA1 := BA1->(GetArea())
						aAreaBA3 := BA3->(GetArea())
						aAreaBTS := BTS->(GetArea())
						//Primeiro monto o array com os dados do beneficiário oModel
						oModel := PlPrDadNio(aDadCob,,,lUsaSIP)
						
						//Verifico se a linha do beneficiário foi excluida para passar essa informação para o NIO
						nOpcSip := K_Alterar
						
						oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','2')
						
						//Chamo a rotina genérica que atualiza o Núcleo de Informações da Central de Obrigações
						If lSIPSincrono .OR. lSIBSincrono 
							cMatric	:= oModel:GetValue( "B3KMASTER", 'B3K_MATRIC')
							cNomBen	:= oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN')
							aAdd(aCritSib,{cMatric,cNomBen,""})
							PLCGrvBen( oModel,.F.,aCritSib )
							DelClassInf()
						Else
							aAdd(oModelAux,oModel)
							aAdd(aOpcSip,nOpcSip)
							aAdd(aDadCobJob,aDadCob)
						EndIf
						
						RestArea(aAreaBA3)
						RestArea(aAreaBA1)
						RestArea(aAreaBTS)
						
					EndIf
				
				EndIf
				
				BA1Trb->(DbSkip())
			EndDo
			
		EndIf
		
		BA1Trb->(DbCloseArea())	
		TSqlBA3->(DbSkip())
	EndDo	
EndIf

TSqlBA3->(DbCloseArea())

BTS->(RestArea(aBTSArea))
BA1->(RestArea(aBA1Area))
BA3->(RestArea(aBA3Area))
				
Return lRet

/*/{Protheus.doc} CNPJDUPLI
Verifica se existem CNPJ'S duplicado

@author  V.Alves
@version P12
@since   02.08.21
/*/
Static Function CNPJDUPLI(cCpfUsu)
	Local cQuery := ""
	Local nQtdReg:= 0
	Local lRet := .F.

	cQuery := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("SA2") + " SA2 "
	cQuery += " WHERE A2_FILIAL = '" + xFilial("SA2")+ "' "
	cQuery += " AND A2_CGC = '"+ cCpfUsu +"' "
	cQuery += "	AND D_E_L_E_T_ = ' '"

	nQtdReg := MPSysExecScalar(cQuery, "CONTADOR")

	If nQtdReg > 1
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} PLSValidMail
Verifica o e-mail

@author  r.soares
@version P12
@since   30.08.21
/*/
Function PLSValidMail(cCampo)

	Local lRet := .T.
	Local nCont := 0
	Local nQtdCaracteres := 0 
	Local nQtdArroba := 0
	Local cCaracter := ""
	Default cCampo := ""
	Default cEmail := cCampo

	If !Empty(cEmail)

		IIf(lRet , lRet := "@" 	$ cEmail ,.F.)
		IIf(lRet , lRet := "." 	$ cEmail ,.F.)
		IIf(lRet , lRet := Len(AllTrim(cEmail)) > 6	,.F.)

		nQtdCaracteres := Len(AllTrim(cEmail))

		For nCont := 1 TO nQtdCaracteres
			cCaracter := SUBSTR(AllTrim(cEmail), nCont, 1)
			If cCaracter $ "@"
				nQtdArroba++
			EndIf
		Next nCont

		IIf(lRet, lRet := nQtdArroba > 0 .And. nQtdArroba <= 1, .F.)
		
	Else
		lRet := .F.
	EndIf	

Return lRet

/*/{Protheus.doc} PLSValidCPF
Verifica o multi-número de CPF
Ex: '222.222.222-22', etc.
@author  r.soares
@version P12
@since   30.08.21
/*/
Function PLSMultiNum(cCampo)
	Local lRet := .T.
	If cCampo $ "00000000000/11111111111/22222222222/33333333333/44444444444/55555555555/66666666666/77777777777/88888888888/99999999999"
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} PLSValidCel
Verifica o Celular
@author  r.soares
@version P12
@since   08.09.21
/*/
Function PLSValidCel(cCampo)
	Local lRet := .T.
	If Len(AllTrim(cCampo)) < 9 .Or. substr(AllTrim(cCampo),1,1) != "9" .Or. Len(AllTrim(cCampo)) > 9
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} PLSValidTel
Verifica o Celular
@author  r.soares
@version P12
@since   08.09.21
/*/
Function PLSValidTel(cCampo)
	Local lRet := .T.
	If Len(AllTrim(cCampo)) < 8 .Or. Len(AllTrim(cCampo)) > 9
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} ExisMatVid
Verifica se a matrícula vinculada ao fornecedor
existe na tabela de vida.

@author  V.Alves
@version P12
@since   02.08.21
/*/
Static Function ExisMatVid(cMatVid)
	Local cQuery := ""
	Local nQtdReg:= 0
	Local lRet := .F.

	Default cMatVid := ""

	If SA2->(FieldPos("A2_MATVID")) > 0
		cQuery := " SELECT COUNT(*) Matricula FROM " + RetSQLName("SA2") + " SA2 "
		cQuery += " INNER JOIN " + RetSQLName("BTS") + " BTS "
		cQuery += " ON BTS.BTS_MATVID = SA2.A2_MATVID "
		cQuery += " AND SA2.A2_MATVID = '"+cMatvid+" ' "
		cQuery += "	AND BTS.D_E_L_E_T_ = ' ' "
		cQuery += "	AND SA2.D_E_L_E_T_ = ' ' "

		nQtdReg := MPSysExecScalar(cQuery, "Matricula")
	EndIf
	
	If nQtdReg >= 1
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/ {Protheus.doc} PlSetEpoch
Alteração do _SET_EPOCH da Rotina MVC

@author Giovanna Charlo
@since 14/01/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PlSetEpoch(nEpochNew)

	Default nEpochNew := Year(Date()) - 90

	SET(_SET_EPOCH, nEpochNew)

Return .T.  