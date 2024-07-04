#Include "FINR400.CH"
#Include "PROTHEUS.CH"  

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes


/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR400  � Autor � Daniel Tadashi Batori    � Data � 12.07.78 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao dos Cheque Emitidos                                   ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR400(void)                                                 ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                      ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/ 
User Function VAFINR01()
Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Return VAFINR01R3() // Executa vers�o anterior do fonte
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportDef� Autor � Daniel Batori         � Data � 12.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do layout do Relatorio									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef(void)                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport  
Local oSection1
Local oSection11
Local aTam1, aTam2, aTam3, aTam4, nTamLiq

oReport := TReport():New("FINR400",STR0003,"FIN400",;
{|oReport| ReportPrint(oReport)},STR0001+STR0002)

Pergunte("FIN400", .F.)

aTam1	:= TamSX3("A6_COD")
aTam2	:= TamSX3("A6_NREDUZ")
aTam3	:= TamSX3("A6_AGENCIA")
aTam4	:= TamSX3("A6_NUMCON")
nTam	:= LEN(STR0011) + aTam1[1] + aTam2[1] + LEN(STR0012) + aTam3[1] + aTam4[1] + 15

oSection1 := TRSection():New(oReport,STR0032,{"SEF"},{STR0008,STR0009,"Cheque+Banco+Agencia+Conta","Cheque Liber+DT Emis.Cheq+Cheque+Banco+Agencia+Conta",;
"CH Liber+ DT Emis+ N Cheque+ Banco","Carteira+Conta+Cheque+Prefixo+Titulo","Carteira+Prefixo+Num.Titulo","Carteira+DT Emis.Cheq+Agencia+Conta","Banco + Agencia + Conta + Num. Titulo","Banco + Agencia + Conta + Talonario",;
"Fil. cheque+Banco+Agencia+Conta+Cheque", STR0027})
TRCell():New(oSection1,"QUEBRA" ,,,,nTam,.F.,)  //definido por SetBlock

oSection1:SetHeaderSection(.F.)

oSection11 := TRSection():New(oSection1,STR0031,{"SEF"},)
TRCell():New(oSection11,"EF_FILIAL" ,"SEF",'Filial',,,.F.,)  //"Numero"
TRCell():New(oSection11,"EF_NUM" ,"SEF",STR0024,,,.F.,)  //"Numero"
TRCell():New(oSection11,"EF_VALOR","SEF",STR0025,,,.F.,)  //"Valor"
TRCell():New(oSection11,"EF_DATA" ,"SEF",STR0026,,,.F.,)  //"Emissao"
TRCell():New(oSection11,"EF_VENCTO" ,"SEF",STR0027,,,.F.,)  //"Vencto."
TRCell():New(oSection11,"EF_EMITENT" ,"SEF",STR0028,,40,.F.,)  //"Cliente Beneficiario/Emitente"
TRCell():New(oSection11,"EF_HIST" ,"SEF",STR0029,,40,.F.,)  //"Historico"
TRCell():New(oSection11,"EF_LIBER","SEF",STR0030,,,.F.,)  //"St.Ch"
	
Return oReport                                                                              

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Daniel Batori          � Data �10.07.06	���
��������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os  ���
���          �relatorios que poderao ser agendados pelo usuario.           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                            ���
��������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �               �                                             ���
���������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local oSection11 := oReport:Section(1):Section(1)
Local cAliasQry1 := GetNextAlias()
Local cQuery := ""
Local nOrder := oSection1:GetOrder()
Local cOrder := ""
Local cCarteira := Iif (Mv_Par13 = 1,"R","P")
Local nDecs := MsDecimais(mv_par11)
Local cAnt
Local nValor	:= 0
Local nTotVal	:= 0
Local nCheque	:= 0
Local lLibCheq := GetMV("MV_LIBCHEQ") =="N"
Local cCheque := ""
Local aCheques := {}

#IFDEF TOP

	oSection1:BeginQuery()

		If cPaisLoc != "BRA"
			If !(AllTrim(Upper(TCGetDB())) $ "ORACLE_INFORMIX")
				cQuery += " AND SUBSTRING(EF_NUM,1,1) <> '*' "
			Else
				cQuery += " AND SUBSTR(EF_NUM,1,1) <> '*' "
			EndIf
		EndIf
  		
		If Mv_Par13 == 1
			cQuery += " AND EF_CART = 'R' "
		ElseIf Mv_Par13 == 2
			cQuery += " AND EF_CART <> 'R' "
		EndIf

		If lLibCheq .And. Mv_Par13 <> 1
			IF Mv_Par14 == 1
				cQuery += " AND EF_LIBER = 'S' "
			ElseIf Mv_Par14 == 2
				cQuery += " AND EF_LIBER IN ('N',' ') "
			EndIf
		EndIf
		
		//Se Op��o for � compensar e liberados
		If mv_par15 == 1 
			cQuery += " AND EF_VENCTO <= '"+DTOS(dDataBase)+"' " 
		//Se op��o for � compensar e nao liberados
	/*	ElseIf mv_par15 == 1 .And. Mv_Par14 == 2
			cQuery += " AND EF_VENCTO = ' ' OR EF_VENCTO <= '"+DTOS(dDataBase)+"' AND EF_LIBER IN ('N',' ') " 
	*/	// Se op��o for Pr� datado
		ElseIf mv_par15 == 2
			cQuery += " AND EF_VENCTO > '"+DTOS(dDataBase)+"' "
		Endif
		
		cOrder := SqlOrder(SEF->(IndexKey( nOrder )))
		cQuery += " ORDER BY "+ cOrder 

		cQuery := "%" + cQuery + "%"
        
		BeginSql Alias cAliasQry1	
			SELECT SEF.*
			FROM %table:SEF% SEF
//			WHERE EF_FILIAL = %xFilial:SEF% AND 
			WHERE 	EF_BANCO  >= %exp:mv_par01% AND 
					EF_BANCO  <= %exp:mv_par02% AND
					EF_AGENCIA >= %exp:mv_par03% AND 
					EF_AGENCIA <= %exp:mv_par04% AND
					EF_CONTA   >= %exp:mv_par05% AND
					EF_CONTA   <= %exp:mv_par06% AND
					EF_NUM     >= %exp:mv_par07% AND
					EF_NUM     <= %exp:mv_par08% AND
					EF_DATA    >= %exp:mv_par09% AND
					EF_DATA    <= %exp:mv_par10% AND
					EF_IMPRESS <> 'A' AND
					EF_IMPRESS <> 'C' AND                      
					EF_NUM <> ' ' AND 
					SEF.%NotDel%
					%exp:cQuery%
		EndSql
		Memowrite("C:\TOTVS\VAFINR01.txt",cQuery)
	oSection1:EndQuery()	

	oSection11:SetParentQuery()	
#ELSE
	cAliasQry1 := "SEF"
   DbSelectArea(cAliasQry1)
   
//	cQuery := " EF_FILIAL  == '"+ xFilial("SEF") + "' .And. "
	cQuery := " EF_BANCO  >= '" + mv_par01 + "' .And. "
	cQuery += " EF_BANCO  <= '" + mv_par02 + "' .And. "
	cQuery += " EF_AGENCIA>= '" + mv_par03 + "' .And. "
	cQuery += " EF_AGENCIA<= '" + mv_par04 + "' .And. "
	cQuery += " EF_CONTA  >= '" + mv_par05 + "' .And. "
	cQuery += " EF_CONTA  <= '" + mv_par06 + "' .And. "
	cQuery += " EF_NUM    >= '" + mv_par07 + "' .And. "
	cQuery += " EF_NUM    <= '" + mv_par08 + "' .And. "
	cQuery += " DTOS(EF_DATA) >= '"+DTOS(MV_PAR09) + "' .And. "
	cQuery += " DTOS(EF_DATA) <= '"+DTOS(MV_PAR10) + "' .And. "
	cQuery += " !(EF_IMPRESS $ 'AC') "
	
	
	If cPaisLoc != "BRA"
		cQuery += " .And. SUBSTR(EF_NUM,1,1) != '*' "
	EndIf

	If Mv_Par13 == 1
		cQuery += " .And. EF_CART == 'R' "
	ElseIf Mv_Par13 == 2
		cQuery += " .And. EF_CART != 'R' "
	EndIf

	If lLibCheq .And. Mv_Par13 <> 1
		IF Mv_Par14 == 1
			cQuery += " .And. EF_LIBER == 'S' "
		ElseIf Mv_Par14 == 2
			cQuery += " .And. EF_LIBER $ 'N ' "
		EndIf
	EndIf

	

	oSection1:SetFilter( cQuery,(cAliasQry1)->(IndexKey(nOrder)) )	
	Memowrite("C:\TOTVS\VAFINR010.txt",cQuery)
