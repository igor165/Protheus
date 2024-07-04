#Include "PLSR952.ch"
#Include "Protheus.ch"
#INCLUDE "REPORT.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR955   � Autor � TOTVS                � Data � 04/08/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o de RDA que foram bloqueados por Suspens�o.         ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR952 	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function PLSR952()
Local oReport

If IsBlind()
    //Gera��o automatica do relat�rio via Schedule
    PL952Email() 
Else
	//Gera��o manual via remote
	Pergunte("PLR952",.F.) 
	oReport := ReportDef()
	oReport:PrintDialog()
Endif

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � TOTVS            � Data � 04/08/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR952                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local oSection0
Local cTitulo := STR0001//"Rela��o de RDA que foram bloqueados por Suspens�o"

DEFINE REPORT oReport NAME "PLSR952 " TITLE (cTitulo) PARAMETER "PLR952" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (STR0001)
oReport:SetLandscape()

DEFINE SECTION oSection0  OF oReport TABLES "TRB" TITLE OemToAnsi(STR0002)//"RDA bloqueadas por suspens�o") 
DEFINE CELL NAME "cUser"   OF oSection0 ALIAS "TRB" TITLE OemToAnsi(STR0013) SIZE 30//"Usu�rio"

DEFINE SECTION oSection1   OF oReport TABLES "TRB" TITLE OemToAnsi(STR0002)//"RDA bloqueadas por suspens�o")
DEFINE CELL NAME "cRDA"    OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0003) SIZE 6//"RDA"
DEFINE CELL NAME "cMotBlq" OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0004) SIZE 6 //"Motivo Bloqueio"
DEFINE CELL NAME "cDesBlq" OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0005) SIZE 30//"Bloqueio"
DEFINE CELL NAME "cDtSol"  OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0006) SIZE 10//"Dt.Solicita��o "
DEFINE CELL NAME "cDtBlq"  OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0007) SIZE 10//"Dt.Bloqueio"  
DEFINE CELL NAME "cData"   OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0008) SIZE 10//"Dt.Limite concedido "

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � TOTVS            � Data � 04/08/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)       	                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR952                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport)
Local oSection0 := oReport:Section(1)
Local oSection1 := oReport:Section(2)
Local aDados  := {}
Local nI      := 0
 
	aDados:= PL952Filtro(.F.)

	For nI:= 1 to len(aDados)		    
		If nI == 1 
			oReport:SkipLine(1)			
			oSection0:Init()
			oSection1:Init()
			oSection0:Cell("cUser"):SetValue(aDados[nI][7])//BC4_USUOPE
			oSection0:PrintLine()
		ElseIf nI > 1	.AND. (aDados[nI][7] <> aDados[nI-1][7])
			oSection0:Finish()
			oSection1:Finish()
			oReport:SkipLine(1)				
			oSection0:Init()
			oSection1:Init()				
			oSection0:Cell("cUser"):SetValue(aDados[nI][7])//BC4_USUOPE
			oSection0:PrintLine()
		EndIf
					
		oSection1:Cell("cRDA"):SetValue(aDados[nI][1])//B9S_CODREG
		oSection1:Cell("cMotBlq"):SetValue(aDados[nI][2])//BIB_DESCRI
		oSection1:Cell("cDesBlq"):SetValue(aDados[nI][3])//BIB_ESPMUN
		oSection1:Cell("cDtSol"):SetValue(aDados[nI][4])//BID_DESCRI
		oSection1:Cell("cDtBlq"):SetValue(aDados[nI][6])//BIB_ESPMUN
		oSection1:Cell("cData"):SetValue(aDados[nI][5])//BID_DESCRI
		oSection1:PrintLine()			
	Next

   If len(aDados) >  1
		oSection0:Finish()
		oSection1:Finish()
	Endif	
	
Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL952Filtro   � Autor � TOTVS            � Data � 04/08/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Filtra os dados para gerar o relatorio ou o arquivo        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PL952Filtro                	                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR952                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PL952Filtro(lShedule)
Local cQuery    := ""
Local cAliasTrb := ""
Local aDados    := {}
Local cInt      := PlsIntPad()
Local cDtAtual  := date()
Local nI        := 0
Local aDiasMeses:= {}
Local cData     := ""
Local nStart    := 0
Local nMesAtual := 0
Local nTotalDias:= 0
Local aUsers := PLRETUSERS(mv_par01, mv_par02)
Local nTam := len(aUsers)

Default lShedule := .T.

cQuery := " SELECT  BC4.BC4_CODCRE,BC4.BC4_MOTBLO,BC4.BC4_DTSOL,BC4.BC4_DTBLQ,BC4.BC4_DATA, BAP.BAP_DESCRI, BC4.BC4_USUOPE "
cQuery += " FROM " + RetSqlName('BC4') +" BC4 ,"+RetSqlName('BAP') +" BAP "			
cQuery += " WHERE "			
cQuery += " BC4.BC4_FILIAL = '" + xFilial("BC4") + "' and"	
cQuery += " BC4.BC4_CODCRE >= '"+ mv_par03+"' And BC4.BC4_CODCRE <= '"+ mv_par04 +"' and "

if nTam > 0 
	cQuery += " BC4.BC4_USUOPE IN("
	for nI := 1 to nTam
		If nI > 1
			cQuery += " , "
		EndIf
		cQuery += "'" + aUsers[nI] + "'"
	next nI
	cQuery += " ) and "
endiF

If !lShedule
	cQuery += " BC4.BC4_DTBLQ  >= '"+ dtos(mv_par05)+"' And BC4.BC4_DTBLQ <= '"+ dtos(mv_par06) +"' and "
Else
	 Do Case
		Case mv_par09 == 1//Dias
		  cData := date() - val(mv_par08) 
		Case mv_par09 == 2//Semana
		  cData := date() - (val(mv_par08) * 7 )
		Case mv_par09 == 3//Meses
		   aAdd(aDiasMeses,{31,28,31,30,31,30,31,31,30,31,30,31})
		   //Identificar quantos dias devera retroceder
		   If ( val(mv_par08) <=  12 )
		       nMesAtual := val(SubStr(DtoS(date()),5,2))
		   		nStart := nMesAtual - val(mv_par08)  
		   		For nI:=nStart to nMesAtual//Qtde informada para retroceder
		      		nTotalDias += aDiasMeses[1][nI]    
		   		Next
		  		cData := date() - nTotalDias
		  	Endif			
		Case mv_par09 == 4//Ano
			cData := date() - (val(mv_par08) * 365 )
	 EndCase
	  
	 cQuery += " BC4.BC4_DTBLQ  >= '"+ dtos(cData)+"' And BC4.BC4_DTBLQ <= '"+ dtos(date()) +"' and "
  
Endif	

cQuery += " BC4.BC4_TIPO = '0' and BC4.BC4_MOTIVO = '1' " 
cQuery += " and BAP_FILIAL = BC4_FILIAL "
cQuery += " and BC4_MOTBLO = BAP_CODBLO "
cQuery += " and BC4.D_E_L_E_T_ = ' ' "
cQuery += " and BAP.D_E_L_E_T_ = ' ' "  
cQuery += " Order by BC4_USUOPE, BC4_DTBLQ "

cQuery := ChangeQuery(cQuery)

//��������������������������������������������������������������Ŀ
//� Pega uma sequencia de alias para o temporario.               �
//����������������������������������������������������������������
cAliasTrb := GetNextAlias()

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
dbSelectArea(cAliasTrb)
dbGoTop()
 
While !(cAliasTrb)->(Eof())
	 AAdd( aDados, { (cAliasTrb)->BC4_CODCRE, (cAliasTrb)->BC4_MOTBLO, (cAliasTrb)->BAP_DESCRI, dtoc(stod((cAliasTrb)->BC4_DTSOL)), dtoc(stod((cAliasTrb)-> BC4_DTBLQ)),dtoc(stod((cAliasTrb)->BC4_DATA)), (cAliasTrb)->BC4_USUOPE })  
 	(cAliasTrb)->(dbSkip()) 
 Enddo

(cAliasTrb)->(dbCloseArea())
	
Return aDados


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Scheddef      � Autor � TOTVS            � Data � 04/08/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Recebe os parametros do schedule                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Scheddef                    	                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR952                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Scheddef()
Local aParam
Local aOrd     := {}
aParam := { "R","PLR952","BC4",aOrd,"Teste SchedDef"} 
Return aParam

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL952Email    � Autor � TOTVS            � Data � 05/08/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Recebe os parametros do schedule                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PL952Email                    	                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR952                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PL952Email() 
Local aDados    := {}
Local nI        := 0
Local cMontaTxt := "" 
Local cDirGrava := "" //diretorio onde ser� armazenado a geracao do relatorio
Local cDestino  := "" //analista que recebera o email  
Local aAnexo    := {}
Local nMesAtual := val(SubStr(DtoS(date()),5,2))
 
aDados:= PL952Filtro(.T.)

