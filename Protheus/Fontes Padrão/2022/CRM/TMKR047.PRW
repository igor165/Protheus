#INCLUDE "REPORT.CH"
#INCLUDE "TMKR047.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TMKR047     � Autor �Vendas CRM          � Data �  13/04/10   ���
���������������������������������������������������������������������������͹��
���Descricao �Relatorio de historico de INATIVIDADE do operador             ���
/���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function TMKR047()
	Local oReport	:= Nil				// Objeto Report
	Local aArea 	:= GetArea()		// Salva a area 
	Local aPDFields	:= {}

	// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	aPDFields := {"U7_NOME"}
	FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
	
	//������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros    �
	//� Mv_Par01           // Data Inicial ?	�
	//� Mv_Par02           // Data Final ?		�
	//� Mv_Par03           // Do Operador ?     �
	//� Mv_Par04           // At� Operador ?  	�
	//�������������������������������������������
	Pergunte("TMKR047", .F.)

	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������                       
	oReport := ReportDef()
	oReport:PrintDialog()

	//Finaliza o gerenciamento dos campos com prote��o de dados.
	FATPDUnLoad()     
	
	RestArea( aArea ) 

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �ReportDef     � Autor �Vendas CRM          � Data �  13/04/10 ���
���������������������������������������������������������������������������͹��
���Descricao �Relatorio de historico de INATIVIDADE do operador             ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ReportDef()

	Local cPerg		:= "TMKR047"
	Local oReport	:= Nil
	Local oInativ	:= Nil 
	Local oBreak	:= Nil
	Local nTamNome	:= TamSX3("U7_NOME")[1]
	Local nTamMotivo:= TamSX3("AGE_DESC")[1]

	//Relatorio
	DEFINE REPORT oReport NAME "TMKR047" TITLE STR0002 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport, cPerg)} //"Relatorio de Inatividade de Operadores"

	//Sessao
	DEFINE SECTION oInativ OF oReport TITLE STR0003 TABLES "AGF" BREAK HEADER //"Operadores inativos"

	//Celulas
	DEFINE CELL NAME "AGF_OPERAD"	OF oInativ ALIAS "AGF"
	DEFINE CELL NAME "NOME" OF oInativ TITLE STR0004 SIZE nTamNome  //"Nome"
		oReport:aSection[1]:aCell[2]:bCellBlock   := {|| FATPDObfuscate(Posicione("SU7",1,xFilial("SU7")+AGF_OPERAD,"SU7->U7_NOME"),"U7_NOME") }
		oReport:aSection[1]:aCell[2]:cType        := "C"
		oReport:aSection[1]:aCell[2]:cPicture     := PesqPict("SU7", "U7_NOME")   
		oReport:aSection[1]:aCell[2]:nHeaderAlign := 1
	DEFINE CELL NAME "AGF_DTINI"	OF oInativ ALIAS "AGF"
	DEFINE CELL NAME "AGF_HRINI"	OF oInativ ALIAS "AGF"
	DEFINE CELL NAME "AGF_DTFIM"	OF oInativ ALIAS "AGF"
	DEFINE CELL NAME "AGF_HRFIM"	OF oInativ ALIAS "AGF"
	DEFINE CELL NAME "MOTIVO" OF oInativ TITLE STR0005 SIZE nTamMotivo //"Motivo"
		oReport:aSection[1]:aCell[7]:bCellBlock   := {|| Posicione("AGE",1,xFilial("AGE")+AGF_CODIGO,"AGE->AGE_DESC") }
		oReport:aSection[1]:aCell[7]:cType        := "C"
		oReport:aSection[1]:aCell[7]:cPicture     := PesqPict("AGE", "AGE_DESC")
		oReport:aSection[1]:aCell[7]:nHeaderAlign := 1

	//Quebra
	DEFINE BREAK oBreak OF oInativ WHEN oInativ:Cell("AGF_OPERAD")    

	//Totalizador
	DEFINE FUNCTION FROM oInativ:Cell("AGF_OPERAD") OF oInativ FUNCTION COUNT TITLE STR0010 NO END SECTION BREAK oBreak //"Per�odos de aus�ncia"

Return( oReport ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrintReport�Autor  �Vendas CRM         � Data �  05/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Selecao dos itens a serem impressos                         ���
�������������������������������������������������������������������������͹��
���Uso       �TMKR047                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport(oReport, cPerg)
	Local cAlias := GetNextAlias()
	Local cSQL := ""

	MakeSqlExp(cPerg)

	If !Empty(MV_PAR01)
		cSQL += "AND AGF_DTINI >= '" + DtoS(MV_PAR01) + "' "
	EndIf

	If !Empty(MV_PAR02)
		cSQL += "AND AGF_DTFIM <= '" + DtoS(MV_PAR02) + "' "
	EndIf

	If !Empty(MV_PAR03)
		cSQL += "AND AGF_OPERAD >= '" + MV_PAR03 + "' "
	EndIf

	If !Empty(MV_PAR04)
		cSQL += "AND AGF_OPERAD <= '" + MV_PAR04 + "' "
	EndIf

	cSQL := "%"+cSQL+"%"

	BEGIN REPORT QUERY oReport:Section(1)
		BeginSql Alias cAlias
			SELECT AGF_OPERAD,AGF_CODIGO,AGF_DTINI,AGF_HRINI,AGF_DTFIM,AGF_HRFIM
			FROM %Table:AGF% AGF
			WHERE AGF_FILIAL = %xFilial:AGF% AND AGF.%NotDel% %Exp:cSQL%
			ORDER BY AGF_FILIAL, AGF_OPERAD
		EndSql
	END REPORT QUERY oReport:Section(1)

	oReport:Section(1):Print()

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote��o de dados.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive