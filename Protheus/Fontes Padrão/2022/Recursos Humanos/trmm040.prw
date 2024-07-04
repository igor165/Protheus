#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMM040.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ Trmm040  ³ Autor ³ Emerson Grassi Rocha    ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Lancamento Coletivo de Cursos Necessarios para os Cargos.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ Trmm040                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS   ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car. ³28/07/14³TPZWA0  ³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³             ³        ³        ³a limpeza.                                  ³±±
±±³Henrique V.  ³07/01/15³TRIBLH  ³Réplica do chamado TRFCNJ :Ajuste no campo  ³±±
±±³             ³        ³        ³Filial do controle de acesso, alterado      ³±±
±±³             ³        ³        ³tratamento da Filial para retornar cursos.  ³±±
±±³Oswaldo L   ³01/03/17³DRHPONTP-9³Nova funcionalidade de tabelas temporarias  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Function Trmm040

LOCAL cFiltra	:= ""				//Variavel para filtro
LOCAL aIndFil	:= {}				//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro 	:= OemtoAnsi(STR0004)		//"Lancamento coletivo de Cursos para Cargos"   
Private oTmpTabFO1
Private cTr1Alias := GetNextAlias()
Private o1Ok,oNo
Private aVetor := {}
oNo 	:= LoadBitmap( GetResources(), "LBNO" )
o1Ok 	:= LoadBitmap( GetResources(), "LBOK" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA1") 
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA1","1")
bFiltraBrw 	:= {|| FilBrowse("RA1",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA1") 
dbGoTop()

mBrowse(6, 1, 22, 75, "RA1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA1",aIndFil)
DeleteObject(oNo)
DeleteObject(o1Ok)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr040Lan      ³ Autor ³  Emerson Grassi  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa Lancamento Coletivo de Cursos para Cargos. 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr040Lan()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr040Lan(cAlias,nReg,nOpc)    

Local aSaveArea	:= GetArea()
Local aSays   	:= {}
Local aButtons	:= {}
Local nOpca		:= 0

Local cPerg	  		:= "TRX040"
Local cFunction		:= "TRMM040"
Local bProcess	  	:= {|oSelf| Tr040Rot( cAlias, nReg, nOpc, oSelf ) }
Local cDescription	:=	OemToAnsi(STR0018) +" "+;	//"Esta rotina permite a solicitacao coletiva de treinamento correspondente" 
						OemToAnsi(STR0019)			//"aos cargos escolhidos."

Private lAbortPrint := .F.                        

Pergunte("TRX040", .F.)

tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg) 

RestArea(aSaveArea)
Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr040Rot  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o Lancamento de Cursos.	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040Rot(cAlias,nReg,nOpc,oSelf)

Local aSaveArea	:= GetArea()
Local lRetorna	:= .T. 
Local aFields	:= {}
Local cChave	:= "" 
Local cCond		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar Enchoice                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCampos		:= {}
Local aNaoAlterar	:= {}
Local aAlteraveis   := {}
Local cCurso		:= RA1->RA1_CURSO  
Local cDescCurso 	:= RA1->RA1_DESC
Local cTitCurso		:= ""
Local cTitEntidade	:= ""
Local cTitData		:= ""
                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar Design da Tela                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlgMain
Local oOk 
Local c1Lbx   		:= "" 
Local n

Local aMostrar		:= {}
Local aAltera 		:= {"RA5_HORAS","RA5_VALIDA","RA5_NOTA","RA5_FREQUE","RA5_PRIORI","RA5_UNPRIO","RA5_EFICAC"}      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}
         

Local nOpca			:= 0


Private o1Lbx,oGet
Private oBtn1, oBtn2, oBtn3, oBtn4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Perguntas				                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private FilialDe	:= ""  	
Private FilialAte 	:= ""
Private CargoDe    	:= ""
Private CargoAte   	:= ""
Private CcDe      	:= ""
Private CcAte     	:= ""
Private GrupoDe   	:= ""
Private GrupoAte  	:= ""
Private DeptoDe   	:= ""
Private DeptoAte  	:= ""
Private Ordem     	:= 1


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar a GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]
Private aHeader	:= {}
Private aCols	:= {}
Private aTr1Rec	:= {}
Private Continua:= .F.
Private nUsado  := 0
Private lMostra	:= .F.
Private aVirtual:= {}	

Private nOpcx	:= nOpc //Opcao para somente poder alterar os campos
Private nOpcGet	:= nOpc

Private aColsVazio  := {}
Private nPosFilial	:= 0
Private nPosCargo	:= 0
Private nPosDesc	:= 0
Private nPosCC		:= 0
Private	nPosHoras	:= 0
Private	nPosValida	:= 0
Private	nPosNota	:= 0
Private	nPosFreque	:= 0
Private	nPosPriori	:= 0
Private	nPosUnPrio	:= 0
Private	nPosEficac	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados: Monta aHeader e aCols para receber Cargos selecionados         	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFields	:= Tr040NMostra()

Tr040Header(aFields)
nUsado 	:= Len(aHeader)