#ENDIF

oSection11:SetParentFilter({|cParam| (cAliasQry1)->(EF_BANCO+EF_AGENCIA+EF_CONTA) == cParam},{|| (cAliasQry1)->(EF_BANCO+EF_AGENCIA+EF_CONTA) })
		
TRPosition():New(oSection1, "SA6", 1, {|| xFilial("SA6")+(cAliasQry1)->(EF_BANCO+EF_AGENCIA+EF_CONTA)}, .T. )

oSection1:SetLineCondition( { ||  ((cAliasQry1)->EF_CART <> "P") .Or. (mv_par12 <> 2) .Or. (Empty(SA6->A6_MOEDA)) .Or. (SA6->A6_MOEDA==mv_par11) } )

oSection1:Cell("QUEBRA"):SetBlock( { || If ((cAliasQry1)->EF_CART <> "R", ;
														STR0011 + SA6->A6_COD + " - " + AllTrim(SA6->A6_NOME) + STR0012 + SA6->A6_AGENCIA + STR0033 + SA6->A6_NUMCON, ;
														STR0011 + (cAliasQry1)->EF_BANCO + " - "+ AllTrim(SA6->A6_NOME) + STR0012 + (cAliasQry1)->EF_AGENCIA + STR0033 + (cAliasQry1)->EF_CONTA) })
oSection11:Cell("EF_NUM"):SetBlock( { || (cAliasQry1)->EF_NUM })
oSection11:Cell("EF_VALOR"):SetBlock( { || nValor })
oSection11:Cell("EF_DATA"):SetBlock( { || (cAliasQry1)->EF_DATA })
oSection11:Cell("EF_VENCTO"):SetBlock( { || If(cPaisLoc <> "BRA" .Or. (cAliasQry1)->EF_CART=="R", (cAliasQry1)->EF_VENCTO, (cAliasQry1)->EF_VENCTO) })
oSection11:Cell("EF_EMITENT"):SetBlock( { || SubStr( If ((cAliasQry1)->EF_CART=="R", ;
																If(cPaisLoc<>"BRA",(cAliasQry1)->EF_EMITENT, (cAliasQry1)->EF_CLIENTE+' '+(cAliasQry1)->EF_EMITENT), ;
																(cAliasQry1)->EF_BENEF ),1,40) })
oSection11:Cell("EF_HIST"):SetBlock( { || SubStr( (cAliasQry1)->EF_HIST,1,50) })
oSection11:Cell("EF_LIBER"):SetBlock( { || If((cAliasQry1)->EF_CART <> 'R' , If((cAliasQry1)->EF_LIBER $ 'N ', "B","L") , nil) })

TRFunction():New(oSection11:Cell("EF_VALOR"),"T_VALOR" ,"SUM",,,,,.T.,.F.)
oSection11:SetTotalInLine(.F.)

//oSection1:Print()

(cAliasQry1)->(dbGoTop())

oSection1:Init()   

aCheques := {}

While (cAliasQry1)->(!Eof())
	oSection1:PrintLine()
	cAnt := (cAliasQry1)->(EF_BANCO+EF_AGENCIA+EF_CONTA)
	oSection11:Init()
	While (cAliasQry1)->(!Eof()) .And. (cAliasQry1)->(EF_BANCO+EF_AGENCIA+EF_CONTA) == cAnt		
		
		cCheque := (cAliasQry1)->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)
		If ASCAN(ACHEQUES,{ |X|  X[1] == cCheque}) <= 0		
			nValor	:= If(cPaisLoc<>"BRA", xMoeda((cAliasQry1)->EF_VALOR, SA6->A6_MOEDA, mv_par11,(cAliasQry1)->EF_DATA,nDecs+1), (cAliasQry1)->EF_VALOR)
			nTotVal	+= nValor
			nCheque++
			aAdd(aCheques,{cCheque})
			oSection11:PrintLine()
		Endif		
		(cAliasQry1)->(dbSkip())
		
	Enddo
	oSection11:Finish()
	oReport:SkipLine()
	oReport:SkipLine()
Enddo

oSection1:Finish()   

oReport:PrintText(STR0014 + Transform(nTotVal, PesqPict('SEF','EF_VALOR') ))
oReport:PrintText(STR0015  + Transform(nCheque, "@E 9,999,999,999,999"))

If mv_par13 <> 1 
	oReport:SkipLine()
	oReport:PrintText(STR0020) //"Total Cheques-> " //"Legenda: "
	oReport:PrintText(STR0021) //"Total Cheques-> " //"St.Ch - Status do Cheque"
	oReport:PrintText(STR0022) //"Total Cheques-> " //"B - Bloqueado "
	oReport:PrintText(STR0023) //"Total Cheques-> " //"L - Liberado "
EndIf

Return
      

/*
---------------------------------------------------------- RELEASE 3 ---------------------------------------------
*/



/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR400R3� Autor � Paulo Boschetti          � Data � 15.06.92 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao dos Cheque Emitidos                                   ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR400R3(void)                                               ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                      ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/ 
Static Function VAFINR01R3()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cDesc1    := STR0001  //"Este relatorio ira imprimir a rela��o de cheques emitidos,"
Local cDesc2    := STR0002  //"em ordem Numerica/Emiss�o"
Local cDesc3    := ""
Local wnrel
Local cString   := "SEF"
Local Tamanho   := "M"

Private titulo  := STR0003  //"Rela��o de Cheques emitidos."
Private cabec1
Private cabec2
Private aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nomeprog:= "VAFINR01"
Private aLinha  := { },nLastKey := 0
Private cPerg   := "FIN400"

//��������������������������������������������������������������Ŀ
//� Definicao dos Cabecalhos                                     �
//����������������������������������������������������������������
titulo := OemToAnsi(STR0006)  //"Relacao de Cheques" 

If cPaisLoc == "BRA"
	cabec1 := OemToAnsi(STR0007)  //"Numero                   Valor Emissao  Beneficiario                              Historico"
Else
	cabec1 := OemToAnsi(STR0016)  //"Numero                   Valor Emissao  Vencto.  Beneficiario                              Historico"
EndIf

cabec2 := " " 

pergunte("FIN400",.F.)

//�����������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                      �
//� mv_par01            // Do Banco                           �
//� mv_par02            // Ate o Banco                        �
//� mv_par03            // Da Agencia                         �
//� mv_par04            // Ate a Agencia                      �
//� mv_par05            // Da Conta                           �
//� mv_par06            // Ate a Conta                        �
//� mv_par07            // Do Cheque                          �
//� mv_par08            // Ate o Cheque                       �
//� mv_par09            // Da Emissao                         �
//� mv_par10            // Ate a Emissao                      �
//� mv_par11            // Qual moeda                         �
//� mv_par12            // Outras moedas                      �
//� mv_par13            // Carteira                           � 
//� mv_par14            // Liberados/Nao Lib./Ambos  
//� mv_par15			// Predatado / � compensar         � 
//�������������������������������������������������������������
//�����������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                     �
//�������������������������������������������������������������
wnrel:= "VAFINR01"            //Nome Default do relatorio em Disco
aOrd := {OemToAnsi(STR0008),OemToAnsi(STR0009), OemToAnsi(STR0027) }  //"Por Cheque"###"Por Emissao"###"Por Vencto"
wnrel:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey = 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
EndIf