cDirGrava  := GetNewPar("MV_PLDIRDA","C:\")
cDestino   := alltrim(MV_PAR07)

If !Empty(aDados)
	//Monta o cabecalho do excel
	cMontaTxt += STR0003 + ";"//"RDA"
	cMontaTxt += STR0004 + ";"//"Motivo Bloqueio"
	cMontaTxt += STR0005 + ";"//"Bloqueio"
	cMontaTxt += STR0006 + ";"//"Dt.Solicita��o "
	cMontaTxt += STR0007 + ";"//"Dt.Bloqueio"
	cMontaTxt += STR0008 + ";"//"Dt.Limite concedido "
	cMontaTxt += CRLF 
	
	//carrega o excel
	For nI:= 1 to len(aDados)
	   cMontaTxt += aDados[nI][1] + ";"
	   cMontaTxt += aDados[nI][2] + ";"
	   cMontaTxt += aDados[nI][3] + ";"
	   cMontaTxt += aDados[nI][4] + ";"
	   cMontaTxt += aDados[nI][5] + ";"
	   cMontaTxt += aDados[nI][6] + ";"
	   cMontaTxt += CRLF 
	Next
	
	cDirAnexo := alltrim(cDirGrava)+STR0009+SubStr(DtoS(date()),7,2)+"_"+SubStr(DtoS(date()),5,2)+"_"+SubStr(DtoS(date()),1,4)+".csv" //"\RDA_Suspensos_"
	
	If File(cDirGrava)
		//adicionando o arquivo como anexo
		aadd(aAnexo,cDirAnexo)
			
		//criar arquivo texto vazio a partir do root path no servidor
		nHandle := FCREATE(cDirAnexo)
			
		FWrite(nHandle,cMontaTxt)
			
		//encerra grava��o no arquivo
		FClose(nHandle)
			
		//envia o arquivo via email 
		PlsWFProc("000001", STR0010 , STR0010+SubStr(DtoS(date()),7,2)+"_"+SubStr(DtoS(date()),5,2)+"_"+SubStr(DtoS(date()),1,4), "PLSR952",cDestino, "" ,"" ,"\workflow\WfAutomatico.htm" ,,aAnexo,.F.)//"RDA Suspensos"
	Else
		Plslogfil(STR0011,cDirAnexo)//"Arquivo nao encontrado"		
	EndIf
Endif

Return (Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL952Val    � Autor � TOTVS            � Data � 06/08/15   ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida��o de SX1                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PL952Val                    	                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR952                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL952Val() 
Local lRet := .T.

   IF(mv_par09 == 3 .And. mv_par08 > "12")
   		MSGAlert(STR0012)//"Quantidade informada para Meses � inv�lida!"
   		lRet := .F.
   		mv_par08:= "  "
   Endif               

Return lRet 

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Objeto     � PLRETUSERS � Autor � Karine Riquena Limp  � Data � 03/05/2016 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o  �Retorna um range de usu�rios passados por parametro            ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
function PLRETUSERS(cCodUsrDe, cCodUsrAte)
local aRet := AllUsers()                            
local aUsers := {}
local nI := 1
local nPos1:= 1
local nPos2:= len(aRet)
local nAux1 := 0
local nAux2 := 0
default cCodUsrDe := ""
default cCodUsrAte := ""

if(!empty(cCodUsrDe))
	// preciso encontrar se o usu�rio do parametro informado no "usuario De" existe para fazer o nPos, 
	// sen�o n�o vai vir no array
	while(!UsrExist ( cCodUsrDe ))
		cCodUsrDe := soma1(cCodUsrDe)
	endDo

	//encontro o ponto de partida do array no Usuario De
	nAux1 := aScan(aRet,{|x| x[1][1] == cCodUsrDe})
	if(nAux1 > 0)
		nPos1 := nAux1
	endIf
endIf

if(!empty(cCodUsrAte) .and. cCodUsrAte <> "ZZZZZZ")
	// preciso encontrar se o usu�rio do parametro informado no "usuario ate" existe para fazer o nPos, 
	// sen�o n�o vai vir no array
	while(!UsrExist ( cCodUsrAte ))
		cCodUsrAte := plssub1(cCodUsrAte)
	endDo

	//encontro o ponto fina� do array no Usuario Ate
	nAux2 := aScan(aRet,{|x| x[1][1] == cCodUsrAte})
	if(nAux2 > 0)
		nPos2 := nAux2
	endIf
endIf

for nI := nPos1 to nPos2	
	Aadd(aUsers, aRet[nI][1][2])
next

return aUsers