aCols	:= Array(1,nUsado+1) 
Tr040Cols(aFields)                        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados: Inicializa Vetor aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                              
aColsVazio  := aClone(aCols[1]) //Copia do Acols Vazio para inicializar 
nPosFilial	:= GdFieldPos( "RA5_FILIAL" ) 
nPosCargo	:= GdFieldPos( "RA5_CARGO" ) 
nPosDesc	:= GdFieldPos( "RA5_DESCCU" )
nPosCC		:= GdFieldPos( "RA5_CC" )
nPosHoras	:= GdFieldPos( "RA5_HORAS" ) 
nPosValida	:= GdFieldPos( "RA5_VALIDA" ) 
nPosNota	:= GdFieldPos( "RA5_NOTA" ) 
nPosFreque	:= GdFieldPos( "RA5_FREQUE" ) 
nPosPriori	:= GdFieldPos( "RA5_PRIORI" ) 
nPosUnPrio	:= GdFieldPos( "RA5_UNPRIO" ) 
nPosEficac	:= GdFieldPos( "RA5_EFICAC" ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Tratar Enchoice                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos		:= {}
aMostrar	:= {"RA5_CURSO","RA5_DESCCU","RA5_HORAS","RA5_VALIDA","RA5_NOTA","RA5_FREQUE","RA5_PRIORI","RA5_UNPRIO","RA5_EFICAC"}
aNaoAlterar := {"RA5_CURSO","RA5_DESCCU"} 
aAlteraveis := {}                
cTitCurso	:= ""
cTitEntidade:= ""
cTitData	:= ""

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("RA5") 

While ! Eof() .and. (X3_ARQUIVO == "RA5")

	If Ascan(aMostrar,Upper(Trim(x3_campo))) > 0
		Aadd(aCampos,Upper(Trim(x3_campo)))
	Endif
    
    If Ascan(aNaoAlterar,Upper(Trim(x3_campo))) == 0
		Aadd(aAlteraveis,Upper(Trim(x3_campo)))	                              
	Endif
    
	cCampo  	:= "M->"+X3_CAMPO
	cX3Campo 	:= "RA5->"+X3_CAMPO

	If x3_campo = "RA5_CURSO"  //Variaveis vindas do RA1
		&cCampo := cCurso 
        //-- Carrega o Titulo do campo RA5_Curso na lingua nativa
        //-- para ser utilizado no help se necessario
		cTitCurso:=X3Titulo()
	ElseIf x3_campo = "RA5_DESCCU" //Variaveis vindas do RA1
		&cCampo := cDescCurso 
    Else                     
       	IF x3_Tipo = "C"
			&cCampo := SPACE(x3_tamanho)
		ELSEIF  x3_Tipo  = "N"
			&cCampo := 0
		ELSEIF  x3_Tipo  = "D"
			&cCampo := CtoD("  /  /  ")
		ELSEIF  x3_Tipo  = "L"
			&cCampo := .F.
		ENDIF
	Endif

	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem Parametros para Selecao de Cargos			             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// MV_PAR01		- Filial De
// MV_PAR02		- Filial Ate
// MV_PAR03		- Cargo De
// MV_PAR04		- Cargo Ate
// MV_PAR05		- Centro Custo de
// MV_PAR06		- Centro Custo ate
// MV_PAR07		- Grupo De
// MV_PAR08     - Grupo Ate
// MV_PAR09		- Depto De
// MV_PAR10		- Depto Ate
// MV_PAR11     - Ordem 1-Cargo 2-Descricao

Pergunte("TRX040",.F.)

FilialDe  	:= xFilial("SQ3", MV_PAR01)
FilialAte 	:= MV_PAR02
CargoDe    	:= MV_PAR03
CargoAte   	:= MV_PAR04
CcDe      	:= MV_PAR05
CcAte     	:= MV_PAR06
GrupoDe   	:= MV_PAR07
GrupoAte  	:= MV_PAR08
DeptoDe   	:= MV_PAR09
DeptoAte  	:= MV_PAR10
Ordem     	:= MV_PAR11

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes de Selecao: Carrega Imagens                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oOk 	:= LoadBitmap( GetResources(), "Enable" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ListBox: Cria arquivo temporario                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tr040CriaArq()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ListBox: Preenche com Cargos Filtrados conforme Parametros   		           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lRetorna := Tr040Monta(cAlias,cCurso,oSelf)

//Verifica se foram encontrados funcionarios de acordo com os parametros
If !lRetorna
  
   Alert(OemtoAnsi(STR0005)) //"ATENCAO: Nao Foram Encontrados Cargos de Acordo com os Parametros Especificados "
   //-- Nao Foram Encontrados
   Fecha040(aSaveArea,oOK,oNo,o1OK)
   
   Return .F.
Endif
					 
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 060 , .T. , .F. } )				//1-Dados Curso
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )				//2-ListBox - Botoes - MsGetDados
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 0 , 0 }					 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. , .T. } )		//1-ListBox
aAdd( aObj1Coords , { 023 , 000 , .F. , .T. } )			//2-Botoes
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//3-MsGetDados
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

