#INCLUDE "plsr820.ch"

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR820 ³ Autor ³Geraldo Felix Junior    ³ Data ³ 06/07/03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Medicos por especialidade...                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR820()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                
Function PLSR820(lAuto)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Define variaveis padroes para todos os relatorios...                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Default lAuto := .F.

PRIVATE wnRel
PRIVATE cNomeProg   := "PLSR820"
PRIVATE nLimite     := 80
PRIVATE nTamanho    := "P"
PRIVATE Titulo		:= oEmToAnsi(STR0001)				//-- Disponibilidade de Consultas por Unidade //"Rede de atendimento por especialidade"
PRIVATE cDesc1      := oEmToAnsi(STR0001) //"Rede de atendimento por especialidade"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BAU"
PRIVATE cPerg       := "PLR820"
PRIVATE Li         	:= 60
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aReturn     := { oEmToAnsi(STR0002), 1,oEmToAnsi(STR0003) , 1, 2, 1, "",1 } //"A Rayas"###"Administracion"
PRIVATE aOrd		:= {}														//--Unidade de Atendimento
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0004+"    "+STR0005+"                                        "+STR0006+"       "+STR0007+"   "+STR0008 //"Codigo"###"Nome"###"Sigla"###"UF"###"Registro"
PRIVATE cCabec2     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCabec
PRIVATE Colunas		:= 080
PRIVATE AT_PRG  	:= "PLSR820"
PRIVATE wCabec0 	:= 1
PRIVATE wCabec1		:=""
PRIVATE wCabec2		:=""
PRIVATE wCabec3		:=""
PRIVATE wCabec4		:=""
PRIVATE wCabec5		:=""
PRIVATE wCabec6		:=""
PRIVATE wCabec7		:=""
PRIVATE wCabec8		:=""
PRIVATE wCabec9		:=""
PRIVATE CONTFL		:=1
PRIVATE cPathPict	:= ""

lAutoSt := lAuto

Pergunte(cPerg,.F.)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Envia controle para a funcao SETPRINT                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="Plsr820"					           //Nome Default do relatorio em Disco
If !lAutoSt
	wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  | Verifica se foi cancelada a operacao                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAutoSt .AND. nLastKey  == 27
   Return
Endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Configura impressora                                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAutoSt
	SetDefault(aReturn,cAlias)
EndIf
If !lAutoSt .AND. nLastKey = 27
	Return
Endif 

aAlias := {"BAU", "BAX", "BAQ"}
objCENFUNLGP:setAlias(aAlias)

If !lAutoSt
	MsAguarde({|lEnd| R820Imp(@lEnd,wnRel,cAlias)},Titulo)
Else
	R820Imp()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R820Imp  ³ Autor ³Geraldo Felix Junior...³ Data ³ 06/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Emite relatorio                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Static Function R820Imp()
Local   cSQL			:= ""
//Local   cPict			:= "@E    999"
//Local   cDias			:= ""
//Local   nDias			:= "  "
//Local   cBAXOpe			:= ""
//Local   cBAXUni			:= ""
//Local   cBAXMed			:= ""
//Local   cBAXEsp			:= ""
//Local   nOrdem  		:= aReturn[8]
//Local   nNrConsDia		:= 0  						//-- Numero de consultas possiveis por dia para cada medico
//Local 	nNrConsEfetuada		:= 0					//-- Numero de consultas efetuadas
//Local   nTempo			:= 0 						//-- Tempo estipulado para cada consulta
//Local   aDiaAgenda		:= {}
//Local 	dDtValido		:= cTod("//") 
Private aDados 			:= {}                      

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Acessa parametros do relatorio...                                        ³
  ³ Variaveis utilizadas para parametros                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cRdaDe   	:= mv_par01					//-- Codigo da Operadora de
cRdaAte  	:= mv_par02					//-- Codigo da Operadora Ate
cEspDe		:= mv_par03					//-- Codigo da Unidade de Atendimento De
cEspAte		:= mv_par04					//-- Codigo da Unidade de Atendimento Ate

