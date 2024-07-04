
#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "RPTDEF.CH"

STATIC oFnt12N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt12C 		:= TFont():New("Arial",12,12,,.f., , , , .t., .f.)
STATIC oFnt14N		   := TFont():New("Arial",18,18,,.t., , , , .t., .f.)
static objCENFUNLGP := CENFUNLGP():New() 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR252   º Autor ³ Paulo Carnelossi   º Data ³  21/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime declaracao de para Usuario        				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

@history
   Vinicius.Queiros 30/12/2019
   Refeito o codigo para imprimir utilizando o FWMSPrinter, onde será impresso
   Logo do Grupo Empresa e também o usuário poderá manipular o texto,
   informando o local do arquivo (Bloco de Notas).
/*/

Function PLSR252()

// Declaracao de Variaveis                                            
Local cArquivo       := "" // Caminho do arquivo txt que contem o texto do usuário
Local lRet
Local cMat
Local cLoc
Local cEmp
Private nlimite      := 85 // Limite da linha
Private nTipo        := 18
Private cPerg        := "PLR252"
Private cFileName		:= "Declaracao_Uso_"+CriaTrab(NIL,.F.)
Private oReport

//-- LGPD ----------
if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)

oReport:setDevice(IMP_PDF)
oReport:setMargin(10,10,10,10)
oReport:SetPortrait() 

If !Pergunte(cPerg,.T.)
   Return
EndIf

cMat     := AllTrim(mv_par01)
cLoc     := AllTrim(mv_par02)
cEmp     := AllTrim(mv_par03)
cArquivo := AllTrim(mv_par04) 

oReport:Setup()  //Tela de configurações

If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
   Return{"",""}
EndIf

lRet := RunReport(oReport,cMat,cLoc,cEmp,cArquivo)

IF (lRet)   
	oReport:EndPage()
	oReport:Print()
ENDIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP5 IDE            º Data ³  21/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(oReport,cMat, cLoc, cEmp , cArquivo)

Local cMatric
Local nAux         := 0
Local cMvPLCDTGP   := GETMV("MV_PLCDTGP")
Local nLin         := 50
Local cLogo        := GetSrvProfString("StartPath","")+"\"

Local cFileArq, nX, nCtdLin, cLinha, nY, lTagAberta, cTxtLin, cCampo, cLinhaNova

oReport:StartPage()

dbSelectArea("BA1")
BA1->(dbSetOrder(2))

If !BA1->(dbSeek(xFilial("BA1")+cMat))
	MsgStop("O usuario nao foi encontrado")
	Return
Endif

cMatric := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC

// Verifica qual Logo será usado
IF File(cLogo+"LGMID"+cEmpAnt+cFilAnt+".PNG") 
   cLogo += "LGMID"+cEmpAnt+cFilAnt+".PNG" 
ElseIf File(cLogo+"LGMID"+cEmpAnt+".PNG")
   cLogo += "LGMID"+cEmpAnt+".PNG" 
ElseIf File(cLogo+"LGMID.PNG")
   cLogo += "LGMID.PNG" 
Else
   nLin := 90
EndIf

// Se o logo foi achado, imprimi o Logo
If nLin == 50
   oReport:SayBitmap(nLin, 230, cLogo ,135, 85)
   nLin := 185
EndIf

oReport:Say(nLin,215,"D  E  C  L  A  R  A  Ç  Ã  O",oFnt14N)

nLin += 50
cFileArq := DecodeUtf8(MemoRead(cArquivo)) // Busco o arquivo se existe

If Empty(cFileArq) // Se o retorno for em branco, imprimo o padrão
   oReport:Say(nLin,100,"Declaramos para os devidos fins, que o Sr.(a) "+BA1->BA1_NOMUSR+"",oFnt12C)
   nLin += 15
   oReport:Say(nLin,100,"é usuario do Plano de Saude  " + cEmp + ", com inicio em "+DtOc(BA1->BA1_DATINC)+ " ate a presente data.",oFnt12C)
   nLin += 15
Else // Imprimo o texto do arquivo do usuário

   nCtdLin     := MLCount(cFileArq, nlimite) // Quebra a linha caso ultrapasse o limite de caracteres por linha
   cLinhaNova  := ""
   For nX := 1 TO nCtdLin
      cLinha := Alltrim(MemoLine(cFileArq,nlimite,nX))
      If AT("<",cLinha) > 0
         lTagAberta  := .F.
         cTxtLin     := ""
         cCampo      := ""

         For nY := 1 To Len(cLinha)
            If Substr(cLinha,nY,1) $ "<" .Or. lTagAberta
               If !lTagAberta
                  lTagAberta := .T.
               Else
                  If Substr(cLinha,nY,1) $ ">"
                     lTagAberta := .F.
                  Else
                     cCampo += Substr(cLinha,nY,1)
                  EndIf
               EndIf 
            Else
               cTxtLin += Substr(cLinha,nY,1)
            EndIf

            IF !Empty(cCampo) .And. !lTagAberta
               If UPPER(cCampo) $ "INSTITUICAO" // Instituicao informado na pergunta
                  cTxtLin += cEmp
               ElseIf FieldPos(cCampo) > 0
                  If Valtype(&("BA1->"+cCampo)) == "D"
                     cTxtLin += DtOc(&("BA1->"+cCampo))               
                  Else
                     cTxtLin += Alltrim(&("BA1->"+cCampo))
                  EndIf
               EndIf
               cCampo := ""
            EndIf
         Next 
         cLinha := cTxtLin
      EndIf 

      cLinhaNova += cLinha+" "

   Next

   nCtdLin   := MLCount(cLinhaNova,nlimite) 
   For nX := 1 TO nCtdLin
      cLinha := MemoLine(cLinhaNova,nlimite,nX)

      oReport:Say(nLin,100,cLinha,oFnt12C)
      nLin += 15
   Next

EndIf

nLin += 15

oReport:Say(nLin,100,"Matricula:",oFnt12N)
oReport:Say(nLin,147,BA1->BA1_CODINT+"."+BA1->BA1_CODEMP+"."+BA1->BA1_MATRIC+"-"+BA1->BA1_TIPREG+"-"+BA1->BA1_DIGITO,oFnt12C)

BA3->(dbSetOrder(1))
IF !BA3->(dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
	MsgStop("Erro ao procurar a Familia")
	Return (.F.)
ENDIF

nLin += 15
oReport:Say(nLin,100,"Produto: ",oFnt12N)
oReport:Say(nLin,142,Padr(BA3->BA3_CODPLA + " - " + Posicione("BI3",1,xFilial("BI3")+BA3->BA3_CODINT+BA3->BA3_CODPLA,"BI3_DESCRI"),60),oFnt12C)

// Imprime dependentes...                                              
BA1->(DbCloseArea())
dbSelectArea("BA1")
BA1->(dbSetOrder(2))

if !BA1->(dbSeek(xFilial("BA1")+cMatric))
	MsgStop("O usuario nao foi encontrado")
	Return (.F.)
Endif

While ! Eof() .And. BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC == cMatric

     If BA1->BA1_TIPREG <> cMvPLCDTGP
        If nAux == 0
           nLin += 30
           oReport:Say(nLin,100,"Dependentes do Plano: ",oFnt12N)
           nLin += 15 
        Endif
        nAux++
        nLin += 5 
        oReport:Say(nLin,120,BA1->BA1_NOMUSR,oFnt12C)
     Endif    
     BA1->(DbSkip())    
Enddo

nLin += 50
oReport:Say(nLin,215,cLoc+", "+AllTrim(Str(Day(Date())))+" de "+MesExtenso(Month(Date()))+" de "+AllTrim(Str(Year(Date())))+".",oFnt12C)
nLin += 15
nLin += 15

Return (.T.)

