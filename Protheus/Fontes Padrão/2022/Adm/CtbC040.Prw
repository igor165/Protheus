#INCLUDE "CTBC040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
// 17/08/2009 -- Filial com mais de 2 caracteres

//-------------------------------------------------------------------
/*{Protheus.doc} CTBC040
Consulta comparativa entre grupos  

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CTBC040(lBar)

Local oDlg
Local aCbx 			:= { 	STR0002, STR0003, STR0004, STR0005, STR0006, STR0007,; //"Linha"###"Area"###"Pontos"###"Barras"###"Piramide"###"Cilindro"
								STR0008, STR0009, STR0010,; //"Barras Horizontal"###"Piramide Horizontal"###"Cilindro Horizontal"
					 			STR0011, STR0012, STR0013, STR0014, STR0015, STR0016 } //"Pizza"###"Forma"###"Linha rapida"###"Flexas"###"GANTT"###"Bolha"
Local aRet			:= {}
Local aGrafico 		:= {}
Local cFilIni		:= cFilAnt
Local cFilGrup	:= ""
Local nK			:= ""   
Local lPerbar		:= .F.
Local lSayGrupo := GetNewPar("MV_CTBNATC","1")=="1"

Private cCadastro 	:= If(lSayGrupo,STR0001,STR0033)
Private oGraphic
Private nSerie, cTitulo, aSaldosMP := {}, mv_pargf := 1
Private cTpBase	:= cTpCompara := ""

Default lBar := .F.                    

// Caso a função tenha sido chamada por ela mesma a variavel nao pode ser reiniciada
If Type("aSelFil") != "A"
	Private aSelFil := {} 
EndIf

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

oMainWnd:ReadClientCoors()

nTop    	:= oMainWnd:nTop+23
nLeft		:= oMainWnd:nLeft+5
nBottom	:= oMainWnd:nBottom-60
nRight	:= oMainWnd:nRight-10

If !lBar    
	If ! Sx1C040()
		Return
	Endif
Endif	

DbSelectArea("CTR")		// Carrego os valores a serem apresentados
dbSetOrder(1)


For nK := 1 To len(aSelFil)	
	cFilAnt := aSelFil[nK]
	cFilGrup := xFilial("CTR")
	DbSelectArea("CTR")
	DbSeek(cFilGrup)
   
	While CTR_FILIAL = cFilGrup .And. !Eof()
		CTBC020Sal(	,, .T.,, "CTR", .T., "CQ1",;
					"_GRUPO", 2, CTR_GRUPO, aGrafico)
		DbSelectArea("CTR")
		dbSkip()
	End	
Next nK		

DEFINE  	MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM 	nTop,nLeft TO;
																nBottom,nRight;
			STYLE nOR(WS_VISIBLE,WS_POPUP)

@00,00 BITMAP oBmp1 RESNAME "FAIXASUPERIOR" SIZE 1200,50 NOBORDER PIXEL OF oDlg
oBmp1:align:= CONTROL_ALIGN_TOP

@ 75,10 BTNBMP oBtn RESOURCE "S4WB005N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0017  //"Recortar"
@ 75,38 BTNBMP oBtn RESOURCE "S4WB006N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0018  //"Copiar"
@ 75,66 BTNBMP oBtn RESOURCE "S4WB007N" 	SIZE 25,25 ACTION NaoDisp() MESSAGE STR0019  //"Colar"
@ 75,94 BTNBMP oBtn RESOURCE "S4WB008N" 	SIZE 25,25 ACTION Calculadora() MESSAGE STR0020  //"Calculadora..."
@ 75,122 BTNBMP oBtn RESOURCE "S4WB009N" 	SIZE 25,25 ACTION Agenda() MESSAGE STR0021  //"Agenda..."
@ 75,150 BTNBMP oBtn RESOURCE "S4WB010N" 	SIZE 25,25 ACTION OurSpool() MESSAGE STR0022  //"Gerenciador de ImpressÆo..."
@ 75,178 BTNBMP oBtn RESOURCE "S4WB016N" 	SIZE 25,25 ACTION HelProg() MESSAGE STR0023  //"Help de Programa..."

@ 75,206 BTNBMP oBtn RESOURCE "SDUPROP" OF oDlg SIZE 25,25;
 	  		ACTION If(Sx1C040(),(lPerBar := .T.,oDlg:End()),lPerBar := .F.) MESSAGE STR0024        //"Parƒmetros..."

@ 75, 234 	BTNBMP oBtnGrap		RESOURCE "AREA" SIZE 25,25;
				ACTION (ParamBox( {	{3,STR0025,mv_pargf,aCbx,50,"",.F.}},STR0024,@aRet),; //"Tipo de grafico"###"Parametros"
					Sx1C040(.F.), If(Len(aRet) > 0, mv_pargf := aRet[1],),;
					CTBC020Grap("CTR",, aGrafico, If(lSayGrupo,STR0032,STR0034),; //"Todos os grupos"
					.T., mv_pargf, STR0001, .T., oDlg, 55, 04,; //"Comparacao entre grupos contabeis"
					(oDlg:nRight / 2.1) - 000, (oDlg:nBottom / 2.1) - 060));
				MESSAGE STR0025  //"Tipo de grafico"
oBtnGrap:Disable()
@ 75, 262 BTNBMP oBtn3D RESOURCE "GRAF3D" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "EFEITO", oBtn3D, oBtn2D) MESSAGE "2D"
@ 75, 262 BTNBMP oBtn2D RESOURCE "GRAF2D" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "EFEITO", oBtn3D, oBtn2D) MESSAGE "3D"
oBtn2d:Hide()
@ 75, 290 BTNBMP oBtnSav	RESOURCE "SALVAR" 	SIZE 25,25 ACTION GrafSavBmp( oGraphic ) MESSAGE STR0026  //"Salva BMP"
oBtnSav:Disable()
@ 75, 318 BTNBMP oBtnPrev 	RESOURCE "PGPREV" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "ROTACAO-", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0027  //"Rotacao -"
// oBtnPrev:Disable()
@ 75, 346 BTNBMP oBtnNext 	RESOURCE "PGNEXT" 	SIZE 25,25 ACTION Ctb020Graph(oGraphic, "ROTACAO+", nSerie, oBtnPrev, oBtnPrev) MESSAGE STR0028  //"Rotacao +"
@ 75, 374 BTNBMP oBtnPrn 	RESOURCE "IMPRESSAO" 	SIZE 25,25 ACTION CtbGrafPrint(oGraphic,STR0001,{ cTitulo },aSaldosMP, .F.) MESSAGE STR0029 //"Comparacao de grupos contabeis"###"Imprimir grafico"
oBtnPrn:Disable()
@ 75, 402 BTNBMP oBtnMail 	RESOURCE "BMPPOST" 	SIZE 25,25 ACTION PmsGrafMail(oGraphic,cTitulo,{cTitulo },aSaldosMP) MESSAGE STR0030 //"Enviar por E-Mail"
oBtnMail:Disable()

@ 75,430 BTNBMP oBtn RESOURCE "FINAL" SIZE 25,25 ACTION oDlg:End() MESSAGE STR0031 //"Fechar"

CTBC020Grap("CTR",, aGrafico, If(lSayGrupo,STR0032,STR0034),; //"Todos os grupos"
				.T., mv_pargf, STR0001, .T., oDlg, 55, 04,; //"Comparacao entre grupos contabeis"
				(oDlg:nRight / 2.1) - 000, (oDlg:nBottom / 2.1) - 060)

oTree := DbTree():New(0, 0, 0, 0, oDlg,,,.T.)		// Somente para os Botoes funcionarem

ACTIVATE MSDIALOG oDlg

cFilIni		:= cFilAnt       

If lPerBar
	CTBC040(.T.)
Endif	

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Sx1C040
Executa confirmacao das perguntas das rotinas e ajusta SX1

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Sx1C040(lPergunta)

Local cPerg 	:= "CTC040"
Local lRet 		:= .T.
Local aArea		:= GetArea()

DEFAULT lPergunta := .T.

If ! Pergunte(cPerg, lPergunta) .And. lPergunta
	lRet := .F.
Endif

If lRet .And. lPergunta
	If MV_PAR05 == 1 
		aSelFil := AdmGetFil()
		If Empty(aSelFil)
			lRet := .F.
		EndIf
	Else
		aSelFil := {cFilAnt}
	Endif
EndIf   	
   	
	
mv_pargf := 1

RestArea(aArea)
Return lRet 