If lAutoSt
	cRdaDe   	:= "      "					//-- Codigo da Operadora de
	cRdaAte  	:= "ZZZZZZ"					//-- Codigo da Operadora Ate
	cEspDe		:= "   "					//-- Codigo da Unidade de Atendimento De
	cEspAte		:= "ZZZ"					//-- Codigo da Unidade de Atendimento Ate
EndIf

cSql := "SELECT DISTINCT BAU_CODIGO, BAU_NOME, BAU_SIGLCR, BAU_CONREG,BAU_ESTCR, BAX_CODESP, BAX_CODINT "
cSql += "FROM "+RetSqlName("BAU")+","+RetSqlName("BAX")+" WHERE "
cSql += RetSqlName("BAU")+".D_E_L_E_T_ = '' AND "+RetSqlName("BAX")+".D_E_L_E_T_ = '' AND "
cSql += "BAU_CODIGO = BAX_CODIGO AND BAU_CODIGO >= '"+cRdaDe+"' AND BAU_CODIGO <= '"+cRdaAte+"' AND "
cSql += "BAX_CODESP >= '"+cEspDe+"'  AND BAX_CODESP <= '"+cEspAte+"'  ORDER BY BAX_CODESP,BAU_NOME "
PlsQuery(cSql, "TRBESP")

TRBESP->( dbGotop() )
While !TRBESP->( Eof() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi abortada a impressao...                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Interrupcao(lAbortPrint)
		@ ++Li, 00 pSay "******** "+STR0009+" ********" //"Impressao abortada pelo operador"
		Exit
	Endif

   If li > 58
		cabec(STR0010,cCabec1,cCabec2,cNomeprog,nTamanho,) //"Rede de atendimento por Especialidades"
		lTitulo := .T.
		li := 7
	EndIf
	cCodEsp := objCENFUNLGP:verCamNPR("BAX_CODESP", TRBESP->BAX_CODESP)
    
	If !lAutoSt
    	MsProcTxt(STR0011+" - "+cCodEsp) //"Especialidade"
    EndIf

    li += 2                                                       
	BAQ->( dbSetorder(01) )
	If BAQ->( dbSeek(xFilial("BAQ")+TRBESP->BAX_CODINT+TRBESP->BAX_CODESP) )
		@ li, 000 Psay STR0011+" ------> "+cCodEsp+" - "+ objCENFUNLGP:verCamNPR("BAQ_DESCRI", Alltrim(BAQ->BAQ_DESCRI)) //"Especialidade"
		li+=2

		While !TRBESP->( Eof() ) .and. TRBESP->BAX_CODESP == cCodEsp
		
		   If li > 58
				cabec(STR0010,cCabec1,cCabec2,cNomeprog,nTamanho,) //"Rede de atendimento por Especialidades"
				lTitulo := .T.
				li := 9
				@ li, 000 Psay STR0011+" ------> "+cCodEsp+" - "+ objCENFUNLGP:verCamNPR("BAQ_DESCRI", Alltrim(BAQ->BAQ_DESCRI)) //"Especialidade"
				li+=2
			EndIf
			
			@ li, 001 Psay objCENFUNLGP:verCamNPR("BAU_CODIGO", TRBESP->BAU_CODIGO)
			@ li, 010 Psay Substr(objCENFUNLGP:verCamNPR("BAU_NOME", TRBESP->BAU_NOME), 1, 30)
			@ li, 055 Psay objCENFUNLGP:verCamNPR("BAU_SIGLCR", TRBESP->BAU_SIGLCR)
			@ li, 065 Psay objCENFUNLGP:verCamNPR("BAU_ESTCR", TRBESP->BAU_ESTCR)
			@ li, 072 Psay objCENFUNLGP:verCamNPR("BAU_CONREG", Substr(TRBESP->BAU_CONREG,1,10))
			li++
			TRBESP->( dbSkip() )
		Enddo
	Else
		TRBESP->( dbSkip() )
	Endif
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodade padrao do produto Microsiga                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Roda(0,space(10),nTamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  aReturn[5] == 1
    Set Printer To
    Ourspool(wnrel)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha area de trabalho...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRBESP->( dbClosearea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Relat¢rio                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return