//Divisao da coluna 2-Botoes em 10 linhas
aAdv2Size		:= aClone(aObj1Size[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 10 }					 
For n:=1 to 10
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
Next n
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dialogo: Exibe Caixa para conter os objetos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgMain Title cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice: Exibe os gets de Entrada das Informacoes Compelementares             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Enchoice: Inicializa variaveis de memoria para Informacoes Complementares do Curso
dbSelectArea("RA5") 
dbSetOrder(1)

nOpca := EnChoice( "RA5", nReg, nOpcx ,,,,aCampos,aObjSize[1],aAlteraveis )
M->RA5_DESCCU	:= cDescCurso                          

@ aObj1Size[1,1],aObj1Size[1,2] LISTBOX o1Lbx VAR c1Lbx FIELDS ;
		 HEADER    						    "",;		//Em Branco para Selecao	
							OemtoAnsi(STR0006),;		//"Fil."
							OemtoAnsi(STR0008),;		//"Cargo"
							OemtoAnsi(STR0007),;		//"Descricao"
							OemtoAnsi(STR0009),;		//"Centro Custo"
							OemtoAnsi(STR0010);			//"Descr. Centro Custo"
		COLSIZES 			GetTextWidth(0,"W"),;
							GetTextWidth(0,REPLICATE("B",LEN((cTr1Alias)->(TR1_FILIAL)))),;
							GetTextWidth(0,REPLICATE("B",LEN((cTr1Alias)->(TR1_CARGO)))),;
							GetTextWidth(0,REPLICATE("B",LEN((cTr1Alias)->(TR1_DESC)))),;
							GetTextWidth(0,REPLICATE("B",LEN((cTr1Alias)->(TR1_CC)))),;			
							GetTextWidth(0,REPLICATE("B",LEN((cTr1Alias)->(TR1_DESCCC))));
					        SIZE aObj1Size[1,3],aObj1Size[1,4] OF oDlgMain PIXEL
	  
	o1Lbx:nFreeze := 3
	
	o1Lbx:SetArray(aVetor)
	o1Lbx:bLine:= {||{  		    aVetor[o1Lbx:nAt,1],;
									aVetor[o1Lbx:nAt,2],;
									aVetor[o1Lbx:nAt,3],;
									aVetor[o1Lbx:nAt,4],;
									aVetor[o1Lbx:nAt,5],;
									aVetor[o1Lbx:nAt,6]  }	}						
							
	o1Lbx:Hide()                           
	o1Lbx:Show()                           
	o1Lbx:Refresh()	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados: Exibe aHeader e aCols para funcionarios selecionados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGet  := MSGetDados():New(aObj1Size[3,1],aObj1Size[3,2],aObj1Size[3,3],aObj1Size[3,4],nOpc,"Tr040LinOK()","Tr040AllOK()"," "	,.F.,aAltera,1)
				
//-- Botoes de Movimentacao de Funcionario				
oBtn1 := TBitmap():New(aObj2Size[1,1],aObj2Size[1,2],25,25,,"NEXT",.T.,oDlgMain ,;
                {||fMoveToGet(.F.,@aVetor)},,,,,,,,.T.,,)
oBtn1:CTOOLTIP := STR0015 //##"Mover Funcionario"

oBtn3 := TBitmap():New(aObj2Size[2,1],aObj2Size[2,2],25,25,,"PREV",.T.,oDlgMain ,;
               {||fMoveToList(.F.,@aVetor)},,,,,,,,.T.,,)
oBtn3:CTOOLTIP := STR0015 //##"Mover Funcionario"

  
oBtn2 := TBitmap():New(aObj2Size[3,1],aObj2Size[3,2],25,25,,"PGNEXT",.T.,oDlgMain ,;
            {||Processa({||fMoveToGet(.T.,@aVetor)},OemToAnsi(STR0022)+OemToAnsi(STR0025))},,,,,,,,.T.,,)	//"Aguarde..."##"Movendo Funcionarios"#  
oBtn2:CTOOLTIP := STR0015 //##"Mover Funcionario"

oBtn4 := TBitmap():New(aObj2Size[4,1],aObj2Size[4,2],25,25,,"PGPREV",.T.,oDlgMain ,;
           {||Processa({||fMoveToList(.T.,@aVetor)},OemToAnsi(STR0022)+OemToAnsi(STR0025))},,,,,,,,.T.,,)	//"Aguarde..."##"Movendo Funcionarios"#	  
oBtn4:CTOOLTIP := STR0015 //##"Mover Funcionario"

nOpca := 0      

ACTIVATE MSDIALOG oDlgMain  On INIT ( Tr040OnOff(.T.),Tr040OnOff(.F.),;
									 	EnchoiceBar	(oDlgMain,;
											 			{|| If(Tr040Grava("RA5",cCurso),oDlgMain:End(),Nil)},;
														{|| If(Tr040Sai(),oDlgMain:End(),Nil)};
											 		);
									)

Fecha040(aSaveArea,oOK,oNo,o1OK)

Return Nil   

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fecha040  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Finaliza TRMM040	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Fecha040(aSaveArea,oOK,oNo,o1OK)

dbSelectArea(cTr1Alias)
dbCloseArea()

      
dbSelectArea("SQ3") 
Set Filter To
RetIndex("SQ3") 
dbSetOrder(1)


If oTmpTabFO1 <> Nil
    oTmpTabFO1:Delete()
    Freeobj(oTmpTabFO1)
EndIf 

DeleteObject(oOk)

RestArea(aSaveArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr040Exc      ³ Autor ³  Emerson Grassi  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa Exclusao de Lancamento Coletivo de Cursos.	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr040Exc()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr040Exc()

Local aSaveArea	:= GetArea()    
Local aSays   	:= {}
Local aButtons	:= {}
Local nOpca	  		:= 0
Local nResultado	:= 0        
Local cPerg	   		:= "TRX040"    
Local cFunction		:= "TRMM040"
Local bProcess	  	:= {|oSelf| nOpca:= 1, nResultado:=Tr040E(oSelf)}
Local cDescription	:=	OemToAnsi(STR0030) +" "+;	//"Esta rotina eliminará os lancamentos coletivo de Cursos correspondentes"
						OemToAnsi(STR0031) 			//"aos Cargos escolhidos."


Private cCadastro   := OemToAnsi(STR0029) // "Eliminacao de Registros de Treinamento Coletivo" 

tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg)   

IF nOpca == 1
	ApMSGInfo(STR0012+Trim(Str(nResultado)),STR0011)
EndIF

RestArea(aSaveArea)
Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr040E        ³ Autor ³Emerson Grassi    ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui cursos de Cargos de forma Coletiva   	          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr040E  ()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040E(oSelf)
Local aSaveArea		:= GetArea()
Local nEliminados	:= 0       


//-- Variavel para Controle de Acesso as informacoes dos cursos dos cargos
Local cAcessaRA5	:= &("{ || " + ChkRH(FunName(),"RA5","2") + "}")

//-- Variaveis para  Obter Parametros
Local FilialDe  := xFilial("RA5", MV_PAR01)
Local FilialAte	:= MV_PAR02
Local CargoDe  	:= MV_PAR03
Local CargoAte 	:= MV_PAR04
Local CcDe     	:= MV_PAR05
Local CcAte    	:= MV_PAR06
Local GrupoDe   := MV_PAR07
Local GrupoAte  := MV_PAR08
Local DeptoDe   := MV_PAR09
Local DeptoAte  := MV_PAR10
Local Ordem     := MV_PAR11

Local cCurso	:= RA1->RA1_CURSO  
Local lCursoComp :=	.F.	 //Tabela Curso é Compartilhada?  

If FWModeAccess("RA1",3)=="C"
	lCursoComp := .T.
EndIf

dbSelectArea("RA5") 
dbSetOrder(2)
dbGoTop()
    
oSelf:SetRegua1(RA5->(Reccount()))
oSelf:SaveLog(STR0004 + ": " + STR0023 + " - " + STR0032)	//"Inicio do Processamento"

While !Eof() .and. ( RA5->RA5_FILIAL + RA5->RA5_CARGO + RA5->RA5_CC + RA5->RA5_CURSO ) < ( FilialAte + CargoAte + CcAte + cCurso )

	If RA5->RA5_CURSO !=  cCurso 	
		dbSkip()
		Loop
	EndIf

	oSelf:IncRegua1(OemToAnsi(STR0022)+OemToAnsi(STR0028)) //"Aguarde..."###" Excluindo Registros ...."
	oSelf:SetRegua2(1)   
	oSelf:IncRegua2(STR0013+" / "+STR0007+": "+RA5->RA5_FILIAL+" / "+Left(RA5->RA5_CARGO,25)) // Filial / Cargo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas				 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(xFilial("RA5",RA5->RA5_FILIAL) $ fValidFil()) .Or. !Eval(cAcessaRA5)
       dbSkip()
       Loop
    EndIf

	If 	RA5->RA5_CARGO 		< CargoDe 	.Or. RA5->RA5_CARGO	> CargoAte 	.Or.;
		RA5->RA5_CC 		< CcDe 		.Or. RA5->RA5_CC 		> CcAte
		dbSkip()
		Loop
	EndIf
	
	If !(lCursoComp) .AND. !(RA5->RA5_FILIAL == xFilial("RA5",RA5->RA5_FILIAL))
		dbSkip()
        Loop	
	EndIf
    
 	nEliminados++
  	RecLock("RA5",.F.)  
   		RA5->(DbDelete())
   	RA5->(MsUnlock())
		  
	dbSelectArea("RA5")
	dbSkip()
EndDo

oSelf:SaveLog(STR0004 + ": " + STR0023 + " - " + STR0033)	// "Término do Processamento"
 
dbSelectArea("RA5")
dbSetOrder(1)
     
RestArea(aSaveArea)

Return nEliminados

                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr040Monta³ Autor ³ Emerson Grassi Rocha ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox da reserva dos treinamentos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr040Monta(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC2 : Codigo do Curso                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040Monta(cAlias,cCurso,oSelf) 
Local aSaveArea := GetArea()
Local lRet		:= .T.
Local cIndCond 	:= ""
Local cFor		:= ""
Local cDescCC	:= ""
Local cDescFunc	:= ""   
Local nBMarca	:= 0
Local nBConcl	:= 0
Local nIndex	:= 0
Local cGrupo	:= ""
Local cDepto	:= ""
Local cAcessaSQ3:= &("{ || " + ChkRH(FunName(),"SQ3","2") + "}")
Local lTrataFil := .T.	//Se Filial vazia -> Não Tratar 
Local lGC		:= fIsCorpManage( FWGrpCompany() ) //Verifica se possui Gestao Corporativa
Local lCursoComp :=	.F.	 //Tabela Curso é Compartilhada?
Local oTmpTesTabFO1
Local cTrTesAlias := GetNextAlias()
Local nTotLoop
Local nLoop
Local aFields := {}
Local __aStruSQ3__

If !(lGC) .OR. FWModeAccess("SQ3",1)=="C" .AND. FWModeAccess("SQ3",2)=="C" .AND. FWModeAccess("SQ3",3)=="C"
	lTrataFil := .F.
EndIf

If FWModeAccess("RA1",3)=="C"
	lCursoComp := .T.
EndIf
                    
dbSelectArea("SQ3") 
dbGoTop()

If Ordem == 1	       // Cargo
	dbSetOrder(1)
	cIndCond    := "Q3_FILIAL+Q3_CARGO+Q3_CC"
	cFor		:= '(Q3_FILIAL+Q3_CARGO+Q3_CC >="'
	cFor		+=  FilialDe+CargoDe+CcDe+'") .And.'
	cFor		+= '(Q3_FILIAL+Q3_CARGO+Q3_CC <="'
	cFor		+=  FilialAte+CargoAte+CcAte+'")'
	
ElseIf Ordem == 2		// Descricao
	dbSetOrder(3)
	cIndCond    := "Q3_FILIAL+Q3_DESCSUM+Q3_CC"
	cFor		:= '(Q3_FILIAL+Q3_CARGO+Q3_CC >="'
	cFor		+=  FilialDe+CargoDe+CcDe+'") .And.'
	cFor		+= '(Q3_FILIAL+Q3_CARGO+Q3_CC <="'
	cFor		+=  FilialAte+CargoAte+CcAte+'")'
EndIf	

DbSelectarea('SQ3')

__aStruSQ3__ := SQ3->(dbStruct())
nTotLoop	:= Len(__aStruSQ3__)  

For nLoop:=1 To nTotLoop
	AADD(aFields,{	__aStruSQ3__[nLoop,1]   ,;
       		        __aStruSQ3__[nLoop,2]  	,;
			        __aStruSQ3__[nLoop,3]  	,;
			        __aStruSQ3__[nLoop,4]    }    )  
Next

oTmpTesTabFO1 := RhCriaTrab(cTrTesAlias, aFields, Nil)

IndRegua("SQ3",cTrTesAlias,cIndCond,,cFor,,.F.)		//"Selecionando Registros..."
nIndex := RetIndex("SQ3") 

#IFNDEF TOP
	dbSetIndex(cTrTesAlias+OrdBagExt())
#ENDIF                              

dbSetOrder(nIndex+1)    
dbGoTop()

oSelf:SetRegua1(SQ3->(Reccount()))
oSelf:SaveLog(STR0004 + ": " + STR0003 + " - " + STR0032)	//"Inicio do Processamento"
aVetor := {} //sempre re-inicializar array

While !Eof() 	
                
	oSelf:IncRegua1(OemToAnsi(STR0022)+OemToAnsi(STR0021)) //"Aguarde..."###" Montando tela de Registro de Treinamentos" 
	oSelf:SetRegua2(1)   
	oSelf:IncRegua2(STR0013+" / "+STR0008+": "+SQ3->Q3_FILIAL+" / "+SQ3->Q3_CARGO+" - "+Left(SQ3->Q3_DESCSUM,25)) // Filial / Cargo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas				 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lTrataFil)
	    If !(Alltrim(xFilial("SQ3",SQ3->Q3_FILIAL)) $ fValidFil()) .Or. !Eval(cAcessaSQ3)
			dbSkip()
			Loop
    	EndIf 
    Else
   	 	If !(xFilial("SQ3",SQ3->Q3_FILIAL) $ fValidFil()) .Or. !Eval(cAcessaSQ3)
			dbSkip()
			Loop
    	EndIf	
    EndIf
    
	If 	SQ3->Q3_FILIAL 	< FilialDe 	.Or. SQ3->Q3_FILIAL	> FilialAte	.Or.;
		SQ3->Q3_CARGO 	< CargoDe 	.Or. SQ3->Q3_CARGO 	> CargoAte 	.Or.;
 		SQ3->Q3_CC 		< CCDe 		.Or. SQ3->Q3_CC 	> CCAte		.Or.;
		SQ3->Q3_GRUPO	< GrupoDe	.Or. SQ3->Q3_GRUPO	> GrupoAte	.Or.;
		SQ3->Q3_DEPTO	< DeptoDe	.Or. SQ3->Q3_DEPTO	> DeptoAte
       
		dbSkip()
		Loop
	EndIf
	
	If  !(lCursoComp)
		If !(SQ3->Q3_FILIAL $ xFilial())  //Referente a Filial Logada - Se a Tabela curso for compartilhada, entao, trata somente empresa e unidade de negocio
			dbSkip()
       		Loop
        EndIf	
	EndIf
		
	nBMarca 	:= 1
	nBConcl		:= 1
	
	// Verificando se ja tem Solicitacao
	dbSelectArea("RA5")
	dbSetOrder(2)
	If dbSeek(SQ3->Q3_FILIAL+SQ3->Q3_CARGO+SQ3->Q3_CC+cCurso) 
	    
		nBConcl:= 2
	EndIf

	dbSelectArea("SQ3")
	cDescCC	 := FDesc("CTT", SQ3->Q3_CC, "CTT->CTT_DESC01", 30)
	
	RecLock(cTr1Alias,.T.)  

	(cTr1Alias)->(TR1_MARCA)		:= nBMarca
	(cTr1Alias)->(TR1_FILIAL)		:= SQ3->Q3_FILIAL
	(cTr1Alias)->(TR1_CARGO)		:= SQ3->Q3_CARGO
	(cTr1Alias)->(TR1_DESC)		:= SQ3->Q3_DESCSUM
	(cTr1Alias)->(TR1_CC)			:= SQ3->Q3_CC
	(cTr1Alias)->(TR1_DESCCC)		:= cDescCC
		
	(cTr1Alias)->(MsUnlock()	)
	
	Aadd( aVetor, {If(		(cTr1Alias)->(TR1_MARCA)==1,o1Ok,oNo),;
							(cTr1Alias)->(TR1_FILIAL),;
							(cTr1Alias)->(TR1_CARGO),;
							(cTr1Alias)->(TR1_DESC),;
							(cTr1Alias)->(TR1_CC),;
							(cTr1Alias)->(TR1_DESCCC)} )
								
	
	dbSelectArea("SQ3")
	dbSkip()
EndDo 

oSelf:SaveLog(STR0004 + ": " + STR0003 + " - " + STR0033)	//"Término do Processamento"

//-- Se nao foram encontrados funcionarios de acordo com os parametros passados
//-- retorna .f. para abandonar rotina
If (cTr1Alias)->(LastRec()) < 1
	lRet:=.F.
Endif          

dbSelectArea(cTr1Alias)
dbGotop()


If oTmpTesTabFO1 <> Nil
    oTmpTesTabFO1:Delete()
    Freeobj(oTmpTesTabFO1)
EndIf 

RestArea(aSaveArea)

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr040CriaArq³ Autor ³Emerson Grassi Rocha ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria arquivo para gravar os dados do listbox 2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040CriaArq()
Local a1Stru	:= {}
Local aSaveArea	:= GetArea()
Local cCond		:= ""
Local aLstIndices := {}

Aadd(a1Stru,{"TR1_MARCA",  "N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_FILIAL", "C", FWGETTAMFILIAL,          0                       } )
Aadd(a1Stru,{"TR1_CARGO",  "C", TamSx3("Q3_CARGO")[1],   TamSx3("Q3_CARGO")[2]    } )
Aadd(a1Stru,{"TR1_DESC",   "C", TamSx3("Q3_DESCSUM")[1], TamSx3("Q3_DESCSUM")[2]     } )
Aadd(a1Stru,{"TR1_CC",     "C", TamSx3("Q3_CC")[1],      TamSx3("Q3_CC")[2]      } )
Aadd(a1Stru,{"TR1_DESCCC", "C", TamSx3("CTT_DESC01")[1], TamSx3("CTT_DESC01")[2] } )

//Ordem 1-Cargo 2-Descricao 

If Ordem == 1				// Nome
    Aadd( aLstIndices,{"TR1_FILIAL","TR1_CARGO","TR1_CC"} )
ElseIf Ordem == 2			// Matricula
    Aadd( aLstIndices,{"TR1_FILIAL","TR1_DESC","TR1_CC"} )
EndIf

oTmpTabFO1 := RhCriaTrab(cTr1Alias, a1Stru, aLstIndices)	

RestArea(aSaveArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr040OnOff    ³ Autor ³ Emerson Grassi   ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ LigaDesliga Botoes	                 			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr040OnOff()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA0040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040OnOff(lPrev)

Default lPrev:=.T.
//-- Se o Botao NEXT chamou a funcao
If !lPrev   
	//-- Se Todos os Funcionarios foram movidos para o GetDados
   	If Len(aCols)==(cTr1Alias)->(Lastrec()) .AND. !Empty(aCols[1,nPosCargo])                       
	    //-- Habilita Botoes PREV
		oBtn3:lReadOnly:=.F.
	    oBtn4:lReadOnly:=.F. 
		//-- Desabilita Botoes NEXT
	    oBtn1:lReadOnly:=.T.
		oBtn2:lReadOnly:=.T. 
	//-- Habilita Todos os Botoes somente se houver pelo menos 1 funcionario escolhido
	ElseIf Len(aCols)>0 .AND. !Empty(aCols[1,nPosCargo])
		//-- Habilita Botoes PREV  
		oBtn3:lReadOnly:=.F.
		oBtn4:lReadOnly:=.F. 
		//-- Habilita Botoes NEXT
		oBtn1:lReadOnly:=.F.
		oBtn2:lReadOnly:=.F.  
	Endif   
//-- Se o Botao PREV chamou a funcao                   
Else 
	//-- Se o GetDados Possui Apenas uma linha em branco)
	If Len(aCols)==1 .AND. Empty(aCols[1,nPosCargo])
		//-- Desabilita Botoes PREV
		oBtn3:lReadOnly:=.T.
		oBtn4:lReadOnly:=.T.
		//-- Habilita Botoes NEXT
		oBtn1:lReadOnly:=.F.
		oBtn2:lReadOnly:=.F. 
	ElseIf Len(aCols)>0 .AND. !Empty(aCols[1,nPosCargo])
		//-- Habilita Botoes PREV  
		oBtn3:lReadOnly:=.F.
		oBtn4:lReadOnly:=.F. 
		//-- Habilita Botoes NEXT
		oBtn1:lReadOnly:=.F.
		oBtn2:lReadOnly:=.F.  
	Endif     
Endif

Return(Nil)          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr040Header³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria o Array Aheader                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Trmm040		                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040Header(aNaoMostrar)
Local aSaveArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define aHeader para GetDados                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")                  
dbSetOrder(1)
dbSeek("RA5") 
nUsado := 0
While !EOF() .And. (x3_arquivo == "RA5") 
	lMostra:=ASCAN(aNaoMostrar,Trim(x3_campo)) == 0
	//-- Forca Mostrar campos
	IF  ( (x3Uso(x3_Usado) .AND. lMostra)   .OR. (!x3Uso(x3_Usado).AND. lMostra) );
		.AND.   cNivel >= x3_nivel
		nUsado++
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_arquivo } )
	Endif
	dbSkip()
EndDo
RestArea(aSaveArea)	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr040Cols  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa o Array aCols                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Trmm040		                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040Cols(aNaoMostrar)
Local aSaveArea	:= GetArea() 
Local nElem		:= Len(aCols)

nUsado := 0
dbSelectArea("SX3")   
dbSetOrder(1)
dbSeek("RA5") 
While !EOF() .And. (x3_arquivo == "RA5") 
	lMostra:=ASCAN(aNaoMostrar,Trim(x3_campo)) == 0
	//-- Forca Mostrar campos
	IF  ( (x3Uso(x3_Usado) .AND. lMostra)   .OR. (!x3Uso(x3_Usado).AND. lMostra) );
		.AND.   cNivel >= x3_nivel
		nUsado++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de 1 elemento vazio. Se inclus†o.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If x3_context == "V"
			aCOLS[nElem][nUsado] := CriaVar(AllTrim(x3_campo))
			Aadd ( aVirtual , AllTrim(x3_campo) )
		Endif
		IF x3_tipo == "C"
			aCOLS[nElem][nUsado] := SPACE(x3_tamanho)
		ELSEIF x3_tipo == "N"
			aCOLS[nElem][nUsado] := 0
		ELSEIF x3_tipo == "D"
			aCOLS[nElem][nUsado] := CTOD("")
		ELSE
			aCOLS[nElem][nUsado] := .F.
		Endif
	Endif
	dbSkip()
EndDo

aCOLS[nElem,nUsado+1] := .F. 

RestArea(aSaveArea)	
Return .T.	

 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr040AllOk³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Gets de Todas as Linhas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr040AllOk()
Local lRet	:= .T.

Return lRet
      
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr040LinOk³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Gets da Linha                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr040LinOk()
Local lRet	:= .T.
//Nao permite Cargo em Branco (Linha Vazia)
If Empty(aCols[n,nPosCargo]) 
   lRet	:= .F.
Endif
Return lRet
 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr040Grava³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC1 : Codigo curso                                       ³±± 
±±³          ³ ExpL2 : Sobrepoe Registro Gerado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA201                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040Grava(cAlias,cCurso)

Local aSaveArea	:= GetArea()
Local ny        := 0  
Local nZ        := 0
Local ni		:= 0
Local nMaxArray := Len(aHeader)
Local naCols    := Len(aCols) 
Local xConteudo	:= ""   
Local lAppenda	:= .T.
Local nCpos		:= 0
Local cCampo	:= ""
Local cVar		:= ""

If Len(aCols)=1 .AND. Empty(aCols[1,nPosCargo])
   Alert(OemtoAnsi(STR0024)) //## "Funcionarios Nao Selecionados"
   Return(.F.)
Endif

//-- Abre inicio da transacao de gravacao e eliminacao de itens
Begin Transaction

    dbSelectArea("RA5") 
	dbSetOrder(2)
	
	For nZ := 1 TO naCols   
	    //--Despreza marcados como deletados
		If aCols[nZ,nUsado+1] 
			Loop
		Endif
	
		lAppenda 	:= .T.
		
        //-- Posiciona no Curso 
		If RA5->(dbSeek(aCols[nz,nPosFilial]+aCols[nz,nPosCargo]+aCols[nz,nPosCC]+cCurso))
			lAppenda	:= .F.
	    EndIf		
    
		RecLock("RA5",lAppenda)
			
			// Grava informacoes genericas da Enchoice
			nCpos := FCount()
			For ni := 1 To nCpos 
				cCampo 	:= "RA5->"+FieldName(ni)
				cVar	:=	"M->"+FieldName(ni)
				&cCampo	:= &cVar
			Next ni
			
			// Grava informacoes individuais da GetDados
			For ny := 1 To nMaxArray
				cCampo    := Trim(aHeader[ny][2])
				//-- Grava Campos Nao Virtuais
				If Ascan(aVirtual,cCampo) == 0
					xConteudo := aCols[nZ,ny]
					RA5->&cCampo := xConteudo
				Endif 
			Next ny                              
	
		RA5->( MsUnlock() )

	Next nZ
   	
End Transaction
RestArea(aSaveArea) 
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr040Sai  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se abandona Rotina                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trmm040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040Sai()
Local lRet:=.T.
//-- Se existir pelo menos 1 funcionario selecionado 
If Len(aCols)>0 .AND. !Empty(aCols[1,nPosCargo])
	//-- Verifica Se NAO Abandona, entao, retorna a geracao de treinamentos coletivos
	If !MsgYesNo(OemtoAnsi(STR0027),OemtoAnsi(STR0014)) //#"Confirma Abandono da rotina?" #"Aten‡„o"
	   lRet:=.F.
	Endif   
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fMoveToGet    ³ Autor ³Emerson Grassi    ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Move Funcionario para oGetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMoveToGet(lTodos)                                         ³±±
±±³          ³            lTodos         .T. move Todos os Funcionarios.  ³±±
±±³          ³                           .F. move Funcinario Atual.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function fMoveToGet(lTodos)                
Local aSaveArea	:= GetArea()
Local nAnterior	:= 0
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.
Local nLi		:= Len(aCols)   
Local nRecTr1Alias      := 0 
Default lTodos	:= .F.

dbSelectArea(cTr1Alias) 
nRecno	:= nInicio	:= o1Lbx:nAt

//-- Determina a Abrangencia
If lTodos
   dbGoTop()               
   nFim		:= Len(aVetor)
   nInicio	:= 1
    //-- Implementa Regua somente para movimentacao coletiva
   ProcRegua(nFim)
Else
   nFim:=o1Lbx:nAt
Endif     

//--Marca Funcionarios de Acordo com a Abrangencia (Todos ou especifico)
For nRec:=nInicio To nFim
	//-- Incrementa Regua somente para movimentacao coletiva
	If lTodos
		IncProc()
	Endif
	If aVetor [nRec][1] == o1Ok 
		//-- Adiciona Funcionario
		//-- Altera Cor indicando que funcionario foi selecionado
		nRecTr1Alias := Tr040Marca(@aVetor, nRec, .T.)  
		dbSelectArea(cTr1Alias)
		
		If !Empty(aCols[1,nPosCargo]) //Na primeira vez, o campo estah em branco
			AADD(aCols,aClone(aColsVazio))
		Endif
		//-- Obtem o ultimo Elemento do aCols
		nLi:=Len(aCols)
		//-- Preenche-o com as informacoes
		Iif(nPosFilial 	> 0, aCols[nli,nPosFilial]	:= aVetor[nRec,2]	, Nil)
		Iif(nPosCargo 	> 0, aCols[nli,nPosCargo]	:= aVetor[nRec,3]	, Nil)
		Iif(nPosDesc	> 0, aCols[nli,nPosDesc]	:= aVetor[nRec,4]	, Nil)
		Iif(nPosCC		> 0, aCols[nli,nPosCC]		:= aVetor[nRec,5]		, Nil)
		
		// Padrao vindo da Enchoice
		Iif(nPosHoras	> 0, aCols[nli,nPosHoras]	:= M->RA5_HORAS	, Nil)
		Iif(nPosValida	> 0, aCols[nli,nPosValida]	:= M->RA5_VALIDA	, Nil)
		Iif(nPosNota	> 0, aCols[nli,nPosNota]	:= M->RA5_NOTA		, Nil)
		Iif(nPosFreque	> 0, aCols[nli,nPosFreque]	:= M->RA5_FREQUE	, Nil)
		Iif(nPosPriori	> 0, aCols[nli,nPosPriori]	:= M->RA5_PRIORI	, Nil)
		Iif(nPosUnPrio	> 0, aCols[nli,nPosUnPrio]	:= M->RA5_UNPRIO	, Nil)
		Iif(nPosEficac	> 0, aCols[nli,nPosEficac]	:= M->RA5_EFICAC	, Nil)
		
		//-- Armazena o Recno da origem das informacoes da linha da GetDados
		AADD(aTr1Rec, {aVetor[nRec,2],aVetor[nRec,3], nRecTr1Alias/*foi posicionado no tr020marca*/ } )
     
		lRet:=.T.
	Endif
	
Next nRec


RestArea(aSaveArea)

o1Lbx:Refresh(.T.)
o1Lbx:DrawSelect()
nAnterior	:= n 
oGet:ForceRefresh()      
n	:= nAnterior           

//-- Liga/Desliga botoes
Tr040OnOff(.F.)

Return lREt         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fMoveToList   ³ Autor ³Emerson Grassi    ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Move Funcionario para  ListBox                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMoveToList(lTodos)                                        ³±±
±±³          ³            lTodos         .T. move Todos os Funcionarios.  ³±±
±±³          ³                           .F. move Funcinario Atual.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function fMoveToList(lTodos,aVetor)                
Local aSaveArea	:= GetArea()
Local nPosicao	:= 0
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.    
Local nListN	:= o1Lbx:nAt

//-- Se Nao Existirem elementos no GetDados nao Move Nada
If Len(aTr1Rec) == 0
   Return lRet
Endif
   
Default lTodos:=.F.

//-- Determina a Abrangencia
If lTodos
   //-- Exibe Mensagem de Aviso 
   If !ApMsgYesNo( OemtoAnsi(STR0020),OemtoAnsi(STR0016) ) // ##" Desfazer Escolha de Funcionarios e Digitacao de Notas e Presencas? " ##
      Return lRet 
   Endif   
   nFim		:= Len(aCols)
   nInicio	:= 1
    //-- Implementa Regua somente para movimentacao coletiva
   ProcRegua(nFim)
Else
   nPosicao:=nInicio:=nFim:=n
Endif

dbSelectArea(cTr1Alias) 

//--Marca Funcionarios de Acordo com a Abrangencia (Todos ou especifico)

For nRec:=nInicio To nFim
	(cTr1Alias)->(dbGoto(aTr1Rec[nRec,3]))
    //-- Incrementa Regua somente para movimentacao coletiva
    If lTodos
       IncProc()
    Endif   
    Tr040Marca(@aVetor, nRec, .F.)
    dbSelectArea(cTr1Alias)
Next nRec

// Elimina os Elementos Escolhidos do array aCols do GetDados
If lTodos 
    //-- Cria 1 Elemento vazio no GetDados
  	aCols:={Aclone(aColsVazio)}
	//-- Elimina o array de posicionamento dos registros no ListBox(TR1)
	aTr1Rec:={}

Else
	//-- Retira da GetDados
	If (Len(aCols)-1)>0
		Adel(aCols,nPosicao) 
		ASize(aCols,Len(aCols)-1)
	Else
	    //-- Cria 1 Elemento vazio no GetDados
  	    aCols:={Aclone(aColsVazio)}
	Endif 
	//-- Elimina Elemento do array de posicao dos registros no ListBox(TR1)
	Adel(aTr1Rec,nPosicao) 
	ASize(aTr1Rec,Len(aTr1Rec)-1)	
Endif


o1Lbx:nAt:=nListN
o1Lbx:Refresh(.T.)

n:=1           
OGET:OBROWSE:NLEN:=Len(aCols)
oGet:oBrowse:Refresh()      

RestArea(aSaveArea)

//-- Liga/Desliga botoes
Tr040OnOff(.T.)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr040Marca    ³ Autor ³Emerson Grassi    ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca Funcionario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr040Marca()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040Marca(aVetor,nRec,lAdiciona)
Local aArea	  := GetArea()
Local cAliasQry := GetNextAlias()
Local ctesteTableName := oTmpTabFO1:GetRealName()
Local cSql
Local nIndice

Local nRecTr1Alias := 0

If lAdiciona
	If aVetor[nRec][1] == o1Ok
		aVetor[nRec][1] := oNo
	Else
		aVetor[nRec][1] := o1Ok
	EndIf
	
	cSQL := " SELECT * FROM " + ctesteTableName 
	cSql += " 		WHERE  "
	cSql += " 		TR1_FILIAL  = '" + aVetor[nRec,2] + "' and "
	cSql += " 		TR1_CARGO     = '" + aVetor[nRec,3] + "' and "
	cSql += " 		TR1_DESC    = '" + aVetor[nRec,4] + "' and "
	cSql += " 		TR1_CC      = '" + aVetor[nRec,5] + "' and "
	cSql += " 		TR1_DESCCC  = '" + aVetor[nRec,6] + "' and D_E_L_E_T_ = ''"
		
	//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
	DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )	
	
	If (cAliasQry)->(!Eof())
		(cTr1Alias)->( DbGoTo(   (cAliasQry)->(R_E_C_N_O_)     ) )
		
		RecLock(cTr1Alias,.F.,.T.)
		
		If aVetor[nRec][1] == o1Ok
			(cTr1Alias)->(TR1_MARCA) := 1//IIF((cTr1Alias)->(TR1_MARCA)==1,2,1)
		Else
			(cTr1Alias)->(TR1_MARCA) := 2
		EndIf
		
		(cTr1Alias)->(MsUnlock())
		nRecTr1Alias := (cTr1Alias)->(Recno())//somente para este caso o retorno sera utilizado
		
	EndIf
	
	(cAliasQry)->(DbCloseArea())

