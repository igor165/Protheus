#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "fileio.ch"

#DEFINE IMP_PDF  6
#DEFINE lSrvUnix IsSrvUnix()
//-------------------------------------------------------------------
/*/{Protheus.doc} PLRRN360
Ponto de entrada para impressao de Carteirinha do beneficiário. Regras
definidas na RN-360

@author  PLS TEAM
@version P11
@since   15.10.15
/*/
//-------------------------------------------------------------------
User Function PLRRN360()
Local cMatric		:= paramixb[1]
Local aDados		:= paramixb[2]
Local lWeb			:= paramixb[3]
Local cPathSrv	:= paramixb[4]
Local nLinMax		:= 0
Local nColMax		:= 0
Local nLinIni		:= 0
Local nColIni		:= 0
Local nColA4    	:= 0
Local nX			:= 0
Local nWeb			:= 0
Local nTweb		:= 1
Local nLweb		:= 0
Local nLwebC		:= 0
Local cFileName	:= ''
Local cMsg			:= ''
local cFileLogo	:= ''
Local cStartPath	:= GetSrvProfString("STARTPATH","")
Local cImgFrente	:= cStartPath + "\" + getNewPar("MV_PLSFRE", "frente.png")
Local cImgVerso 	:= cStartPath + "\" + getNewPar("MV_PLSVER", "verso.png")
Local cRel      	:= "carbene"
Local lContinua	:= .t.
Local oFont02		:= nil
Local oFont02n	:= nil
Local oFont03n	:= nil
Local oFont05n	:= nil
Local oPrint		:= nil
Local aRet			:= {}

cTitulo	 := "Carteirinha do Beneficiário"

//quando for chamada web aciona a funcao para validacao e busca dos dados a serem impresso (lote de carteirinha)
If lWeb
	
	aDados := U_PLRNCARTE(cMatric)
EndIf

//em montagem ou alteracao do layout do relatorio usar esta matriz
/*aDados := { {	replicate('A',30),; 					//01 - nome do beneficiario
replicate('B',21),; 										//02 - numero da matricula
replicate('C',10),; 										//03 - data de ascimento do beneficiario
replicate('D',15),; 										//04 - numero do cartao naciona de saude CNS
replicate('E',12),; 										//05 - numero do registro do plano ou do cad. do plano na ans
replicate('F',56),; 										//06 - segmentacao assistencial do plano
replicate('G',6),; 										//07 - codigo do registro da operadora na ans
replicate('H',30)+replicate('P',15)+replicate('X',30),;	//08 - informacao de contato com a operadora
replicate('I',40)+replicate('P',15)+replicate('X',30),;	//09 - informacao de contato com a ans
replicate('J',10),; 										//10 - data de termino da cobertura parcial temporaria
replicate('L',13),; 										//11 - padrao de acomodacao
replicate('M',17),; 										//12 - tipo de contratacao
replicate('N',19),; 										//13 - area de abrangencia geografica
replicate('O',22),; 										//14 - nome do produto
replicate('P',60),; 										//15 - nome fantasia da operadora
replicate('Q',20),; 										//16 - nome fantasia da administradora de beneficios
replicate('R',40),; 										//17 - nome da p. juridica contratante do plano coletivo ou emp.
replicate('S',10),; 										//18 - data de inicio da vigencia do plano
replicate('T',10) } } 									//19 - informacoes
*/

//verifica se tem registro a ser impresso
If len(aDados) == 0
	If !lWeb
		msgAlert("Não é possível realizar a impressão!")
	Else
		cMsg := "Não é possível realizar a impressão. Usuário Bloqueado!"
	EndIf
	lContinua := .f.
EndIf

If lContinua
	//preparando para impressao
	nLinMax	:=	2275
	nColMax	:=	3270
	
	//Estilo de fontes
	oFont02 := TFont():New("Arial"		 , 11, 11, , .F., , , , .T., .F.) // Normal
	oFont02n:= TFont():New("courier new", 10, 10, , .T., , , , .T., .F.) // Negrito
	oFont03n:= TFont():New("courier new", 10, 10, , .F., , , , .T., .F.) // Negrito
	oFont05n:= TFont():New("Arial"      , 17, 17, , .T., , , , .T., .F.) // Negrito
	
	//Define o arquivo para impressao
	If lWeb
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf
	
	nH := PLSAbreSem("PPLSIMPCAR.SMF")
	If lWeb
		oPrint := FWMSPrinter():New( cFileName,,.f.,cPathSrv,.t.,,@oPrint,,,.f.,.f.)
	Else
		oPrint := FWMSPrinter():New( cFileName,,.f.,cPathSrv,.t.,,,,,.f.,,)
	EndIf
	PLSFechaSem(nH,"PPLSIMPCAR.SMF")
	
	If lSrvUnix
		ajusPath(@oPrint)
	EndIf
	
	oPrint:lServer 	:= lWeb
	oPrint:cPathPDF	:= cPathSrv
	
	nTweb	:= 3.9
	nLweb	:= 10
	nLwebC	:= -3
	nWeb	:= 25
	nColMax := IIf(lWeb,2980,3100)
	
	oPrint:SetPortrait()//³Modo retrato
	oPrint:setPaperSize(9)// Papél A4
	
	//Device
	If lWeb
		oPrint:setDevice(IMP_PDF)
	Else
		oPrint:Setup()
		If !(oPrint:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
			Return
		Endif
	Endif
	
	//Carrega e Imprime Logotipo da Empresa
	fLogoEmp(@cFileLogo)
	
	//dados a serem impressos
	For nX := 1 To Len(aDados)
		
		nLinIni := 080
		nColIni := 080
		nColA4  := 000
		
		//Inicia uma nova pagina
		oPrint:startPage()
		
		//Box Principal                                                 
		oPrint:box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)
		
		nColA4 := -0335
		
		//titulo
		oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "Carteirinha", oFont05n,,,, 2)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60, 80)
		
		//linha abaixo do titulo
		AddTBrush(oPrint, (nLinIni + 190)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 191)/nTweb, (nColIni + nColMax)/nTweb)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
		
		//FRENTE

		if file(cImgFrente)
			//imagem de fundo da frente do cartao
			oPrint:SayBitmap((nLinIni + 110)/nTweb, (nColIni + 230)/nTweb, cImgFrente, (1200)/nTweb, (600)/nTweb)
		else
			//box marcando a frente do cartao
			oPrint:box((nLinIni + 145)/nTweb, (nColIni + 280)/nTweb, (nLinIni + 700)/nTweb, (nColIni + 1430)/nTweb)
		endIf
		
		//Tem que estar abaixo do RootPath - logomarca
		if file(cFilelogo)
			//logo
			oPrint:SayBitmap((nLinIni + 160)/nTweb, (nColIni + 300)/nTweb, cFileLogo, (155)/nTweb, (090)/nTweb)
			
			//01 - nome do beneficiario
			oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 500)/nTweb, aDados[nX,1], oFont02n)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 55, 80)
			
			//02 - numero da matricula
			oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 500)/nTweb, aDados[nX,2], oFont02n)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
			
		//caso nao tenha logo muda a posicao do nome e matricula	
		else
			//01 - nome do beneficiario
			oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,1], oFont02n)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
			
			//02 - numero da matricula
			oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,2], oFont02n)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
			
		endIf

		//03 - data de nascimento do beneficiario				
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,3], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
		
		//04 - numero do cartao naciona de saude CNS
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,4], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
	
		//05 - numero do registro do plano ou do cad. do plano na ans
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,5], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
		
		//06 - segmentacao assistencial do plano
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,6], oFont03n)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
		
		//07 - codigo do registro da operadora na ans
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,7], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
		
		//08 - informacao de contato com a operadora
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, allTrim(left(aDados[nX,8],30)) + iif(!empty(allTrim(left(aDados[nX,8],30))),', ','') , oFont03n)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
	
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, allTrim(subStr(aDados[nX,8],31,15)) + iif(!empty(allTrim(subStr(aDados[nX,8],31,15))),' - ','') + allTrim(subStr(aDados[nX,8],46,30)), oFont03n)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
	
		//09 - informacao de contato com a ans
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, allTrim(left(aDados[nX,9],40)) + iif(!empty(allTrim(left(aDados[nX,9],40))),', ',''), oFont03n)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)

		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, allTrim(subStr(aDados[nX,9],41,15)) + iif(!empty(allTrim(subStr(aDados[nX,9],41,15))),' - ','') + allTrim(subStr(aDados[nX,8],56,30)), oFont03n)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)

		
		//VERSO
		

		//indicacao para corte entre frente e versao
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 250)/nTweb, replicate('-',130), oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)

		if file(cImgVerso)
			//imagem de fundo do verso do cartao
			oPrint:SayBitmap((nLinIni + 130)/nTweb, (nColIni + 230)/nTweb, cImgVerso, (1200)/nTweb, (600)/nTweb)
			oPrint:box((nLinIni + 145)/nTweb, (nColIni + 280)/nTweb, (nLinIni + 700)/nTweb, (nColIni + 1430)/nTweb)
		else
			//box marcando o verso do cartao
			oPrint:box((nLinIni + 145)/nTweb, (nColIni + 280)/nTweb, (nLinIni + 700)/nTweb, (nColIni + 1430)/nTweb)
		endIf

		//10 - data de termino da cobertura parcial temporaria
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,10], oFont02)
		
		//11 - padrao de acomodacao
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 600)/nTweb, aDados[nX,11], oFont02)
	
		//12 - tipo de contratacao
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 1000)/nTweb, aDados[nX,12], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 165, 80)
		
		//21 - Data maxima de carencia
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 1000)/nTweb, aDados[nX,21], oFont02)
		
		
		//13 - area de abrangencia geografica
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[1,13], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

		//22 - Informações sobre o plano
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 1000)/nTweb, aDados[nX,22], oFont02)
		
		//14 - nome do produto
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,14], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

		//20 - Data de Inclusão
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 1000)/nTweb, aDados[nX,20], oFont02)
		
		//15 - nome fantasia da operadora
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,15], oFont03n)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

		//23 - Numero do Contrato
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 1000)/nTweb, aDados[nX,19], oFont02)

		//16 - nome fantasia da administradora de beneficios
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,16], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

		//17 - nome da p. juridica contratante do plano coletivo ou emp.
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,17], oFont03n)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
	
		//18 - data de inicio da vigencia do plano
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,18], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
		
		//23 - informacoes
		oPrint:Say((nLinIni + 195)/nTweb, (nColIni + 300)/nTweb, aDados[nX,23], oFont02)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
		
		//Finaliza a pagina
		oPrint:endPage()
	Next
	
	//imprime quando web e mostra o preview no remote
	If lWeb
		oPrint:Print()
	Else
		oPrint:Preview()
	EndIf
EndIf

Return( { cFileName, cMsg } )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRNCARTE
Função que retorna os dados para gerar a carteirinha.

OBSERVAÇÃO: a função PLSA261INC foi substituida, pois continha muitas
validações desnecessárias, dificultando a manutenção. 

@version P12
@since   14.06.16
/*/
//-------------------------------------------------------------------
User Function PLRNCARTE(cMatric)
LOCAL aRet := {}
LOCAL lRet := .T.
	
	//Se o beneficiário não estiver bloqueado, libera a impressão.
	BA1->(DbSetOrder(2))	
	If BA1->(MsSeek(xFilial("BA1") + cMatric))
		If !EMPTY(BA1->BA1_DATBLO)
			If BA1->BA1_DATBLO <= dDatabase
				lRet := .F.
				AADD(aRet,{})			
			EndIf
		EndIf
		
		If lRet
				
			BTS->(DbSetOrder(1))
			BTS->(MsSeek(xFilial("BTS") + BA1->BA1_MATVID))				
			
			AADD(aRet, {BA1->BA1_NOMUSR,; //01 - nome do beneficiario
				      	cMatric,; //02 - numero da matricula
				      	DTOC(BA1->BA1_DATNAS),; //03 - data de ascimento do beneficiario
				      	BTS->BTS_NRCRNA,; //04 - numero do cartao naciona de saude CNS
				      	"",; //05 - numero do registro do plano ou do cad. do plano na ans
				      	"",; //06 - segmentacao assistencial do plano
				      	"",; //07 - codigo do registro da operadora na ans
				      	"",; //08 - informacao de contato com a operadora
				      	"",; //09 - informacao de contato com a ans
						"",; //10 - data de termino da cobertura parcial temporaria  
						"",; //11 - padrao de acomodacao
						"",; //12 - tipo de contratacao
						"",; //13 - area de abrangencia geografica
						"",; //14 - nome do produto
						"",; //15 - nome fantasia da operadora
						"",; //16 - nome fantasia da administradora de beneficios
						"",; //17 - nome da p. juridica contratante do plano coletivo ou emp.
						"",; //18 - data de inicio da vigencia do plano
						"",; //19 - Numero do contrato/apólice
						"",; //20 - Data de contratação do plano de saúde
						"",; //21 - Prazo máximo previsto no contrato para carência
						"",; //22 - Informação sobre a regulamentação do plano
						""}) //23 - Informação
		EndIf
	EndIf	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AjusPath

Ajuste provisorio do path do objeto 

@Observ  Solucao de contorno ate sair o path do frame
@version P12
@since   25/09/2020
/*/
//-------------------------------------------------------------------
Static Function AjusPath(oPrint)

	oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"\","/",1)
	oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"\","/",1)
	oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"//","/",1)
	oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"//","/",1)

Return