#INCLUDE "plsr820.ch"

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR820 � Autor �Geraldo Felix Junior    � Data � 06/07/03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Medicos por especialidade...                               ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR820()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/                                
Function PLSR820(lAuto)
/*��������������������������������������������������������������������������Ŀ
  � Define variaveis padroes para todos os relatorios...                     �
  ����������������������������������������������������������������������������*/
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

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
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

/*��������������������������������������������������������������Ŀ
  � Envia controle para a funcao SETPRINT                        �
  ����������������������������������������������������������������*/
wnrel:="Plsr820"					           //Nome Default do relatorio em Disco
If !lAutoSt
	wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)
EndIf

/*��������������������������������������������������������������������������Ŀ
  | Verifica se foi cancelada a operacao                                     �
  ����������������������������������������������������������������������������*/
If !lAutoSt .AND. nLastKey  == 27
   Return
Endif
/*��������������������������������������������������������������������������Ŀ
  � Configura impressora                                                     �
  ����������������������������������������������������������������������������*/
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R820Imp  � Autor �Geraldo Felix Junior...� Data � 06/07/03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio                                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

/*��������������������������������������������������������������������������Ŀ
  � Acessa parametros do relatorio...                                        �
  � Variaveis utilizadas para parametros                                     �
  ����������������������������������������������������������������������������
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
	//��������������������������������������������������������������������Ŀ
	//� Verifica se foi abortada a impressao...                            �
	//����������������������������������������������������������������������
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

//��������������������������������������������������������������������Ŀ
//� Imprime rodade padrao do produto Microsiga                         �
//����������������������������������������������������������������������
Roda(0,space(10),nTamanho)
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  aReturn[5] == 1
    Set Printer To
    Ourspool(wnrel)
End

//��������������������������������������������������������������������������Ŀ
//� Fecha area de trabalho...                                                �
//����������������������������������������������������������������������������
TRBESP->( dbClosearea() )

//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������

Return
