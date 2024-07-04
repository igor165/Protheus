#include "PLSRPRO03.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "msgraphi.ch"
#include "colors.ch"

#DEFINE RESETLIN nLinha := 550
#DEFINE	IMP_PDF 6
#DEFINE	TAM_A4 9			//A4     	210mm x 297mm  620 x 876

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSRPRO03 บAutor  ณSaude				    บ Data ณ  09/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorios Graficos da Ananmnese      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSRPRO03(cRegger,cPergAn,lPront,cRegate)     
LOCAL AAREA       := GETAREA()
Local oFld        := Nil
Local oBold       := Nil 
Local nSerie      := 0
Local aSay    		:= {}
Local aButton 		:= {}
Local cPerAnan		:=""

Private cAlias	:= "GFR"
Private oMSGraphic  
Private cPerg 	:= PADR("PLRPRO03", Len(SX1->X1_GRUPO))
Private aVetGr01  := {}
Private aVetGr02  := {}
Private aVetGr03  := {}
Private oGraOk    := Nil   
Private cTitulo   := STR0001//"Gera็ใo de Graficos na Anamnese"
Private nCbt1     := 1
Private nCbt2     := 1
Private cGrafic   := .t.
Private cPaciente	:=""
Private oPrn
Private cFile		:=""
Private cFileName	:= "PLSRPRO03" + criaTrab(nil,.f.)
Private cPath 	:= GetSrvProfString("Startpath","")
Private lSucesso	:=.F.
Private lView		:=.T.
Private m_pag		:= 1
Private cPergAn	:=""
Private cPergTemp	:=""
Private cSexo		:=""
Private aColors	:={}
Private aColors2	:={}
Private nPercent	:=0
Private cResPer	:=""
Private cTipPer	:=""
Private aPerg		:=""
Private cAtendime :=""
Private nAudOuv	:=1

Default cRegger	:=""
Default lPront	:=.F.
Default  cPergAn  :=""
Default cRegate	 :=""

AAdd( aColors,  CLR_HBLUE     )
AAdd( aColors,  CLR_HCYAN     )
AAdd( aColors,  CLR_HRED      )
AAdd( aColors,  CLR_HMAGENTA  )
AAdd( aColors,  CLR_YELLOW    )
AAdd( aColors,  CLR_WHITE     )
AAdd( aColors,  CLR_MAGENTA   )
AAdd( aColors,  CLR_BROWN     )
AAdd( aColors,  CLR_HGRAY     )
AAdd( aColors,  CLR_LIGHTGRAY )
AAdd( aColors,  CLR_BLUE      )
AAdd( aColors,  CLR_CYAN      )
AAdd( aColors,  CLR_RED       )
AAdd( aColors,  CLR_GRAY      )
AAdd( aColors,  CLR_BLACK     )
AAdd( aColors2,  CLR_HGREEN    )
AAdd( aColors2,  CLR_GREEN     )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCarregando as perguntas do Relatorio.
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
GeraSX1()                                   

Pergunte("PLRPRO03",.T.)

cPergTemp	:=mv_par01
cPergAn		:=mv_par02
nCbt1		:=mv_par04
nCbt2		:=mv_par04
nPercent	:=mv_par05
nAudOuv		:=mv_par06

aPerg:=PRO03VAL({cPergTemp,cPergAn})

cPergTAna:=alltrim(Posicione("GCH",1,xFilial("GCG")+cPergTemp,"GCH_DESPER"))
cPerAnan:=alltrim(Posicione("GCH",1,xFilial("GCG")+cPergAn,"GCH_DESPER"))
If nAudOuv == 1
	//Diario   
	If(mv_par03) == 1
		cTitulo+=STR0002+" x "+Iif(empty(cPergTAna),"KG/CM",cPergTAna)+" -> "+cPergAn+"--"+cPerAnan//" Dias"
	// MENSAL
	ElseIf(mv_par03) == 2
		cTitulo+=STR0003+" x "+Iif(empty(cPergTAna),"KG/CM",cPergTAna)+" -> "+cPergAn+"--"+cPerAnan//" M๊s"
	// ANUAL
	ElseIf(mv_par03) == 3
		cTitulo+=STR0004+" x "+Iif(empty(cPergTAna),"KG/CM",cPergTAna)+" -> "+cPergAn+"--"+cPerAnan//" Ano"
	EndIf
Else
	cTitulo+=STR0004+" x "+Iif(nAudOuv==2,STR0016,STR0017)//"Grafico Audiometria Ouvido Direito"  "Grafico Audiometria Ouvido Esquerdo"
Endif
If !lPront
	cPaciente:=&cRegger
	cAtendime:=&cRegate
Else
	cPaciente:=cRegger
	cAtendime:=cRegate
Endif

dbselectarea("GCY")
dbsetorder(2)
GCY->(MsSeek(xFilial("GCY")+cPaciente))
cSexo:=GCY->GCY_SEXO

DEFINE MSDIALOG oGraOk FROM 0,0 TO 510,760 TITLE cTitulo PIXEL 
DEFINE FONT oBold  NAME "Arial" SIZE 0, -12 BOLD
DEFINE FONT oBold2 NAME "Arial" SIZE 0, -16 BOLD

oMSGraphic := TMSGraphic():New( 25,05,,,,RGB(239,239,239),370,210)

MsgRun( STR0005, '', { || Pro03Gera(oMSGraphic,cPergAn) } )//'Gerando grแfico, aguarde...'

ACTIVATE MSDIALOG oGraOk CENTER ON INIT MyConBar(oGraOk,{||oGraOk:End()},oMsGraphic)

RESTAREA(AAREA)   
Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMyConBar บAutor  ณSaude				    บ Data ณ  09/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Bot๕es da Tela do Grafico					 			       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
     
Static Function MyConBar(oObj,bObj,oMSGraphic)
LOCAL oBar, lOk, lVolta, lLoop,oDBG10,oDBG02,oBtOk,oNada,oBtcl,oBtcn 
oMSGraphic:l3D:=.F.
DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP    OF oObj
DEFINE BUTTON         RESOURCE "S4WB008N"  OF oBar GROUP ACTION Calculadora()                                 TOOLTIP STR0006//"Calculadora"
DEFINE BUTTON         RESOURCE "BAR"       OF oBar       ACTION  oMSGraphic:l3D := !oMSGraphic:l3D		     TOOLTIP "3D"
DEFINE BUTTON         RESOURCE "IMPRESSAO"    OF oBar       Action Pro03Monta(oMSGraphic)            			     TOOLTIP STR0007//"Imprimir"
DEFINE BUTTON oBtOk   RESOURCE "CANCEL"    OF oBar       ACTION (lLoop:=lVolta,lOk:=Eval(bObj))               TOOLTIP "Sair - <Alt+F4>"

oBar:bRClicked:={||AllwaysTrue()}

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPro03Gera บAutor  ณSaude				    บ Data ณ  09/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe as Informa็oes de Grafico na Tela				      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Static Function Pro03Gera(oMSGraphic,cPergAn)
Local nIndTask 	:= 0
Local nIndTask2	:= 0
Local nMax     	:= 1
Local _n		:=0
Local ni		:=0
Local nSerie	:=0
Local lRet		:=.T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCarregando os Dados do relatorio.
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

lRet:=PRPR03DADO(cPergAn)

If !lRet
	Return(.F.)
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณDados dos Percentil
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If  nPercent==2
	PRPR03PERC(cPergAn)
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณDados do Grafico.
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

oMSGraphic:SetLegenProp( GRP_SCRBOTTOM, CLR_LIGHTGRAY, GRP_VALUES , .T. )
oMSGraphic:lShowHint:=.t.  // Desabilita Hint  
oMSGraphic:SetMargins( 20, 6, 6, 6 )
oMSGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE)

store .f. to vet1,vet2,vet3
For _n := 1 to len(aVetGr01)
	if aVetGr01[_n][1]
		vet1=.t.
	endif
         
Next _n

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณDados Percentil
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
For _n := 1 to len(aVetGr02)
    if aVetGr02[_n][1]
        vet2=.t.
    endif
  
Next _n

if vet1
	nSerie := oMSGraphic:CreateSerie( IIf( nCbt1 == 1, GRP_BAR, IIF(nCbt1 == 2,GRP_LINE,GRP_POINT) ))
	nMax := len(aVetGr01)
	xcor=CLR_GREEN
	CorL1='BR_VERDE'
		If nSerie <> GRP_CREATE_ERR
			If nCbt1 == GRP_PIE
				nMax := 1
			Endif
			For _n := 1 to nMax
				if aVetGr01[_n][1] 
				
					If nAudOuv>1
						oMSGraphic:Add(nSerie,VAL(aVetGr01[_n][3]),aVetGr01[_n][2],xcor)					
					ElseIf  !Empty(cPergTemp)
						oMSGraphic:Add(nSerie,VAL(aVetGr01[_n][3]),aVetGr01[_n][2],xcor)
					Else
						oMSGraphic:Add(nSerie,aVetGr01[_n][3],aVetGr01[_n][2],xcor)
					Endif
					
				else
					oMSGraphic:Add(nSerie,0,aVetGr01[_n][2],xcor)
				endif 
			Next _n
		Endif
Endif

   if vet2
    nMax := len(aVetGr02)
      xcor=CLR_HRED 
      CorL2='BR_VERMELHO'
      If nSerie <> GRP_CREATE_ERR
  	   	If nCbt2 == GRP_PIE
   	   	nMax := 1
   	   Endif
	      For _n := 1 to nMax
	      	nSerie := oMSGraphic:CreateSerie( IIf( nCbt2 == 1, GRP_BAR, GRP_LINE ))
             if aVetGr02[_n][1]
             	if nPercent==0
                	oMSGraphic:Add(nSerie,aVetGr02[_n][3],aVetGr02[_n][2],aColors[_n])
                Else
                	For ni:= 1 to len(aVetGr02[_n][3])            	
                	oMSGraphic:Add(nSerie, VAL(aVetGr02[_n][3][ni]),"",aColors[_n])
	               	next ni
                Endif	                	
              Else
                oMSGraphic:Add(nSerie,0,aVetGr02[_n][2],aColors[_n])
             endif 
   	   Next _n
	   Endif
   Endif

oMSGraphic:REFRESH()
cGrafic:=.f.
   
Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPro03Monta บAutor  ณSaude				    บ Data ณ  09/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprimir o Relatorio via impressora PDF				      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function Pro03Monta(oMSGraphic) 
LOCAL cArq			:= "PRO03" + CriaTrab(NIL,.F.) + ".JPEG"
Local cRaizServer := If(issrvunix(), "/", "\")
Local lBmp 		:= !( oMSGraphic == NIL )
Local nLenPag    	:= 2500
Local nLin			:=	0220
Local nEntreLin	:=	30
Local nMargX		:=	050
Local limite		:=	132
Local nPosi		:= 0373
Local bRepli       := {|| REPLI("_",limite) }
Local cBmpName		:=	""

If lBmp
	cBmpName := CriaTrab(,.F.)+".BMP"
	oMSGraphic:SaveToBMP( cBmpName, cRaizServer )
Endif

oPrn:=    FwMsPrinter():New(cFileName           , IMP_PDF    ,.T.                  ,cPath              ,.F.                ,.F.          ,@oPrn            ,              ,.F.         ,.F.           ,.F.      ,lView      ,/*nQtdPags*/)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณResolu็ใo do relatorio.
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oPrn:setResolution(72)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณModo paisagem
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oPrn:setLandscape()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณPapel A4
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oPrn:setPaperSize(TAM_A4)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณMargem
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

oPrn:setMargin(05,05,05,05)

//Objetos para tamanho e tipo das fontes
oFont1 	:= TFont():New( "Times New Roman",,11,,.T.,,,,,.F.)
oFont2 	:= TFont():New( "Tahoma",,16,,.T.,,,,,.F.)
oFont3	:= TFont():New( "Arial"       ,,20,,.F.,,,,,.F.)

oPrn:StartPage() //Inicia uma nova pแgina // startando a impressora
oPrn:Say(0, 0, "",oFont1,100) 
nLin += nEntreLin
nLin := FS_CabGraf(oPrn, nLenPag, "PLSRPRO03", 0800, cTitulo)
nLin += nEntreLin

oPrn:Say(nLin, nMargX+0000, STR0008,oFont1,100)//"Prontuแrio"
oPrn:Say(nLin, nMargX+nPosi,STR0009, oFont1, 100)//"Nome."
oPrn:Say(nLin, nMargX+0857, STR0010, oFont1, 100)//"Data Nascimento: "
oPrn:Say(nLin, nMargX+1075, STR0011, oFont1, 100)//"Sexo"
oPrn:Say(nLin, nMargX+1440, STR0012, oFont1, 100)//"Idade "
oPrn:Say(nLin, nMargX+1640, STR0018, oFont1, 100)//"Data Atendimento "
oPrn:Say(nLin, nMargX+0000, Eval(bRepli), oFont1, 100)
nLin += nEntreLin

oPrn:Say(nLin, nMargX+0000, GCY->GCY_REGGER ,oFont1,100)
oPrn:Say(nLin, nMargX+nPosi, GCY->GCY_NOME , oFont1, 100)
oPrn:Say(nLin, nMargX+0857, DTOC(GCY->GCY_DTNASC), oFont1, 100)
oPrn:Say(nLin, nMargX+1075,  Iif (GCY->GCY_SEXO=="0",STR0013,STR0014) , oFont1, 100)//"Masculino"//"Feminino"
oPrn:Say(nLin, nMargX+1440, ALLTRIM(GCY->GCY_IDADE), oFont1, 100)
oPrn:Say(nLin, nMargX+1640, DTOC(GCY->GCY_DATATE), oFont1, 100)
oPrn:Say(nLin, nMargX+0000, Eval(bRepli), oFont1, 100)
nLin += nEntreLin
oPrn:Saybitmap(nLin+0200,0300,cRaizServer + cBmpName,1800,1000)

oPrn:EndPage()
oPrn:Preview()

Return()
                                                  
 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRPR03DADO บAutor  ณSaude				    บ Data ณ  09/09/14บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca informa็๕es para a montagem do Array de Dados	     	บฑฑ
ฑฑบ          ณ  para a exibi็ใo do Grแfico na Tla                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
                                                 
Static Function PRPR03DADO(cPergAn)
Local cFiltro	:=""
Local cAnamn	:=""
Local cResNumI	:=""
Local cResNumF	:=""
Local cResDatI	:=""
Local cResDatF	:=""
Local cResCarI:=""
Local cResCarF:=""
Local cOrdem	:=""
Local lRetNum	:=.F.
Local lRetCar	:=.F.
Local lRetDat	:=.F.
Local cPergAud:=""
Local aAudioValor	:={}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSelects ...             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nAudOuv>1
	cFiltro := " SELECT GFK_CDANAM,GFK_RESNUM,GFK_RESCAR,"
	cFiltro +="GCG_ORDPER"

Else

	If  Empty(cPergTemp)
		cFiltro := " SELECT SUM(CAST(GFK_RESNUM AS INT)) as GF_TOTAL,"
	Else
		cFiltro := "SELECT GFK_CDANAM,GFK_RESNUM,GFK_RESCAR,"
	
	Endif

	If (mv_par03) == 1 
		If AllTrim(TCGetDB()) $ "ORACLE"
			cFiltro += IIF(Empty(cPergTemp),"SUBSTR(GCY_IDADE,8,3)","SUBSTR(GFK_RESDAT,7,2)" )+" GBH_DTNASC "
		Else
			cFiltro += IIF(Empty(cPergTemp),"SUBSTRING(GCY_IDADE,8,3)","SUBSTRING(GFK_RESDAT,7,2)" )+" GBH_DTNASC "
		Endif	
	ElseIf (mv_par03) == 2
		If AllTrim(TCGetDB()) $ "ORACLE"
			cFiltro += IIF(Empty(cPergTemp),"SUBSTR(GCY_IDADE,5,3)","SUBSTR(GFK_RESDAT,5,2)" )+" GBH_DTNASC "
		Else
			cFiltro += IIF(Empty(cPergTemp),"SUBSTRING(GCY_IDADE,5,3)","SUBSTRING(GFK_RESDAT,5,2)" )+" GBH_DTNASC "
		Endif
	ElseIf (mv_par03) == 3
		If AllTrim(TCGetDB()) $ "ORACLE"
			cFiltro += IIF(Empty(cPergTemp),"SUBSTR(GCY_IDADE,1,4)","SUBSTR(GFK_RESDAT,1,4)" )+" GBH_DTNASC "		
		Else
			cFiltro += IIF(Empty(cPergTemp),"SUBSTRING(GCY_IDADE,1,4)","SUBSTRING(GFK_RESDAT,1,4)" )+" GBH_DTNASC "
		Endif	
	EndIf
Endif

cFiltro += "  FROM "+RetSqlName("GBH")+ " GBH "
cFiltro += "  INNER JOIN "+RetSqlName('GFU')+" GFU ON GFU_FILIAL = '" +xFilial('GFU')+ "' AND GFU_REGGER = GBH_CODPAC AND GFU.D_E_L_E_T_ <> '*' "
cFiltro += "  INNER JOIN "+RetSqlName('GFK')+" GFK ON GFK_FILIAL = '" +xFilial('GFK')+ "' AND GFK_CDANAM = GFU_CDANAM     AND GFK.D_E_L_E_T_ <> '*'"

If nAudOuv>1
	If nAudOuv==2
		cPergAud:= GetNewPar("MV_RELAUDD","")
	Else
		cPergAud:=GetNewPar("MV_RELAUDE","")
	Endif       
	
	If Empty(cPergAud)
		MsgInfo(STR0022) //"Para o Grafico de Audiometria ้ necessแrio a configura็ใo dos Parametros MV_RELAUDD e MV_RELAUDE "
		return(.F.)
	Endif
Endif	

If !Empty(cPergAud) // Se for Grafico de auditoria
	cPergAn:=cPergAud
	cFiltro += "	AND GFK_CODPER IN (" + HS_InSql(cPergAn) + ") "
Else

	If  EMPTY(cPergTemp)
		cFiltro += "	AND GFK_CODPER= '"+cPergAn+"'"
	Else
		cFiltro += "	AND GFK_CODPER IN  ('"+cPergAn+"','"+cPergTemp+"')"
	Endif
	
Endif		

	cFiltro += "  INNER JOIN "+RetSqlName('GCH')+" GCH ON GCH_FILIAL = '" +xFilial('GCH')+ "'  AND GCH.D_E_L_E_T_ <> '*' AND GCH.GCH_CODPER = GFK.GFK_CODPER "
	cFiltro += "  INNER JOIN "+RetSqlName('GCY')+" GCY ON GCY_FILIAL = '" +xFilial('GCY')+ "'  AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGGER = GFU.GFU_REGGER AND GCY.GCY_REGATE = GFU.GFU_REGATE "

If !Empty(cPergAud) .AND. nAudOuv>1
	cFiltro += "	AND GCY_REGATE= '"+cAtendime+"'"
	cFiltro += "  INNER JOIN "+RetSqlName('GCG')+" GCG ON GCG_FILIAL = '" +xFilial('GCG')+ "'  AND GCG.D_E_L_E_T_ <> '*' AND GCH.GCH_CODPER = GCG.GCG_CODPER "
Endif

cFiltro += "  WHERE  GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND  GBH.D_E_L_E_T_ = ' ' AND GBH.GBH_CODPAC= '"+cPaciente+"'"

cOrdem:=Pro03Ord()

If nAudOuv>1
	cFiltro +=" GROUP BY GFK_CDANAM,GFK_RESNUM,GFK_RESCAR,GCG_ORDPER"
	cFiltro +=" ORDER BY GFK_CDANAM "
Else
	If  !Empty(cPergTemp)
		cFiltro +=" GROUP BY GFK_CDANAM,GFK_RESNUM,GFK_RESCAR,"+cOrdem
		cFiltro +=" ORDER BY GFK_CDANAM "

	Else
		cFiltro +=" GROUP BY "+cOrdem
		cFiltro +=" ORDER BY "+cOrdem
	Endif
Endif

cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"QRYITE",.T.,.F.)

DbSelectArea("QRYITE")

If Eof()
	QRYITE->( dbCloseArea() )
	return(.F.)
endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray com os Dados						             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

IF 	nAudOuv<>1
	aAudioValor:={'250Hz','500Hz','1KHz','2KHz','3KHz','4KHz','6KHz','8KHz'}
Endif

naud:=1
While !QRYITE->(EOF())
	
	If  Empty(cPergTemp) .AND. nAudOuv==1
		aAdd(aVetGr01,{.t.,GBH_DTNASC, GF_TOTAL})
	Else
		cAnamn		:= QRYITE->GFK_CDANAM
		If  Alltrim(cAnamn) == Alltrim(QRYITE->GFK_CDANAM)
			
			If !Empty(QRYITE->GFK_RESNUM) .and. !lRetNum
				cResNumI:=QRYITE->GFK_RESNUM
				lRetnum:=.T.
			Else
				cResNumF:=QRYITE->GFK_RESNUM
				lRetNum:=.F.
			Endif
			
			If !Empty(QRYITE->GFK_RESCAR) .and. !lRetCar
				cResCarI:=QRYITE->GFK_RESCAR
				lRetCar:=.T.
			Else
				cResCarF:=QRYITE->GFK_RESCAR
				lRetCar:=.F.
			Endif
		
			If nAudOuv>1
				If !Empty(cResNumI) .AND. naud<=8
					cResDatI:=aAudioValor[naud]
					aAdd(aVetGr01,{.t.,(cResDatI), (cResNumI)})
					cResNumI	:=""
					cResDatI	:=""
					lRetNum:=.F.
					lRetDat:=.F.
					naud+=1
					
				Endif

			Else
				
				If !Empty(cResDatI) .and. !Empty(cResNumI)
					aAdd(aVetGr01,{.t.,(cResDatI), (cResNumI)})
					cResNumI	:=""
					cResDatI	:=""
					lRetNum:=.F.
					lRetDat:=.F.
				ElseIf !Empty(cResDatI) .and. !Empty(cResCarI)
					aAdd(aVetGr01,{.t.,(cResDatI), (cResCarI)})
					cResCarI	:=""
					cResDatI	:=""
					lRetCar:=.F.
					lRetDat:=.F.
				ElseIf !Empty(cResNumI) .and. !Empty(cResCarI)
					aAdd(aVetGr01,{.t.,(cResNumI), (cResCarI)})
					cResCarI	:=""
					cResNumI	:=""
					lRetNum:=.F.
					lRetCar:=.F.
				ElseIf !Empty(cResDatI) .and. !Empty(cResDatF)
					aAdd(aVetGr01,{.t.,(cResDatI), (cResDatF)})
					cResDatI	:=""
					cResDatF	:=""
					lRetDat:=.F.
				ElseIf !Empty(cResCarI) .and. !Empty(cResCarF)
					aAdd(aVetGr01,{.t.,(cResCarI), (cResCarF)})
					cResCarI	:=""
					cResCarF	:=""
					lRetCar:=.F.
				ElseIf !Empty(cResNumI) .and. !Empty(cResNumF)
					aAdd(aVetGr01,{.t.,(cResNumI), (cResNumF)})
					cResNumI	:=""
					cResNumF	:=""
					lRetNum:=.F.
					
				Endif
			Endif
		Endif
	Endif
	
	dbSkip()
	
EndDo

dbCloseArea("QRYITE")

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPro03Ord   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ordem dos Campos no Relatorio                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function Pro03Ord()
Local csql	:=""
 
If (mv_par03) == 1
	If AllTrim(TCGetDB()) $ "ORACLE"
		csql :=  IIF(Empty(cPergTemp),"SUBSTR(GCY_IDADE,8,3)","SUBSTR(GFK_RESDAT,7,2)" )	
	Else
		csql :=  IIF(Empty(cPergTemp),"SUBSTRING(GCY_IDADE,8,3)","SUBSTRING(GFK_RESDAT,7,2)" )
	Endif
ElseIf (mv_par03) == 2
	If AllTrim(TCGetDB()) $ "ORACLE"
		csql := IIF(Empty(cPergTemp),"SUBSTR(GCY_IDADE,5,3)","SUBSTR(GFK_RESDAT,5,2)" )	
	Else
		csql := IIF(Empty(cPergTemp),"SUBSTRING(GCY_IDADE,5,3)","SUBSTRING(GFK_RESDAT,5,2)" )
	Endif
ElseIf (mv_par03) == 3
	If AllTrim(TCGetDB()) $ "ORACLE"
		csql := IIF(Empty(cPergTemp),"SUBSTR(GCY_IDADE,1,4)","SUBSTR(GFK_RESDAT,1,4)" )	
	Else
		csql := IIF(Empty(cPergTemp),"SUBSTRING(GCY_IDADE,1,4)","SUBSTRING(GFK_RESDAT,1,4)" )
	Endif
EndIf

Return(csql)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPro03Ord   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dados do Percentil para exibi็ใo no Grafico                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PRPR03PERC(cPergAn)
Local  cFiltro:=""
Local nPos    := 1	
Local cValores :=""
Local aDahomo:={}

cSexo:="0"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSelects ...             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cFiltro := "SELECT GTU_PERCEN,GTU_VALORE "	
cFiltro += "  FROM "+RetSqlName("GTU")+ " GTU "
cFiltro += "  WHERE  GTU.GTU_FILIAL = '" + xFilial("GTU") + "' AND  GTU.D_E_L_E_T_ = ' '"
cFiltro += " AND GTU.GTU_PERGUN= '"+cPergAn+"'"
cFiltro += " AND GTU.GTU_SEXO= '"+cSexo+"'"
 
cFiltro	:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"QRYPERC",.T.,.F.)

DbSelectArea("QRYPERC")

If Eof()
	QRYPERC->( dbCloseArea() )
	Return()
endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray com os Dados						             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

While !QRYPERC->(EOF()) 

cPerg		:= QRYPERC->GTU_PERCEN
cValores:=QRYPERC->GTU_VALORE	
	If  Alltrim(cPerg) == Alltrim(QRYPERC->GTU_PERCEN)
	While (nPos := AT(";", UPPER(cValores) +";")) > 0 .and. !Empty(cValores)
		cAux   := Substr(UPPER(cValores), 1,nPos-1)
		cValores := UPPER(substr(cValores,nPos+1,len(cValores)))
		If !Empty(cAux) 
			Aadd(aDahomo,UPPER(cAux))
		Endif
	End
	
