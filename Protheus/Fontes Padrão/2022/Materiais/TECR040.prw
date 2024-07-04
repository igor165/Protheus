#Include "Rwmake.ch"
#Include "Protheus.ch"      
#Include "TOPCONN.ch" 
#Include "TECR040.ch"
Static cAutoPerg := "TECR040"
//-------------------------------------------------------------------
/*/{Protheus.doc} TECR040
Relat�rio para imprimir a rela��o de funcion�rios cadastrados na tabela SRA que
n�o estejam cadastrados como Atendentes do Gest�o de Servi�os na tabela AA1.

@author filipe.goncalves
@since 21/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function TECR040()

Local oReport
Private cPerg	:= "TECR040"
 	
//������������������������������������������������������������������Ŀ
//� PARAMETROS                                                       �
//� MV_PAR01 : Funcion�rio de ?                                      �
//� MV_PAR02 : Funcion�rio ate?                                      �
//� MV_PAR03 : Fun��o de ?                                           �
//� MV_PAR04 : Fun��o ate ?                                          �
//� MV_PAR05 : Centro de Custo de ?                                  �
//� MV_PAR06 : Centro de Custo ate ?                                 �
//�������������������������������������������������������������������� 
If !Pergunte(cPerg,.T.)
	Return
EndIf 
	
oReport := ReportDef()
oReport:PrintDialog()
Return
                
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Monta as defini��es do relatorio de Atendentes nao cadastrados

@author filipe.goncalves
@since 21/01/2016
@version P12.1.11
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef()

Local cTitulo 	:= STR0001	//"Atendentes n�o cadastrados"
Local oReport 
Local oSection1

If TYPE("cPerg") == "U"
	cPerg	:= "TECR040"
EndIf

oReport 	:= TReport():New(cPerg, cTitulo, cPerg , {|oReport| PrintReport(oReport)},STR0002)	//"Relat�rio de atendentes n�o cadastrados"
oSection1	:= TRSection():New(oReport,STR0019,{"SRA","CTT"})	//"Funcion�rios"

oReport:ShowHeader()
oReport:SetPortrait()
oReport:SetTotalInLine(.F.)
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1, STR0009, "SRA", STR0013, PesqPict('SRA',"RA_MAT"),     TamSX3("RA_MAT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)		//"CODAT"  # "Cod. Func"
TRCell():New(oSection1, STR0010, "SRA", STR0014, PesqPict('SRA',"RA_NOME"),    TamSX3("RA_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/)		//"ATEND"  # "Funcion�rio"	 
TRCell():New(oSection1, STR0011, "CTT", STR0015, PesqPict('CTT',"CTT_CUSTO"),  TamSX3("CTT_CUSTO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)	//"CODCC"  # "Centro Custo"
TRCell():New(oSection1, STR0012, "CTT", STR0016, PesqPict('CTT',"CTT_DESC01"), TamSX3("CTT_DESC01")[1],/*lPixel*/,/*{|| code-block de impressao }*/)	//"NOMECC" # "Descri��o" 

oSection1:Cell(STR0009):SetAlign("LEFT")	//"CODAT"
oSection1:Cell(STR0010):SetAlign("LEFT")	//"ATEND"
oSection1:Cell(STR0011):SetAlign("LEFT")	//"CODCC"
oSection1:Cell(STR0012):SetAlign("LEFT")	//"NOMECC"

Return (oReport)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Emite o relat�rio de Atendentes n�o cadastrados

@author filipe.goncalves
@since 21/01/2016
@version P12.1.11
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)

#IFDEF TOP
	Local aArea		:= GetArea()
	Local oSection1	:= oReport:Section(1)
	Local cCCCod		:= ""
	Local cCCNome		:= ""
	Local cSql			:= ""

	MakeSqlExp("TECR040")

	cSql += "AND RA_MAT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cSql += "AND RA_CODFUNC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cSql += "AND RA_CC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
	cSql := "%"+cSql+"%"

	//Consulta funcionarios ativos na SRA que nao estejam presentes na AA1
	BEGIN REPORT QUERY oReport:Section(1)

		BeginSql alias "QRY"

           SELECT RA_MAT, RA_NOME, RA_CC
             FROM %table:SRA% SRA
            WHERE RA_FILIAL = %xfilial:SRA%
              AND RA_SITFOLH <> 'D'
              AND RA_MAT NOT IN (SELECT AA1_CDFUNC FROM %table:AA1% AA1  WHERE AA1.D_E_L_E_T_ = ' ')
              AND SRA.%notDel%
              %exp:cSql%
            ORDER BY RA_NOME

		EndSql

	END REPORT QUERY oReport:Section(1)

	QRY->(dbGoTop())

	//Define tamanho da regua de processamento
	oReport:SetMeter(QRY->(RecCount()))

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	dbSelectArea('QRY')
	dbSelectArea('CTT')
	CTT->(dbSetOrder(1))

	//Para cada funcionario nao cadastrado, printa uma linha no relatorio
	While QRY->(!Eof())

		If CTT->(dbSeek(xFilial('CTT')+QRY->RA_CC))
			cCCCod 	:= CTT->CTT_CUSTO
			cCCNome	:= CTT->CTT_DESC01
		Else
			cCCCod 	:= STR0017 //"XXXXXX"
			cCCNome	:= STR0018 //"DESCONHECIDO"
		EndIf

		oSection1:Cell(STR0009):SetValue(QRY->RA_MAT)		//"CODAT"
		oSection1:Cell(STR0010):SetValue(QRY->RA_NOME)	//"ATEND"
		oSection1:Cell(STR0011):SetValue(cCCCod)			//"CODCC"
		oSection1:Cell(STR0012):SetValue(cCCNome)			//"NOMECC"
		If !isBlind()
			oSection1:PrintLine()
		EndIf
		//Botao Cancelar
		If oReport:Cancel()
			Exit
		EndIf

		//Incrementa regua de processamento
		oReport:IncMeter()

		//Proximo registro
		QRY->(dbSkip())
	EndDo

	QRY->(dbCloseArea())
	oSection1:Finish()
	RestArea(aArea)
#ENDIF
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relat�rio
Fun��o utilizada na automa��o
@author Mateus Boiani
@since 31/10/2018
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg