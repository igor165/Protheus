#INCLUDE "PLSC005.ch"
#include "PLSMCCR.CH"                                      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSC005  ³ Autor ³ Angelo Sperandio      ³ Data ³ 13/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta carencias do usuario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSC005()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAPLS                                                    ³±±
±±³          ³ O BA1-Usuarios deve estar posicionado no usuario           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSC005(oBrwUsr,oBrwDoe)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cRdmake     := "",i
local i			:= 0
Local aButtons    := {} 
Local lVolta      := .F.
Local aOpc		:= {}
Local nPosMatric:=0
Local nPosCid		:=0
Local cCid			:=""
Private cPerg       := "PLC005"
Private aLog        := {}
Private aLog1       := {}
Private aDetalhe    := {}
Private lEnd		:= .F.
Private cPerg   	:= "PLC005"
Private lCanc 	:= .F.


If ValType(oBrwUsr) ="O"  .AND. ValType(oBrwDoe) ="O"// Posicionando o usuario correto selecionado na browse 

	nPosMatric:= PLRETPOS("BA1_MATUSU",oBrwUsr:aHeader)
	nPosCid	:= PLRETPOS("BF3_CODDOE",oBrwDoe:aHeader)

	BA1->(DbSetOrder(2))
	BA1->(DbGoTop())
	BA1->(DbSeek(xFilial("BA1")+oBrwUsr:aCols[oBrwUsr:oBrowse:nat,nPosMatric]))
	
	cCid:= oBrwDoe:aCols[oBrwDoe:oBrowse:nat,nPosCid]

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se BA1-Usuario esta posicionado                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  BA1->(bof()) .or. BA1->(eof())
    msgalert(STR0001) //"Informe o usuario"
    Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consulta carencias                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
msAguarde( {|lEnd| PLSC005C(@lEnd,aLog,aLog1,aDetalhe,cCid) }, STR0002,"", .T.) //"Analisando procedimentos ..."
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta tela de carencias                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ExistBlock("PL005IMP")
    cRdmake := "PL005IMP"
Else
    cRdmake := ""
Endif 

Aadd(aButtons, {"HISTORIC",{ || PLSCCPT() },STR0003,STR0004} )	 // //"Visualizar Doenças Pré-Existentes"###"CID"
       
If  len(aLog) > 0
    While .T.
       aOpc := PLSCRIGEN(aLog,{{STR0005,"@!",40},{STR0006,"@!",180},{STR0007,"@!",50},{STR0008,"@!",50}},STR0009 + BA1->BA1_NOMUSR,IIF(lVolta,.F.,nil),STR0010,nil,aButtons,nil,cRdmake) //"Procedimento"###"Descricao"###"Possui cobertura ?"###"Carencia cumprida ?"###"Consulta cobertura/carencia de procedimentos - "###"Para consultar detalhes da carencia posicione sobre o procedimento desejado e clique no botao de verde de confirmacao (ok)"
       If  ! aOpc[1]
           Exit
       Endif
       x     := aOpc[2]
       cCod  := alltrim(aLog[x][1])
       cDes  := alltrim(aLog[x][2])
       If  aLog[x][3] == "Nao" .or. aLog[x][4] == "Nao"
           aLog1 := {}
           For i := 1 to len(aDetalhe[x][2])
               aadd(aLog1,{aDetalhe[x][2][i][2],aDetalhe[x][2][i][3]})
           Next
           PLSCRIGEN(aLog1,{{STR0006,"@!",200},{STR0011,"@!",50}},STR0012 + cCod + " - " + cDes,nil,nil) //"Descricao"###"Informacao"###"Detalhes sobre cobertura/carencia do procedimento "
           lVolta:=.T.
       Endif
    Enddo
Else
    If lCanc
    	msgalert(STR0030)     //"Cancelado pelo usuário."
    Else
    	msgalert(STR0013)     //"Nenhum procedimento foi encontrado para os parametros informados"
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do programa                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSC005C ³ Autor ³ Angelo Sperandio      ³ Data ³ 13/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta carencias do usuario                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PLSC005C(lEnd,aLog,aLog1,aDetalhe,cCid)
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL cRecBA1 := BA1->(Recno())
LOCAL bRest   := {|| BA1->(DbSetOrder(nOrdBA1)) , BA1->(DbGoto(cRecBA1)) }
LOCAL aDadRDA := PLSGetRDA()
LOCAL cCob    := "Sim"
LOCAL cCar    := "Sim"
LOCAL nI	  := 1
Private i, j, z, nTamRegra, nTamUsuario
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicita parametros                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! Pergunte(cPerg,.T.)
    Return()
Endif    

PLLimpCCri(.T.) //limpo as criticas para nao acumular

cProDe  := mv_par01
cProAte := mv_par02
cCodPad := mv_par03
nListar := mv_par04
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica formato dos parametros informado                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cProDe := alltrim(cProDe)
If  empty(cProAte)
    If  len(cProDe) >= 8
        cProAte := cProDe + space(TamSX3("BR8_CODPSA")[1] - len(cProDe))
    Else
        cProAte := cProDe + replicate("Z",TamSX3("BR8_CODPSA")[1] - len(cProDe))
    Endif
Endif
cProDe := cProDe + space(TamSX3("BR8_CODPSA")[1] - len(cProDe))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDataEve := dDataBase
cHoraEve := time()
nQtd     := 1
aDadUsr  := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.T.,dDataBase)
If  ! aDadUsr[1]
    msgalert(STR0014) //"Usuario invalido"
    Return()
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os procedimentos conforme parametros                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(dbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
BR8->(dbSeek(xFilial("BR8")+cCodPad+cProDe,.T.))
While ! BR8->(eof()) .and. BR8->BR8_FILIAL == xFilial("BR8") .and. BR8->BR8_CODPAD == cCodPad .and. ;
                            BR8->BR8_CODPSA <= cProAte .and. BR8->BR8_PROBLO <> "1"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se foi cancelado...				                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		aLog := {}
		lCanc := .T.
		Return
	Endif
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se o procedimento eh analitico                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If  BR8->BR8_ANASIN <> "1"
       BR8->(dbSkip())
       Loop
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Mensagem de processamento                                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   msProcTxt(STR0015 + BR8->BR8_CODPSA) //"Analisando procedimento "
   ProcessMessage()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Inicializa variaveis                                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cCodPad := BR8->BR8_CODPAD
   cCodPro := BR8->BR8_CODPSA
   cCob    := "Sim"
   cCar    := "Sim"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica cobertura / carencia                                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aRet := PLSAUTP(dDataEve,cHoraEve,cCodPad,cCodPro,nQtd,aDadUsr,nil,aDadRDA,"1",.F.,cCid,.T.)
   
   If  ! aRet[1]
   
       For nI:=1 To Len(aRet[2])
	       If  aRet[2,nI,1] $ __aCdCri001[1]  //__aCdCri001 {"501","Usuario nao possui cobertura para este procedimento."}
           cCob := "Nao"
           cCar := ""
	           exit
       Endif
	       
	       If  aRet[2,nI,1] $ __aCdCri003[1]  //__aCdCri003 {"002","Procedimento em carencia para este usuario."}
           cCar := "Nao"
       Endif   
       Next   
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Salva procedimento no array                                              ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If  nListar == 1 .or. ;
           nListar == 3 .or. ;
          (nListar == 2 .and. cCar == "Nao")
           aadd(aLog,{BR8->BR8_CODPAD + " " + BR8->BR8_CODPSA,BR8->BR8_DESCRI,cCob,cCar})
           aadd(aDetalhe,aRet)
       Endif
   Else
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Salva procedimento no array - caso seja para listar todos                ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If  nListar == 3
           aadd(aLog,{BR8->BR8_CODPAD + " " + BR8->BR8_CODPSA,BR8->BR8_DESCRI,cCob,cCar})
           aadd(aDetalhe,aRet)
       Endif
   Endif   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Acessa proximo registro                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BR8->(dbSkip())
Enddo 
Eval(bRest)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da funcao                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCCPT  ³ Autor ³ Luciano Aparecido     ³ Data ³ 31/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Doenças Pre - Existentes                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCCPT()
Local aArea     := GetArea()
Local aDados    := {}
Local cUnid     := "" 
Local cSQL      := ""
Local cPag      := ""
Local cDatCpt	:= ""
Local nDias		:= 0
Local cCod      := BA1->(BA1_CODINT)
Local cEmp      := BA1->(BA1_CODEMP)
Local cMatr     := BA1->(BA1_MATRIC)
Local cTpReg    := BA1->(BA1_TIPREG)

cSQL := "SELECT BF3.BF3_CODDOE,BF3.BF3_PAGAGR,BF3.BF3_VALAGR,BF3.BF3_PERAGR, BF3.BF3_MESAGR, BF3.BF3_UNAGR , BF3.BF3_DATCPT, "
cSQL += "BA9.BA9_DOENCA FROM " + RetSQLName("BF3")+ " BF3, " + RetSQLName("BA9")+ " BA9" +" WHERE "

cSQL += "BF3_FILIAL = '"+xFilial("BF3")+"' AND "
cSQL += "BF3.BF3_CODINT = '"+cCod+"' AND "
cSQL += "BF3.BF3_CODEMP = '"+cEmp+"' AND "
cSQL += "BF3.BF3_MATRIC = '"+cMatr+"' AND "
cSQL += "BF3.BF3_TIPREG = '"+cTpReg+"' AND "
cSQL += "BF3.D_E_L_E_T_ = ' ' AND "

cSQL += "BA9.BA9_FILIAL = '"+xFilial("BA9")+"' AND "
cSQL += "BA9.BA9_CODDOE = BF3.BF3_CODDOE AND "
cSQL += " BA9.D_E_L_E_T_ = ' ' "

PLSQUERY(cSQL,"Trb")

While ! Trb->(EOF())
    
    If Trb->BF3_MESAGR == 0
		cUnid	:=""
		cDatCPt :="" 
	Else
		DO CASE
			CASE Trb->BF3_UNAGR =="1" 
				cUnid	:=STR0016 //"Horas"
				nDias := IIf(Trb->BF3_MESAGR > 24,Int(Trb->BF3_MESAGR/24),0) 
				cDatCPt :=DtoC(Trb->BF3_DATCPT+nDias)
			CASE Trb->BF3_UNAGR =="2" 
				cUnid:=STR0017 //"Dias"
				nDias 	:= PLSCarDias(Trb->BF3_MESAGR,Trb->BF3_UNAGR)
				cDatCPt :=DtoC(Trb->BF3_DATCPT+nDias)
			CASE Trb->BF3_UNAGR =="3" 
				cUnid:=STR0018 //"Meses"
				If  Empty(Trb->BF3_DATCPT)
					If Empty(BA1->BA1_DATCPT)
						nDias	:=	Abs(( date() -MonthSum( date() , 0 )))
						cDatCPt:= 	DtoC(date()+nDias)
					Else
						nDias	:=	Abs((BA1->BA1_DATCPT -MonthSum(BA1->BA1_DATCPT , Trb->BF3_MESAGR )))
						cDatCPt:= 	DtoC(BA1->BA1_DATCPT+nDias)
					Endif		
					
				Else
					nDias	:=	Abs((Trb->BF3_DATCPT -MonthSum(Trb->BF3_DATCPT , Trb->BF3_MESAGR )))
				cDatCPt :=DtoC(Trb->BF3_DATCPT+nDias)
				Endif	
			CASE Trb->BF3_UNAGR =="4" 
				cUnid:=STR0019 //"Anos"
				nDias 	:= PLSCarDias(Trb->BF3_MESAGR,Trb->BF3_UNAGR)
				cDatCPt :=DtoC(Trb->BF3_DATCPT+nDias)
			OTHERWISE
				cUnid:=""
		ENDCASE
	Endif
	
	IF Trb->BF3_PAGAGR == "0"
		cPag:= STR0020 //"Nao"
	ElseIf Trb->BF3_PAGAGR == "1"
		cPag:= STR0021 //"Sim"
	Endif

	aAdd(aDados,{Trb->BF3_CODDOE,;
				 Trb->BA9_DOENCA,;
				 cPag,;
				 IIF(Trb->BF3_PAGAGR == "0","",Transform(Trb->BF3_VALAGR,"@E 999,999,999.99")),;
				 IIF(Trb->BF3_PAGAGR == "0","",Trb->BF3_PERAGR),;
				 If(Empty(BF3->BF3_DATCPT),If(Empty(BA1->BA1_DATCPT),date(),BA1->BA1_DATCPT),Trb->BF3_DATCPT),;
				 IIF(Trb->BF3_MESAGR == 0 ,"",Alltrim(STR(Trb->BF3_MESAGR)))+" "+cUnid,;
				 cDatCPt})

	Trb->(dbSkip())

EndDo

If  len(aDados) > 0
    PLSCRIGEN(aDados,{	{STR0004,"@!",25},;
    					{STR0006,"@!",TamSX3("BA9_DOENCA")[1]},;
    					{STR0022,"@!",20},;
    					{STR0023,"@!",35},;
    					{STR0024,"@!",20},;
    					{STR0025,"@!",25},;
    					{STR0026,"@!",35},;
    					{STR0029,"@!",35}},STR0027 + BA1->BA1_NOMUSR) //"CID"###"Descricao"###"Paga Agravo/CPT"###"Vlr Agravo"###"% Mensalid"###"Data Base CPT"###"Tempo Agravo/CPT"###"Consulta Doenças Pré-Existentes - "
Else
    msgalert(STR0028)     //"Nenhuma Doença Pré-Existente"
EndIf

Trb->(DbCloseArea()) 

RestArea(aArea)

Return