RptStatus({|lEnd| Fa400Imp(@lEnd,wnRel,cString)},titulo)
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FA400Imp � Autor � Paulo Boschetti       � Data � 15.06.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao dos Cheque Emitidos                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FA400Imp(lEnd,wnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A�ao do Codelock                             ���
���          � wnRel       - T�tulo do relat�rio                          ���
���Parametros� cString     - Mensagem			                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FA400Imp(lEnd,wnRel,cString)

Local CbCont,CbTxt
Local tamanho   := "M"
Local limite    := 132
Local nOrdem
Local nTotch:=0,nTotVal:=0,nTotchg:=0,nTotValg:=0,nFirst:=0
Local lContinua := .T.,nTipo
Local cCond1,cCond2,cCarAnt, nValorEF
Local cFilialA6 :=  xFilial("SA6")
Local cCarteira := Iif (Mv_Par13 = 1,"R","P")  
#IFDEF TOP
	Local aStru     := SEF->(dbStruct()), ni
#ENDIF	
Local cFilterUser:=aReturn[7]
Local lLibCheq := GetMV("MV_LIBCHEQ") =="N"

Local cCheque := ""
Local aCheques := {}

Private nDecs   := MsDecimais(mv_par11)

nTipo:=Iif(aReturn[4]==1,15,18)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1
nOrdem   := aReturn[8]

//������������������������������������������������Ŀ
//� Imprime o Cabecalho em funcao da Carteira      �
//��������������������������������������������������
If mv_par13 == 1     //Receber          
	cabec1 := OemToAnsi(STR0017) //"Numero                   Valor  Emissao   Vencto.  Cliente Emitente                             Historico"
ElseIf mv_par13 == 2 //Pagar       
	cabec1 := OemToAnsi(STR0007) //"Numero                   Valor  Emissao     Beneficiario                              Historico"    
ElseIf mv_par13 == 3 //Ambos
	cabec1 := IIf (cPaisLoc <> "BRA", OemToAnsi(STR0019), OemToAnsi(STR0018)) //"Numero                   Valor  Emissao   Vencto.  Cliente Beneficiario/Emitente                Historico                      St.Ch"
EndIf    
                                     
SA6->(DbSetorder(1)) // Para pegar moeda do banco
dbSelectArea("SEF")

SetRegua(RecCount())
#IFDEF TOP
	If TcSrvType() != "AS/400"
	
		cOrder := SqlOrder(SEF->(IndexKey(nOrdem)))
		cQuery := "SELECT * "
		cQuery += "  FROM "+	RetSqlName("SEF")
//		cQuery += " WHERE EF_FILIAL = '" + xFilial("SEF") + "' AND "
//	  	cQuery += "EF_BANCO   >= '" + mv_par01 + "' AND EF_BANCO   <= '"  + mv_par02 + "' AND " 
		cQuery += " WHERE EF_BANCO   >= '" + mv_par01 + "' AND EF_BANCO   <= '"  + mv_par02 + "' AND " 
		cQuery += "EF_AGENCIA >= '" + mv_par03 + "' AND EF_AGENCIA <= '"  + mv_par04 + "' AND " 
		cQuery += "EF_CONTA   >= '" + mv_par05 + "' AND EF_CONTA   <= '"  + mv_par06 + "' AND " 
		cQuery += "EF_NUM     >= '" + mv_par07 + "' AND EF_NUM     <= '"  + mv_par08 + "' AND "
		cQuery += "EF_DATA    >= '" + Dtos(mv_par09) + "' AND EF_DATA    <= '"  + Dtos(mv_par10) + "' AND "
        cQuery += "EF_IMPRESS <> 'A' AND "
        cQuery += "EF_IMPRESS <> 'C' AND "
		
		If cPaisLoc != "BRA"
		    If !(AllTrim(Upper(TCGetDB())) $ "ORACLE_INFORMIX")
			   cQuery += " SUBSTRING(EF_NUM,1,1) <> '*' AND "
		    Else
			   cQuery += " SUBSTR(EF_NUM,1,1) <> '*' AND "
		    EndIf		
		EndIf
  		
		If Mv_Par13 == 1
			cQuery += "EF_CART = 'R' AND "
		ElseIf Mv_Par13 == 2
			cQuery += "EF_CART <> 'R' AND "
		EndIf
		
		If lLibCheq .And. Mv_Par13 <> 1
			IF Mv_Par14 == 1
				cQuery += "EF_LIBER = 'S' AND "
			ElseIf Mv_Par14 == 2
				cQuery += "EF_LIBER IN ('N',' ') AND "
			EndIf
		EndIf
		
		//Se Op��o for � compensar 
		If mv_par15 == 1
			cQuery += " AND EF_DATA <= '"+DTOS(dDataBase)+ "' 
		// Se op��o for Pr� datado
		ElseIf mv_par15 == 2
			cQuery += " AND EF_DATA > '"+DTOS(dDataBase)+ "' 
		Endif		
		cQuery += "D_E_L_E_T_ <> '*' "   

		cQuery += " ORDER BY "+ cOrder 
		cQuery := ChangeQuery(cQuery)
		Memowrite("C:\TOTVS\VAFINR01.txt",cQuery)								
		dbSelectArea("SEF")
		dbCloseArea()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEF', .F., .T.)
			
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SEF', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			EndIf
		Next 
		   
		If (SEF->(EOF()))
			dbSelectArea("SEF")
			dbCloseArea()
			ChkFile("SEF")
			dbSelectArea("SEF")
			dbSetOrder(1)
			Return
	   EndIf
	Else
	
#ENDIF	

		If nOrdem == 1
			dbSetOrder(1)
//			dbSeek(cFilial+mv_par01+mv_par03+mv_par05+mv_par07,.T.)
			dbSeek(xFilial('SEF')+mv_par01+mv_par03+mv_par05+mv_par07,.T.)
		Elseif nOrdem == 2
			dbSetOrder(2)
//			dbSeek(cFilial+mv_par1+mv_par03+mv_par05+Dtos(mv_par09),.T.)
			dbSeek(xFilial('SEF')+mv_par01+mv_par03+mv_par05+Dtos(mv_par09),.T.)
		ElseIf nOrdem == 3
		   dbSetOrder(12)
//		   dbSeek(cFilial+mv_par01+mv_par03+mv_par05+Dtos(mv_par09),.T.)
		   dbSeek(xFilial('SEF')+mv_par01+mv_par03+mv_par05+DtoS(SEF->EF_VENCTO),.T.)
		
		EndIf

#IFDEF TOP 
	Endif
#ENDIF
   
If nOrdem == 1
	cCond1 := "EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM <= mv_par02+mv_par04+mv_par06+mv_par08"
	cCond2 := "EF_BANCO+EF_AGENCIA+EF_CONTA" 
Elseif nOrdem == 2
	cCond1 := "EF_BANCO+EF_AGENCIA+EF_CONTA+DTOS(EF_DATA) <= mv_par02+mv_par04+mv_par06+DTOS(mv_par10)"
	cCond2 := "EF_BANCO+EF_AGENCIA+EF_CONTA"
Elseif nOrdem == 3
    cCond1 := "EF_BANCO+EF_AGENCIA+EF_CONTA+DTOS(EF_VENCTO) <= mv_par02+mv_par04+mv_par06+DTOS(SEF->EF_VENCTO)"
    oCond2 := "EF_BANCO+EF_AGENCIA+EF_CONTA0"
EndIf

While &cCond1 .And. !Eof() .And. lContinua //.and. EF_FILIAL == cFilial

	If lEnd
		@Prow()+1,001 Psay OemToAnsi(STR0010)  //"Cancelado pelo Operador"
		Exit
	EndIf

	IncRegua()

	If EF_IMPRESS $ "AC"		//Integrante de outro Cheque ou cancelado
		dbSkip()
		Loop
	Endif

	If Empty( EF_NUM ) .Or. ( cPaisLoc<>"BRA" .And. Subs( EF_NUM,1,1)="*")
		dbSkip()
		Loop
	Endif

	//����������������������Ŀ
	//�Validacao da carteira.�
	//������������������������
	If !Empty(EF_CART) .AND. ((Mv_Par13 <> 3 ) .AND. (EF_CART <> cCarteira))
		DbSkip()
		Loop
	EndIf
	
	If (mv_par13 == 2 .and. SEF->EF_CART = 'R') .or. (mv_par13 == 1 .and. SEF->EF_CART <> 'R')
		DbSkip()
		Loop
	EndIf

	nTotVal := nTotCh := nFirst := 0
	cCarAnt := &cCond2

	While &cCond2 == cCarAnt .And. !Eof() //.and. cFilial == EF_FILIAL

		If lEnd
			@Prow()+1,001 Psay OemToAnsi(STR0010)  //"Cancelado pelo operador"
			lContinua := .F.
			Exit
		Endif
       
		cCheque := SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)
		If ASCAN(ACHEQUES,{ |X|  X[1] == cCheque}) <= 0		
			IncRegua()
	     	//��������������������������������������������������������������Ŀ
			//� Considera filtro do usuario                                  �
			//����������������������������������������������������������������
			If !Empty(cFilterUser).and.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
	
	
			If Empty( EF_NUM ) .Or. ( cPaisLoc<>"BRA" .And. Subs( EF_NUM,1,1)="*")
				dbSkip( )
				Loop
			Endif
	
			//����������������������Ŀ
			//�Validacao da carteira.�
			//������������������������
			If !Empty(EF_CART) .And. ((Mv_Par13 <> 3 ) .AND. (EF_CART <> cCarteira))
				DbSkip()
				Loop
			EndIf 
			
			If (mv_par13 == 2 .and. SEF->EF_CART = 'R') .or. (mv_par13 == 1 .and. SEF->EF_CART <> 'R')
				DbSkip()
				Loop
			EndIf	
	
			If EF_IMPRESS $ "AC"	//Integrante de outro Cheque ou cancelado
				dbSkip( )
				Loop
			Endif
	        
			If lLibCheq .And. Mv_Par13 <> 1
				IF Mv_Par14 == 1 .AND. EF_LIBER != 'S'
					dbSkip( )
					Loop
				ElseIf Mv_Par14 == 2 .AND. !(EF_LIBER $ 'N ')
					dbSkip( )
					Loop
				EndIf
			EndIf
	        
	             
			// Desconsidera cheques com moeda diferente se escolhido nao imprimir
			If SEF->EF_CART == "P"  //Carteira Pagar - Cheques Emitidos
				SA6->(dbSeek(cFilialA6+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA))
				If mv_par12 == 2 .AND. !Empty(SA6->A6_MOEDA) .And. SA6->A6_MOEDA != mv_par11 
				   dbSkip()
				   Loop
				EndIf
			Endif
					
			If li > 58
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				nFirst:=0
			Endif
	
			If nFirst = 0

				dbSelectArea( "SA6" )
				dbSeek(cFilialA6+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA)

				If SEF->EF_CART <> "R"   //Carteira Pagar - Cheques Emitidos
					@li, 0 Psay OemToAnsi(STR0011) +A6_COD+" - "+AllTrim(A6_NOME)+OemToAnsi(STR0012)+A6_AGENCIA+ STR0033 +SA6->A6_NUMCON  //"Banco : "###" -  Agencia : "
				Else 					//Carteira receber - Cheques Recebidos	
					@li, 0 Psay OemToAnsi(STR0011) +SEF->EF_BANCO+" - "+ SA6->A6_NOME + " - " +OemToAnsi(STR0012)+SEF->EF_AGENCIA+ STR0033 +SEF->EF_CONTA  //"Banco : "###" -  Agencia : "
				Endif
				li += 2
				nFirst++
			Endif  
			
			dbSelectArea( "SEF" )
			@li ,   0 Psay SEF->EF_NUM 
			
			If cPaisLoc <> "BRA"
				nValorEF := xMoeda(SEF->EF_VALOR, SA6->A6_MOEDA, mv_par11,SEF->EF_DATA,nDecs+1)
				@li ,  16 Psay nValorEF           Picture TM(SEF->EF_VALOR,14,nDecs)
				@li ,  32 Psay SEF->EF_DATA
				@li ,  42 Psay SEF->EF_VENCTO
				
				//������������������������������������������������Ŀ
	 			//� Imprime o Beneficiario em funcao da Carteira   �
				//��������������������������������������������������
				If SEF->EF_CART == "R"   
					@ li,  51 Psay Substr(SEF->EF_EMITENT,1,40)   // "Emitente"
				ElseIf SEF->EF_CART <> "R"   
					@li ,  51 Psay Substr(SEF->EF_BENEF,1,40)     // "Beneficiario"
				EndIf
				
				@li ,  95 Psay Substr(SEF->EF_HIST,1,31)		
				nTotVal += nValorEF
			Else
				@li ,  16 Psay SEF->EF_VALOR     Picture TM(SEF->EF_VALOR,14)
				@li ,  32 Psay SEF->EF_DATA
	
				//������������������������������������������������Ŀ
	 			//� Imprime o Beneficiario em funcao da Carteira   �
				//��������������������������������������������������
				If SEF->EF_CART == "R"   
					@ li,  42 Psay SEF->EF_VENCTO    // "Vencimento"  				
					@ li,  52 Psay SEF->EF_CLIENTE   // "Cliente"  								
					@ li,  59 Psay Substr(SEF->EF_EMITENT,1,35)   // "Emitente"  
				ElseIf SEF->EF_CART $ "P "   
					If mv_par13 <> 3 //Ambos
						@li ,  44 Psay SEF->EF_BENEF     // "Beneficiario"
					Else
						@li ,  59 Psay Substr(SEF->EF_BENEF,1,35)     // "Beneficiario"
					EndIf
				EndIf  
				
				If mv_par13 <> 3 .and. mv_par13 <> 1 //Ambos ou Receber
					@li ,  86 Psay Substr(SEF->EF_HIST,1,40)
				Else
					@li ,  96 Psay Substr(SEF->EF_HIST,1,32)
				EndIf
				nTotVal += SEF->EF_VALOR
			EndIf                                    
			
			If SEF->EF_CART <> 'R' 
				@li , 129 Psay If(SEF->EF_LIBER $ 'N ', "B","L")
			EndIf 
			
			aAdd(aCheques,{cCheque})
			nTotCh++
			li++
		Endif
			
		dbSkip()
		
	Enddo
	 
	If nTotVal > 0
		SubTot400(nTotVal,limite)
	EndIf
	
	nTotChg  += nTotCh
	nTotValg += nTotVal
EndDo

If nTotValg > 0
	TotGer400(nTotChg,nTotValg)
EndIf

If li != 80
	roda(cbcont,cbtxt,"M")
EndIf

Set Device To Screen
dbSelectArea("SEF")

#IFDEF TOP
	If TcSrvType() != "AS/400"
		dbCloseArea()
		ChkFile("SEF")
		dbSelectArea("SEF")
	EndIf
#ENDIF    

dbSetOrder(1)
Set Filter To

If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
EndIf
MS_FLUSH()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SubTot400 � Autor � Paulo Boschetti       � Data � 01.06.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do SubTotal do Banco                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � SubTot400(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1  - Valor Total                                       ���
���          � ExpN2  - Tamanho da linha                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function SubTot400(nTotVal,limite)
li++
@li, 0 Psay OemToAnsi(STR0013)  //"Sub-Total ----> "
@li,16 Psay nTotVal            Picture TM(nTotVaL,14,nDecs)
li++
@ li,00 Psay __PrtThinLine()
li++
Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TotGer400� Autor � Paulo Boschetti       � Data � 01.06.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Total Do Relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � TotGer400(ExpN1,ExpN2)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Total de cheques,Valor Total                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TotGer400(nTotChg,nTotValg)
li++
@li  ,  0 Psay OemToAnsi(STR0014)  //"Total Geral--> "
@li  , 16 Psay nTotValg              Picture tm(nTotValg,14,nDecs)
li++
@li  ,  0 Psay OemToAnsi(STR0015)+Alltrim(str(nTotChg))  //"Total Cheques-> "
li++                                                            
If mv_par13 <> 1 
	li++                   
	@li  ,  2 Psay OemToAnsi(STR0020)  //"Total Cheques-> " //"Legenda: "
	li++                   
	@li  ,  2 Psay OemToAnsi(STR0021)  //"Total Cheques-> " //"St.Ch - Status do Cheque"
	li++                    
	@li  ,  2 Psay OemToAnsi(STR0022)  //"Total Cheques-> " //"B - Bloqueado "
	li++                    
	@li  ,  2 Psay OemToAnsi(STR0023)  //"Total Cheques-> " //"L - Liberado "
	li++                    
EndIf

Return .T.
