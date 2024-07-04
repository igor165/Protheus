#include "MSBARHP.CH"
#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'MSOBJECT.CH'  


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MSBAR       ³ Autor ³ ALEX SANDRO VALARIO ³ Data ³  06/99   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime codigo de barras                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 01 cTypeBar String com o tipo do codigo de barras          ³±± 
±±³          ³ 				"EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"     ³±±
±±³          ³ 				"INT25","MAT25,"IND25","CODABAR","CODE3_9"     ³±±
±±³          ³ 				"EAN128"                                       ³±±
±±³          ³ 02 nRow		Numero da Linha em centimentros                ³±±
±±³          ³ 03 nCol		Numero da coluna em centimentros				     ³±±
±±³          ³ 04 cCode		String com o conteudo do codigo                ³±±
±±³          ³ 05 oPr		Obejcto Printer                                ³±±
±±³          ³ 06 lcheck	Se calcula o digito de controle                ³±±
±±³          ³ 07 Cor 		Numero  da Cor, utilize a "common.ch"          ³±±
±±³          ³ 08 lHort		Se imprime na Horizontal                       ³±±
±±³          ³ 09 nWidth	Numero do Tamanho da barra em centimetros      ³±±
±±³          ³ 10 nHeigth	Numero da Altura da barra em milimetros        ³±±
±±³          ³ 11 lBanner	Se imprime o linha em baixo do codigo          ³±±
±±³          ³ 12 cFont		String com o tipo de fonte                     ³±±
±±³          ³ 13 cMode		String com o modo do codigo de barras CODE128  ³±±
±±³          ³ 14 lPrint	Logico que indica se imprime ou nao            ³±±
±±³          ³ 15 nPFWidth	Numero do indice de ajuste da largura da fonte ³±±
±±³          ³ 16 nPFHeigth Numero do indice de ajuste da altura da fonte ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ImpressÆo de etiquetas c¢digo de Barras para HP e Laser    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
A partir do dia 11/12/04, este fonte foi convertido para utilizacao no
formato de classes conteudo algumas melhorias
1) possibilidade de ter espaco em branco dentro do codigo 128
2) possibllidade de ter banner em todos os tipos de codigo de barras
3) Criacao do tipo EAN 128
4) possibilidade de mudancas de tipos de subconjunto (ABC) para CODE128 e EAN128 
5) Tratamento de AIs do padrao EAN  somente para o tipo EAN128
6) possiblidade de informar o indice de ajuste para a largura e altura do banner (codigo impresso abaixo das barras)
7) tratamento com mensagens de erros  
*/                                   

// rotinas de chamadas das funcoes
//         			 1		  2	 3		 4		 5		  6      7		 8	    9	     10     11      12    13     14      15       16
Function MSBAR(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:= CBBAR():New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:Draw()
Return                            
Function MSBAR2(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:= CBBAR():New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:useOldCm2Pix:= .F.
   oBar:Draw()
Return                            
Function MSBAR3(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:= CBBAR():New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:useOldCm2Pix:= .F.
// nrs da HP LaserJet 4 
   oBar:nVertRes:= 3720
   oBar:nHorzRes:= 2400
   oBar:nVertSize:= 271
   oBar:nHorzSize:= 203
   oBar:Draw()
Return                            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na MSBAR4 o parametro nWidth realmente especifica o       ³
//³tamanho desejado do codigo de barra inteiro.              ³
//³Ao Contrario da outras usavam ele para o espaçamento entre³
//³as barras.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function MSBAR4(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:= CBBAR():New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
   oBar:useOldCm2Pix:= .F.
// nrs da HP LaserJet 4 
   oBar:nVertRes:= 3720
   oBar:nHorzRes:= 2400
   oBar:nVertSize:= 271
   oBar:nHorzSize:= 203
   oBar:lCalcSpace :=.T.
   oBar:Draw()
Return                            



//--------------------------------
CLASS CBBAR
   data useOldCm2Pix
   data nVertRes
   data nHorzRes
   data nVertSize
   data nHorzSize
   data nRow 
   data nCol 
   data oPrint
   data lCheck
   data lHorz
   data nWidth
   data nHeigth
   data lBanner
   data cFont
   data cMode
   data lPrint
   data cConteudo
   data cBanner
   data nIndice       
   data cTypeBar                      
   data cCode                                             
   data Color
   data nPFWidth   // indice de ajuste do tamanho da fonte
   data nPFHeigth  // indice de ajuste da altura da fonte
   data cErro 
   data lCmtr2Pix
   Data lCalcSpace
   data C128GS
   data C128A
	data C128B
	data C128C
	data C128S
	data lEan128      
	data cBanEan128
	data nTxTVert
  	Method New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix) 
	Method CBCODE128()
	Method CBCODE3_9()
	Method CBEAN13()
	Method CBEAN8()
	Method CBUPCA()
	Method CBSUP5()
	Method CBCODABAR()
	Method CBINT25()
	Method CBIND25()
	Method CBMAT25()	
	Method Draw()         
   Method FillBar(cConteudo,nIndice,nIniVertical) 	
   Method Banner()
   Method MsgErro() 
   Method TrataEan(aConteudo)
ENDCLASS

/*
Tipo de codigos de barras para cTypebar:
CODE128
CODE3_9
EAN13
EAN8   
EAN128
UPCA
SUP5
CODABAR
INT25
IND25
MAT25
*/
Method New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix) CLASS CBBAR
Local bBlock

default nRow    	:= 0 
default nCol    	:= 0 
default oPrint  	:= ReturnPrtObj()
default cTypeBar	:= "EAN13" 
default lCheck  	:= .t.
default Color   	:= CLR_BLACK
default lHorz   	:= .t.
default lCmtr2Pix 	:= .t.
default nWidth  	:= 0.025 // 1/3 M/mm  ************** no final do desenvolvimento aumentar para 0.05
default nHeigth 	:= 1.5
default cFont   	:= 'arial'
default lPrint	 	:= .T.
Default cMode   	:= ''  
Default nPFWidth	:= 1
Default nPFHeigth	:= 1     


If lBanner ==NIL .and. Trim(Upper(cTypeBar))=="SUP5"
   If lHorz
      lBanner := .t.
   Else 
      lBanner := .f. 
   EndIf   
ElseIf lBanner==NIL 
   lBanner := .f. 
EndIf

::useOldCm2Pix:= .T.
::lCalcSpace  := .F.
::nVertRes    := oPrint:nVertRes()
::nHorzRes    := oPrint:nHorzRes()
::nVertSize   := oPrint:nVertSize()
::nHorzSize   := oPrint:nHorzSize()
::nRow        := nRow
::nCol        := nCol
::cTypeBar    := Trim(Upper(cTypeBar))
::lCheck      := lCheck
::lHorz       := lHorz
::nWidth      := nWidth // 1/3 M/mm
::nHeigth     := nHeigth
::lBanner     := lBanner
::cFont       := cFont
::lPrint	     := lPrint
::cMode       := cMode
::nIndice     := 1
::cCode       := cCode
::Color       := Color
::oPrint      := oPrint
::cBanner     := ''
::nPFWidth    := nPFWidth
::nPFHeigth   := nPFHeigth
::cErro       := ''
::lEAN128     := .F.
::cBanEan128  := ''
::lCmtr2Pix   :=  lCmtr2Pix
::nTxTVert 	  := 0
If ValType(::cCode) =="A" 
   If ::cTypeBar <> "EAN128"
      ::cErro := STR0001//"Obrigatorio o tipo ser EAN128"
   EndIf
   ::cCode:= Self:TrataEan(::cCode)
EndIf  
If ::cTypeBar =="EAN128"
   ::lEAN128:= .T.
   ::cTypeBar:="CODE128"
EndIf
bBlock := &('{|| Self:CB'+::cTypeBar+'()}')
::cConteudo:=Eval(bBlock)

Return ''  

Method CBCODE128() CLASS CBBAR // MELHORIAS: MECANISMO DE MUDANCA DO SUBSET E A OPCAO DE TER O BANNER
Local cCode    := ::cCode
Local cStart   := ''
Local cConteudo:= ''
Local cBarra   := ''
Local cChar    := ''
Local N    		:= 0
Local nChar    := 0
Local nCount   := 0
Local nSum     := 0
Local nCheckSum:= 0
Local aCode    := {}


cStart:= Alltrim(Upper(::cMode))
aCode :={"212222","222122","222221","121223","121322","131222","122213",;
			"122312","132212","221213","221312","231212","112232","122132",;
			"122231","113222","123122","123221","223211","221132","221231",;
			"213212","223112","312131","311222","321122","321221","312212",;
			"322112","322211","212123","212321","232121","111323","131123",;
			"131321","112313","132113","132311","211313","231113","231311",;
			"112133","112331","132131","113123","113321","133121","313121",;
			"211331","231131","213113","213311","213131","311123","311321",;
			"331121","312113","312311","332111","314111","221411","431111",;
			"111224","111422","121124","121421","141122","141221","112214",;
			"112412","122114","122411","142112","142211","241211","221114",;
			"413111","241112","134111","111242","121142","121241","114212",;
			"124112","124211","411212","421112","421211","212141","214121",;
			"412121","111143","111341","131141","114113","114311","411113",;
			"411311","113141","114131","311141","411131","211412","211214",;
			"211232","2331112"}

If Empty(cStart) // analise do tipo de c¢digo (A,B ou C)
	If StrZero(Val(cCode),Len(cCode)) == cCode // Numerico
		cStart:= 'C'
	Else
		For N:= 1 to Len(cCode)
			nCount+= If(Asc(Substr(cCode,n,1)) > 31,1,0) // no cars. de control
		Next
		If nCount < (Len(cCode)/2)
			cStart:= 'A'
		Else
			cStart:= 'B'
		Endif
	Endif
Endif
If cStart == 'C'
	cConteudo:= aCode[106] // Start C
	nSum     := 105
Elseif cStart =='A'
	cConteudo:= aCode[104] // Start A
	nSum     := 103
Else
	cConteudo:= aCode[105] // Start B
	nSum     := 104
Endif

If ::lEan128 
	//Incluindo o Func1 para existir o caractere duplo inicial (exemplo: StartC+Func1)
	cConteudo += aCode[103]
	nSum      += 102
	nCount:= 1 // Variavel utilizada no CheckSum, inicializado com 1 (hum), devido o start inicial	
Else
	nCount:= 0 // Variavel utilizada no CheckSum
EndIf
For N:= 1 to Len(cCode)
	nCount++
	cChar:= Substr(cCode,N,1)
   
	//Verifica se existe separador de AIs
	If Substr(cCode,N,2)==">8" //GS
		cConteudo+= aCode[103]
		nSum+= (102)*nCount	
		N++
		Loop
	ElseIf Substr(cCode,N,2)==">7" //code a
		cConteudo+= aCode[102]
		nSum+= (101)*nCount	
		N++  
		cStart := 'A'
		Loop	
	ElseIf Substr(cCode,N,2)==">6" //code b
		cConteudo+= aCode[101]
		nSum+= (100)*nCount	
		N++  
		cStart := 'B'
		Loop	
	ElseIf Substr(cCode,N,2)==">5" //code c	
		cConteudo+= aCode[100]
		nSum+= (99)*nCount	
		N++  
		cStart := 'C'
		Loop		
	EndIf    

	If cStart == 'C'                           
		If Len(cCode) = N  // ultimo caracter
			cConteudo+= aCode[101] // SHIFT Code B
			nSum     += (100)*nCount
			nCount++			
			nChar    := Asc(cChar)-31    
		Else
			nChar:= Val(Substr(cCode,N,2))+1
			N++ // Incrementacao de 2 em 2 necessaria para compactacao (tipo C)
		Endif
	Elseif cStart == 'A'
		If cChar > '_' // Shift Code B
			cConteudo+= aCode[101]
			nChar:= Asc(cChar)-31
		Elseif cChar < ' '
			nChar:= Asc(cChar)+64
		Else
			nChar:= Asc(cChar)-31
		Endif
	Else // Code B standard
		If cChar < ' ' // Shift code A
			cConteudo+= aCode[102]
			nChar:= Asc(cChar)+64
		Else
			nChar:= Asc(cChar)-31
		Endif
	Endif
	nSum+= (nChar-1)*nCount
	cConteudo+= aCode[nChar]
Next

nCheckSum:= (nSum%103)+1
cConteudo+= aCode[nCheckSum]+aCode[107]
cBarra := ''
For N:=1 to Len(cConteudo) Step 2
	cBarra+= Replicate('1',Val(Substr(cConteudo,N,1)))
	cBarra+= Replicate('0',Val(Substr(cConteudo,N+1,1)))
Next   
Return cBarra
                                                                                          
Method CBCODE3_9() CLASS CBBAR   // MELHORIAS: MECANISMO DE MUDANCA DO SUBSET E A OPCAO DE TER O BANNER
Local n,nPos,nCheck:=0
Local cCars :='1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ-. *$/+%'
Local aBarras:={'1110100010101110','1011100010101110','1110111000101010',;
              '1010001110101110','1110100011101010','1011100011101010',;
              '1010001011101110','1110100010111010','1011100010111010',;
              '1010001110111010','1110101000101110','1011101000101110',;
              '1110111010001010','1010111000101110','1110101110001010',;//E
              '1011101110001010','1010100011101110','1110101000111010',;
              '1011101000111010','1010111000111010','1110101010001110',; //K
              '1011101010001110','1110111010100010','1010111010001110',;
              '1110101110100010','1011101110100010','1010101110001110',;
              '1110101011100010','1011101011100010','1010111011100010',;
              '1110001010101110','1000111010101110','1110001110101010',;
              '1000101110101110','1110001011101010','1000111011101010',;//Z
              '1000101011101110','1110001010111010','1000111010111010',; // ' '
              '1000101110111010','1000100010100010','1000100010100010',;
              '1000101000100010','1010001000100010'}
Local cConteudo:=''

::cCode := Upper(::cCode)
::cCode := '*'+Alltrim(Left(::cCode,32))+'*'

For n:= 1 to len(::cCode)
   nPos:=at(SubStr(::cCode,n,1), cCars )
   If nPos > 0 // outros caracteres se ignoran 
      cConteudo +=aBarras[nPos]
      nCheck += (nPos-1)
   end
Next
If ::lCheck
   cConteudo+= aBarras[nCheck%43 +1]
End  
return cConteudo


Method CBEAN13() CLASS CBBAR   
Local cRight	:="1110010110011011011001000010101110010011101010000100010010010001110100"
Local cLeft1	:="0001101001100100100110111101010001101100010101111011101101101110001011"
Local cLeft2	:="0100111011001100110110100001001110101110010000101001000100010010010111"
Local cFirst	:="ooooooooeoeeooeeoeooeeeooeooeeoeeooeoeeeoooeoeoeoeoeeooeeoeo"
Local cConteudo:=""
Local nX,nPos
Local nParte1:= 0
Local nParte2:= 0
Local nDigit := 0

Local cParte1:=""
Local cParte2:=""
Local cMascara:=""

If Len(Alltrim(Str(Val(::cCode),12))) < 12
   ::cErro:=STR0002  //"***Conteudo invalido para codigo EAN13***"
EndIf

::nIndice := 0.90	
::cCode :=Padr(Trim(::cCode),12,"0")

nParte1:=0                                         
nParte2:=0                                         
For nX:=1 to 6
	nParte1+=val(substr(::cCode,(nX*2)-1,1))
	nParte2+=val(substr(::cCode,(nX*2)  ,1))
next

nDigit:=(nParte2*3)+nParte1
nX:=10
While nDigit> nX
	nX:=nX+10
End
nDigit:=nX-nDigit

::cCode+=Str(nDigit,1,0) //calcula digito verificador
	
cParte1:=SubStr(::cCode,8,6)
cParte2:=substr(::cCode,2,6)

cMascara:=SubStr(cFirst,(val(SubStr(::cCode,1,1))*6)+1,6)

cConteudo :="101"
For nX:=1 to 6
   nPos:=val(SubStr(cParte2,nX,1))
   If substr(cMascara,nX,1)="o"
      cConteudo+=SubStr(cLeft1,nPos*7+1,7)
   Else
      cConteudo+=SubStr(cLeft2,nPos*7+1,7)
   End
Next
cConteudo+="01010"
For nX:=1 to 6
   nPos:=val(substr(cParte1,nX,1))
   cConteudo+=substr(cRight,nPos*7+1,7)
Next
cConteudo+="101"
::cBanner := '101'+replicate('0',42)+'01010'+replicate('0',42)+'101'
Return cConteudo

Method CBEAN8() CLASS CBBAR
Local nLen := 7
Local cRight:="1110010110011011011001000010101110010011101010000100010010010001110100"
Local cLeft :="0001101001100100100110111101010001101100010101111011101101101110001011"
Local nX       
Local nParte1:= 0
Local nParte2:= 0
Local cParte1:= ''
Local cParte2:= ''
Local nDigit   
Local nCount
Local cConteudo:='' 

If Len(Alltrim(Str(Val(::cCode),nLen))) < nLen
   ::cErro:=STR0003  //"***Conteudo invalido para codigo EAN8***"
EndIf

::nIndice := 0.90	
::cCode:=Padr(Trim(::cCode),nLen,"0")
	
For nX=1 to nLen step 2
	nParte1+=val(substr(::cCode,nX,1))
	nParte2+=val(substr(::cCode,nX+1,1))
Next
nDigit:=(nParte1*3)+nParte2
	
nCount:=10
While nDigit>nCount
	nCount+=10
End
nDigit:=nCount-nDigit
::cCode+=str(nDigit,1,0)

nLen++ // fara referencia ao condigo incluindo o digito

cParte1 :=Right(::cCode,nLen/2)
cParte2 :=Left (::cCode,nLen/2)
   
cConteudo:='101'
For nX=1 to len(cParte2)
   nCount:=val(substr(cParte2,nX,1))
   cConteudo+=substr(cLeft,nCount*7+1,7)
Next
cConteudo+='01010'
For nX=1 to len(cParte1)
   nCount:=val(substr(cParte1,nX,1))
   cConteudo+=substr(cRight,nCount*7+1,7)
Next
cConteudo+='101'                                                     
::cBanner := '101'+replicate('0',28)+'01010'+replicate('0',28)+'101'
Return cConteudo

Method CBUPCA() CLASS CBBAR
Local nLen := 11
Local cRight:="1110010110011011011001000010101110010011101010000100010010010001110100"
Local cLeft :="0001101001100100100110111101010001101100010101111011101101101110001011"
Local nX       
Local nParte1:= 0
Local nParte2:= 0
Local cParte1:= ''
Local cParte2:= ''
Local nDigit   
Local nCount
Local cConteudo:='' 

If Len(Alltrim(Str(Val(::cCode),nLen))) < nLen
   ::cErro:=STR0004  //"***Conteudo invalido para codigo UPCA***"
EndIf


::nIndice := 0.90	
::cCode:=Padr(Trim(::cCode),nLen,"0")
	
For nX=1 to nLen step 2
	nParte1+=val(substr(::cCode,nX,1))
	nParte2+=val(substr(::cCode,nX+1,1))
Next
nDigit:=(nParte1*3)+nParte2
	
nCount:=10
While nDigit>nCount
	nCount+=10
End
nDigit:=nCount-nDigit
::cCode+=str(nDigit,1,0)

nLen++ // fara referencia ao condigo incluindo o digito

cParte1 :=Right(::cCode,nLen/2)
cParte2 :=Left (::cCode,nLen/2)
   
cConteudo:='101'
For nX=1 to len(cParte2)
   nCount:=val(substr(cParte2,nX,1))
   cConteudo+=substr(cLeft,nCount*7+1,7)
Next
cConteudo+='01010'
For nX=1 to len(cParte1)
   nCount:=val(substr(cParte1,nX,1))
   cConteudo+=substr(cRight,nCount*7+1,7)
Next
cConteudo+='101'
 
::cBanner :='101'+Subs(cLeft,Val(Left(::cCode,1))*7+1,7)+Repl('0',35)+'01010'+Repl('0',35)+Subs(cRight,Val(Right(::cCode,1))*7+1,7)+'101'

Return cConteudo

Method CBSUP5()CLASS CBBAR
Local cParte1:= "0001101001100100100110111101010001101100010101111011101101101110001011"
Local cParte2:= "0100111011001100110110100001001110101110010000101001000100010010010111"
Local cAux   := "ooooooooeoeeooeeoeooeeeooeooeeoeeooeoeeeoooeoeoeoeoeeooeeoeo"
Local cConteudo:= '1011'
Local cControle
Local nX
Local nCar
Local cNewCode
::cCode:=Padr(Trim(::cCode),5,"0")
cControle := right(str(val(substr(::cCode,1,1))*3+val(substr(::cCode,3,1))*3 ;
              + val(substr(::cCode,5,1))*3+val(substr(::cCode,2,1))*9+;
              val(substr(::cCode,4,1))*9,5,0 ),1)
cControle:=substr(cAux,val(cControle)*6+2,5)

For nX:=1 to 5
   nCar:=val(substr(::cCode,nX,1))
   If substr(cControle,nX,1)='o'
      cConteudo+=substr(cParte2,nCar*7+1,7)
   Else
      cConteudo+=substr(cParte1,nCar*7+1,7)
   End
   If nX<5
      cConteudo+='01'
   end
next    

cNewCode:=''
For nX := 1 to 5
   cNewCode+=Subs(::cCode,nX,1)+' '
Next
::cCode := Alltrim(cNewCode)

Return cConteudo

Method CBCODABAR() CLASS CBBAR
Local cChar :='0123456789-$:/.+ABCDTN*E'
Local abar:={	"101010001110"  ,"101011100010"  ,"101000101110"  ,"111000101010"  ,;
		 		   "101110100010"  ,"111010100010"  ,"100010101110"  ,"100010111010"  ,;
				   "100011101010"  ,"111010001010"  ,"101000111010"  ,"101110001010"  ,;
				   "11101011101110","11101110101110","11101110111010","10111011101110",;
			   	"10111000100010","10001000101110",'10100011100010','10111000100010',;
				   '10001000101110','10100010001110','10100011100010'}
Local cCode := upper( ::cCode )
Local nCar,nX
Local cConteudo:=""

For nX:=1 to len( cCode )
	If (nCar:=at(substr(cCode,nX,1),cChar)) > 0
		cConteudo += aBar[nCar]
	EndIf
Next
return cConteudo 


Method CBINT25() CLASS CBBAR
Local cBarra    := ""
Local cConteudo := ""
Local cCode		 := ::cCode
Local cParte1	 := ""
Local cParte2	 := ""
Local nLen		 := 0
Local nCheck    := 0
Local nX,nY
Local	aBar      :={'00110','10001','01001','11000','00101','10100','01100',;
  	                 '00011','10010','01010'}
   
cCode:=trans(cCode,'@9') // elimina caracteres
If (nLen%2==1 .and.!::lCheck)
   nLen++
   cCode+='0'
End
If ::lCheck
   For nX:=1 to len(cCode) step 2
       nCheck+=val(substr(cCode,nX,1))*3+val(substr(cCode,nX+1,1))
   Next
   cCode += right(str(nCheck,10,0),1)
End
nLen:=len(cCode)
cBarra:= '0000'
For nX:=1 to nLen step 2
   cParte1 := aBar[val(substr(cCode,nX,1))+1]
   cParte2 := aBar[val(substr(cCode,nX+1,1))+1]
   For nY:=1 to 5
      cBarra += substr(cParte1,nY,1)+substr(cParte2,nY,1)
   Next
Next
cBarra+='100'
For nX:=1 to len(cBarra) step 2
	cConteudo += If(Subs(cBarra,nX  ,1)=='1','111','1')
	cConteudo += If(Subs(cBarra,nX+1,1)=='1','000','0')
Next
Return cConteudo                 


Method CBIND25() CLASS CBBAR                           
Local cConteudo := ""
Local cBar		 := ""
Local nX
Local nCheck	 := 0
Local	aBar      :={'00110','10001','01001','11000','00101','10100','01100',;
                   '00011','10010','01010'}

::cCode:=trans(::cCode,'@9') 
If ::lCheck
	For nX:=1 to len(::cCode) step 2
		nCheck+=val(substr(::cCode,nX,1))*3+val(substr(::cCode,nX+1,1))
	Next
	::cCode += right(str(nCheck,10,0),1)
End
cBar:='110'
For nX:=1 to len(::cCode)
	cBar+=aBar[val(substr(::cCode,nX,1))+1]+'0'
Next
cBar+='101'
For nX:=1 to len(cBar)
	cConteudo += If(Subs(cBar,nX,1)=='1','1110','10')
Next
Return cConteudo


Method CBMAT25()	CLASS CBBAR                
Local cConteudo := ""
Local cBar		 := ""
Local nCheck	 := 0
Local nX
Local	aBar      := {'00110','10001','01001','11000','00101','10100','01100',;
			            '00011','10010','01010'}

::cCode := Trans(::cCode,'@9') // only digits
If ::lCheck
	For nX:=1 to Len(::cCode) Step 2
         nCheck+=Val(Substr(::cCode,nX,1))*3+Val(Substr(::cCode,nX+1,1))
	Next
   ::cCode += Right(Str(nCheck,10,0),1)
EndIf
cBar:='10000'
For nX:=1 to Len(::cCode)
    cBar+=aBar[Val(Substr(::cCode,nX,1))+1]+'0'
Next
cBar+='10000'
For nX:=1 to Len(cBar) Step 2
  cConteudo += If(Subs(cBar,nX  ,1)=='1','111','1')
  cConteudo += If(Subs(cBar,nX+1,1)=='1','000','0')
Next
Return cConteudo

//-----metodos de desenho das barras ---------------------------------------------------------------------
Method Draw() CLASS CBBAR             
Local nIniVertical
If  ::lCmtr2Pix
	::oPrint:Cmtr2Pix(@::nRow, @::nCol, ::useOldCm2Pix)
Else
	::nRow := Round(::oPrint:nLogPixelX()*(::nRow/2.45),0)
	::nCol := Round(::oPrint:nLogPixelX()*(::nCol/2.45),0)
EndIf
If ! ::lHorz 
	If ::lBanner 
  	 // tramento especial somente ateh o objeto printer nao permitir rotacionar o texto     
 	  ::cErro:= STR0005//"***Codigo de barras com Banner nao disponivel p/ vertical****"
	Else
		::cBanner:= ''
	Endif
EndIf    
                                             
If Self:MsgErro() // verifica se tem algum erro 
   Return
EndIf

If ! ::lHorz
   nIniVertical :=round  ( ::nHeigth * 10 * ::nHorzRes / ::nHorzSize, 0 )*0.1
End
self:FillBar(::cConteudo,::nIndice,nIniVertical)  
If ! Empty(::cBanner)  
   self:FillBar(::cBanner)   
   ::lBanner := .t.
Endif
If ::lBanner
   self:Banner()
End   
If ::lPrint
	::oPrint:Print()
Endif
Return    
   

Method FillBar(cConteudo,nIndice,nIniVertical) CLASS CBBAR
Local n, oBr
Local ac:= array(4)
Local nHeigth
Local nWidth           
Local nCol := ::nCol
Local nRow := ::nRow
DEFAULT nIndice:= 1                   
DEFAULT nIniVertical := 0   
nCol +=nIniVertical
                     
nHeigth:= ::nHeigth*nIndice                    

oBR := TBrush():New(,::Color)
If !::lHorz  	                                   
	   nWidth  := Round  ( ::nWidth * 10 * ::nVertRes / ::nVertSize,0)   // largura da barra
	   nHeigth := Round  ( nHeigth * 10 * ::nHorzRes / ::nHorzSize,0)   //  altura   
Else
	   nWidth  := Round  (::nWidth * 10 * ::nHorzRes / ::nHorzSize	,0)  //largura
	   nHeigth := Round  (nHeigth * 10 * ::nVertRes / ::nVertSize  ,0)  //altura  
EndIf
If ::lCalcSpace //Nova forma de Calculo para MSBAR4
	nWidth := (::nWidth ) / Len(cConteudo) 
	If !::lHorz	
		nWidth *= 10 * 	::nVertRes / ::nVertSize
	Else
		nWidth *= 10 * ::nHorzRes / ::nHorzSize
	Endif
Endif

   
For n:=1 to len(cConteudo)
	If substr(cConteudo,n,1) =='1'
  	   ac[1]:= nRow
		ac[2]:= nCol
		If ::lHorz
			ac[3]:= nRow+nHeigth
			ac[4]:= nCol+nWidth
			nCol+=nWidth 
		Else
			ac[3]:= nRow+nWidth
			ac[4]:= nCol+nHeigth
			nRow+=nWidth
		End
  		::oPrint:fillRect(ac,oBr)			
	Else
		If ::lHorz
			nCol+=nWidth
		Else
			nRow+=nWidth
		End
	End
Next
oBr:end()
Return nil

Method Banner() CLASS CBBAR                                                     
Local nWidth  := ::nWidth
Local nHeigth := ::nHeigth           
Local nCol    := ::nCol
Local nRow    := ::nRow + ::nTxTVert
Local oFont   
Local oBr

If !::lHorz
    nWidth  :=round ( nWidth  * 10 * ::nVertRes / ::nVertSize ,0 )
	 nHeigth :=round ( nHeigth * 10 * ::nHorzRes / ::nHorzSize, 0 )
Else
    nWidth  :=round ( nWidth  * 10 * ::nHorzRes / ::nHorzSize, 0 )
	 nHeigth :=round ( nHeigth * 10 * ::nVertRes / ::nVertSize ,0 )
End


If ::cTypeBar+"|" $ "CODE128|CODE3_9|INT25|IND25|CODABAR|" 
	If ::cTypeBar== "CODE128"
		If !Empty(::cBanEan128)
			::cCode := ::cBanEan128
		EndIf
	   ::cCode := StrTran(::cCode,">8","")
	  	::cCode := StrTran(::cCode,">7","")
	   ::cCode := StrTran(::cCode,">6","")
	  	::cCode := StrTran(::cCode,">5","")         	
	EndIf
   define font oFont name ::cFont of ::oPrint size (nWidth*11.2)*::nPFWidth, (nHeigth*0.08)*::nPFHeigth nescapement if(::lHorz,0,13500)
	If ::lHorz
	  ::oPrint:say(nRow+nHeigth,nCol,::cCode,oFont,,::Color)
   End
ElseIf ::cTypeBar=="EAN13"
   define font oFont name ::cFont of ::oPrint size (nWidth*5.6)*::nPFWidth, (nHeigth*0.04)*::nPFHeigth nescapement if(::lHorz,0,13500)
   If ::lHorz
      ::oPrint:say(nRow+nHeigth*0.9,nCol-nWidth*8,Left(::cCode,1),oFont,,::Color)
      ::oPrint:say(nRow+nHeigth*0.9,nCol+nWidth*3,Substr(::cCode,2,6),oFont,,::Color)
      ::oPrint:say(nRow+nHeigth*0.9,nCol+nWidth*50,Substr(::cCode,8,6),oFont,,::Color)
   Else
      ::oPrint:say(nRow-nWidth*8,nCol+nHeigth*0.1,Left(::cCode,1),oFont,,::Color)
      ::oPrint:say(nRow+nWidth*3,nCol+nHeigth*0.1,Substr(::cCode,2,6),oFont,,::Color)
      ::oPrint:say(nRow+nWidth*50,nCol+nHeigth*0.1,Substr(::cCode,8,6),oFont,,::Color)
   End
ElseIf ::cTypeBar=="EAN8"
   define font oFont name ::cFont of ::oPrint size (nWidth*11.2)*::nPFWidth, (nHeigth*0.08)*::nPFHeigth nescapement if(::lHorz,0,13500)
	If ::lHorz
	   ::oPrint:say(nRow+nHeigth*0.9,nCol+nWidth*3,Left(::cCode,4),oFont,,::Color)
	   ::oPrint:say(nRow+nHeigth*0.9,nCol+nWidth*36,Right(::cCode,4),oFont,,::Color)
	Else
	   ::oPrint:say(nRow+nWidth*3,nCol+nHeigth*0.1,Left(::cCode,4),oFont,,::Color)
	   ::oPrint:say(nRow+nWidth*36,nCol+nHeigth*0.1,Right(::cCode,4),oFont,,::Color)
	End
ElseIf ::cTypeBar=="UPCA"
	define font oFont  name ::cFont of ::oPrint size (nWidth*8)*::nPFWidth, (nHeigth*0.06)*::nPFHeigth nescapement if(::lHorz,0,13500)
	If ::lHorz
	  ::oPrint:say(nRow+nHeigth*0.9,nCol-nWidth*8 ,Substr(::cCode, 1,1),oFont,,::Color)
	  ::oPrint:say(nRow+nHeigth*0.9,nCol+nWidth*10,Substr(::cCode, 2,5),oFont,,::Color)
	  ::oPrint:say(nRow+nHeigth*0.9,nCol+nWidth*50,Substr(::cCode, 7,5),oFont,,::Color)
	  ::oPrint:say(nRow+nHeigth*0.9,nCol+nWidth*95,Substr(::cCode,12,1),oFont,,::Color)
	Else
	  ::oPrint:say(nRow-nWidth* 8,nCol+nHeigth*0.1,Substr(::cCode, 1,1),oFont,,::Color)
	  ::oPrint:say(nRow+nWidth*10,nCol+nHeigth*0.1,Substr(::cCode, 2,5),oFont,,::Color)
	  ::oPrint:say(nRow+nWidth*50,nCol+nHeigth*0.1,Substr(::cCode, 7,5),oFont,,::Color)
	  ::oPrint:say(nRow+nWidth*95,nCol+nHeigth*0.1,Substr(::cCode,12,1),oFont,,::Color)
	end	
ElseIf ::cTypeBar=="SUP5"
   oBR := TBrush():New(,CLR_WHITE)
	define font oFont name ::cFont of ::oPrint size (nWidth*5.6)*::nPFWidth , (nHeigth*0.04)*::nPFHeigth nescapement if(::lHorz,0,13500)
	If ::lHorz
  		::oPrint:fillRect({nRow,nCol,nRow+nHeigth*.3,nCol+48*nWidth},oBr)			
	Else
	   ::oPrint:fillRect({nRow,nCol,nRow+41*nWidth,nCol+nHeigth*.3+48*nWidth},oBr)
	End
	::oPrint:say(nRow,nCol,::cCode,oFont,,::Color)
EndIf                                               
Return

Method MsgErro()  CLASS CBBAR
If ! Empty(::cErro)
	::oPrint:say(::nRow,::nCol,::cErro)
	::oPrint:Print()
	Return .t.
Endif	
Return .f. 

Method TrataEan(aConteudo) CLASS CBBAR
Local aVetAux:=MSCBTabEAN()  // esta funcao se encontra dentro do fonte mscbimp.prx
Local cTemp:=""          
Local nX,nX2
For nX:= 1 to len(aConteudo)
   nX2:=Ascan(aVetAux,{|x| x[1] == aConteudo[nX,1] })
   cTemp += aVetAux[nX2,1]
   If aVetAux[nx2,4] .and. nX < len(aConteudo) // se for verdadeiro, entao o tamanho nao eh fixo
      cTemp += Alltrim(aConteudo[nX,2])+CB128GS()
   Else //tamanho fixo
      cTemp += Alltrim(aConteudo[nX,2])
   EndIf       
   ::cBanEan128 += '('+aConteudo[nX,1]+')'+Alltrim(aConteudo[nX,2])+' '
Next
Return cTemp
	

Function CB128GS()
Return ">8"

Function CB128A()
Return ">7"

Function CB128B()
Return ">6"

Function CB128C()
Return ">5"