Else
    //remove da lista do grid da direita(de selecionados)
	nIndice := Ascan(aVetor,{|x| (cTr1Alias)->(TR1_FILIAL) = x[2]  .and.  (cTr1Alias)->(TR1_CARGO) = x[3] .and.   ;
	                             (cTr1Alias)->(TR1_DESC)   = x[4]  .and.  (cTr1Alias)->(TR1_CC)  = x[5] .and.  (cTr1Alias)->(TR1_DESCCC)= x[6] })
		
	If nIndice > 0 
		If aVetor[nIndice][1] == o1Ok
			aVetor[nIndice][1] := oNo
		Else
			aVetor[nIndice][1] := o1Ok
		EndIf
	
		RecLock(cTr1Alias,.F.,.T.)
			
		If aVetor[nIndice][1] == o1Ok
			(cTr1Alias)->(TR1_MARCA) := 1
		Else
			(cTr1Alias)->(TR1_MARCA) := 2
		EndIf
			
		(cTr1Alias)->(MsUnlock())
		
	EndIf
EndIf

RestArea(aArea)

Return nRecTr1Alias


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr040NMostra  ³ Autor ³Emerson Grassi    ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna array c/campos que nao serao mostrados na Getdados.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr040NMostra()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trmm040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr040NMostra()
Local aSaveArea	:= GetArea() 
Local aMostrar	:= {"RA5_FILIAL","RA5_CARGO","RA5_CC","RA5_DESCCU","RA5_HORAS","RA5_VALIDA","RA5_NOTA","RA5_FREQUE","RA5_PRIORI","RA5_UNPRIO","RA5_EFICAC"}
Local aNMostrar	:= {}

dbSelectArea("SX3") 
dbSetOrder(1)
dbSeek("RA5")
While ! Eof() .and. (SX3->X3_ARQUIVO == "RA5")
    If Ascan(aMostrar,Upper(Trim(x3_campo))) == 0
		Aadd(aNMostrar,Upper(Trim(x3_campo)))
	Endif   
	dbSkip()
EndDo

RestArea(aSaveArea)

Return aNMostrar


/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³26/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMM040                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

 Local aRotina := {	    { STR0001,'PesqBrw'		, 0,1,,.F.},;//"Pesquisar"
						{ STR0003,'Tr040Lan'	, 0,6},;//"Lancamento"
						{ STR0023,'Tr040Exc'	, 0,5}}	//"Excluir"


Return aRotina