Endif
	aAdd(aVetGr02,{.t.,(QRYPERC->GTU_PERCEN), (aDahomo)})
	aDahomo:={}		
	
dbSkip()

EndDo

dbCloseArea("QRYITE")

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRO03VAL   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do Tipo de Pergunta escolhido para a emissใo do  บฑฑ
ฑฑบ          ณ relat๓ri                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PRO03VAL(aPergAn)
Local Ni:=0
Local aDaPer:={}

For Ni := 1 to Len (aPergAn)

	cPergAn:=aPergAn[Ni]

	If "_" $ cPergAn
		cPergAn := Alltrim(SubStr(cPergAn, 5, Len(cPergAn)))
	EndIf

	GCH->(DbSetOrder(1))
	If GCH->(MsSeek(xFilial("GCH")+cPergAn))
		cTipPer := GCH->GCH_TIPPER
		If cTipPer == "C" 
			cResPer := "GFK_RESCAR"
		ElseIf cTipPer == "N"
			cResPer := "GFK_RESNUM"
		ElseIf cTipPer == "D"
			cResPer := "GFK_RESDAT"
		EndIf 
	EndIf

	If  !EMPTY(cTipPer) .AND. !(cTipPer $ "CND")   
		MsgInfo(STR0015)//"Para esta funcionalidade s๓ devem ser utilizadas perguntas do tipo numerico, caracter ou Data!"	
		Return()
	EndIf

	aadd(aDaPer,{cPergAn,cTipPer,cResPer})
Next 

Return(aDaPer) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CabGraf   บAutor  ณMicrosiga           บ Data ณ  04/09/14บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cabe็alho do Relat๓rio									  บฑฑ
ฑฑบ          ณ relat๓ri                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CabGraf(oPrn, nLenPag, cNomeFunc, nColTit, cTitulo)
Local cEmpLogo   := ""
Local nLin1      := 0100
Local nLin2      := 0150
Local nLin3      := 0170
Local nLinTit    := 0180
Local nColStart  := 0050
Local nColEnd    := nLenPag - 0050
Local oCabFont1  := TFont():New("Courier New", 13, 11,, .T.,,,,,.F.) //cTitulos dos Relat๓rio
Local oCabFont2  := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //Adendos Cabe็alho

Default nColTit    := 0800

oPrn:Line(0000, nColStart, 0000,  nColEnd)

cEmpLogo := "system\lgrl" + Lower(Iif( FindFunction("FWGRPCompany"),FWGRPCompany(), SM0->M0_CODIGO )   ) + ".bmp"
If File(cEmpLogo)
	oPrn:SayBitmap(nLin1-40, nColStart, cEmpLogo, 0300, 0080)
Else
	oPrn:Say(nLin1, nColStart,Iif( FindFunction("FWGRPCompany"),AllTrim(FWFilialName(FWGrpCompany(),FWCodFil(),2)), SM0->M0_CODIGO )+ Iif( FindFunction("FWFilialName"), FWFilialName(),SM0->M0_NOME), oCabFont2, 100)
EndIf

oPrn:Say(nLin2, nColStart, "SIGA/" + AllTrim(cNomeFunc) + "/v." + cVersao, oCabFont2, 100)
oPrn:Say(nLin3, nColStart, Time(), oCabFont2, 100)

oPrn:Say(nLinTit, nColTit, cTitulo, oCabFont1, 100)

oPrn:Say(nLin1, nColEnd-380, Padl(STR0019 + AllTrim(Str(m_pag++)), 20), oCabFont2, 100) //"Pแgina: "
oPrn:Say(nLin2, nColEnd-380, Padl(STR0020 + DToC(dDataBase), 20), oCabFont2, 100) //"Dt. Ref.: "
oPrn:Say(nLin3, nColEnd-380, Padl(STR0021 + DToC(Date()), 20), oCabFont2, 100) //"Emissใo: "
oPrn:Line(0200, nColStart, 00200,  nColEnd)

Return 0250

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraSX1   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Perguntas utilizadas no Relatorio                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GeraSX1()
Local i,j
local 		aHelpPor := {} ; aHelpSpa := {} ; 	aHelpEng := {}

aRegs:={}
// Grupo/Ordem/Pergunta/Perg.Espanhol/Perg.Ingles/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSPA1/DefIng1/Cnt01/Var02/Def02/DefSPA2/DefIng2/Cnt02/Var03/Def03/DefSPA3/DefIng3/Cnt03/Var04/Def04/DefSPA4/DefIng4/Cnt04/Var05/Def05/DefSPA5/DefIng5/Cnt05/Alias/Grupo
AADD(aRegs,{cPerg,"01","Perg. Tempo ?","","","MV_CH01","C",06,00,00,"G","","MV_PAR01","      ","","","","","      ","","","","","     ","","","","","","","","","","","","","","GCH01","","","","@",""})
AADD(aRegs,{cPerg,"02","Perg. Evolu็ใo?","","","MV_CH02","C",06,00,00,"G","","MV_PAR02","      ","","","","","      ","","","","","     ","","","","","","","","","","","","","","GCH","","","","@",""})
AADD(aRegs,{cPerg,"03","Evolu็ใo em  ?","","","mv_ch03","C",01,00,00,"C","","mv_par03","Dias","","","","","M๊s","","","","","Anos","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Opcใo Grafico ?","","","mv_ch04","C",01,0,0,"C","","mv_par04","Barras","","","","","Linhas","","","","","Pontos","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Faixa Padr ?","","","mv_ch05","C",01,0,0,"C","","mv_par05","Nใo","","","","","Sim","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Audiometria ?","","","mv_ch06","C",01,0,0,"C","","mv_par06","Nใo","","","","","Ouv.Direito ","","","","","Ouv. Esquerdo","","","","","","","","","","","","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1)

If (SX1->( !dbSeek(aRegs[5,1]+Space(Len(SX1->X1_GRUPO)-Len(cPerg))+aRegs[5,2])) .OR. SX1->( !dbSeek(aRegs[6,1]+Space(Len(SX1->X1_GRUPO)-Len(cPerg))+aRegs[6,2]))) // Significa que a pergunta nใo existe.

	// Se a pergunta 9 nใo existe ้ porque o dicionario esta antigo. Entใo apago todas pra recriar com a nova estrutura.
	If SX1->( dbSeek(aRegs[1,1]+Space(Len(SX1->X1_GRUPO)-Len(cPerg))+aRegs[6,2]))
		While !SX1->( Eof() ) .and. Alltrim(SX1->X1_GRUPO) == cPerg
			SX1->( RecLock("SX1", .F.) )
			SX1->( dbDelete() )
			SX1->(MsUnlock())
			SX1->(dbSkip())
		Enddo
	Endif
	For i := 1 To Len(aRegs)
		lInclui := !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	
		aHelpPor := {} ; aHelpSpa := {} ; 	aHelpEng := {}
		IF i == 1
			AADD(aHelpPor,"Informe a Pergunta Tempo ")
			AADD(aHelpPor,"Exemplo : Idade Gestacional ")			
			AADD(aHelpPor," que serแ  filtrada para ser ")
			AADD(aHelpPor," exibida na Evolu็ใo do Grแfico ")
		ELSEIF i==2
			AADD(aHelpPor,"Informe a pergunta de evolu็ใo    ")
			AADD(aHelpPor," desejado para a Linha do Grafico")
			AADD(aHelpPor," Juntamente com a pergunta escolhida")
			AADD(aHelpPor," anteriormente")
		ELSEIF i==3
			AADD(aHelpPor,"Informe a op็ใo de evolu็ใo do Grแfico")
			AADD(aHelpPor,"em dias , m๊ses ou anos ")
			AADD(aHelpPor," que serแ exibido na Gera็ใo do Relatorio")
			
		ELSEIF i==4
			AADD(aHelpPor,"Informe a op็ใo de Graficos")
			AADD(aHelpPor," que serแ exibido na Gera็ใo do Relatorio")

		ELSEIF i==5
			AADD(aHelpPor,"Informe se serแ exibido no grแfico")
			AADD(aHelpPor,"caso configurado para a pergunta")
			AADD(aHelpPor," a Linha de Percentil para cada Pergunta  ")
			AADD(aHelpPor," de evolu็ใo de Tempo")		
			
		ELSEIF i==6
			AADD(aHelpPor,"Informe se este Relatorio grแfico")
			AADD(aHelpPor,"	้ de Audiometria")
			AADD(aHelpPor," Caso selecionado esta op็ใo serแ exibido  ")
			AADD(aHelpPor," apenas dados referente a Audiometria Grแfica")				
		ENDIF

		PutSX1Help("P."+alltrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
	Next   
Endif

Return()
