#INCLUDE 'TECA190A.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
 
#DEFINE FIL_CLIENTE 1
#DEFINE FIL_LOCAL   2
#DEFINE FIL_REGIAO  3
#DEFINE FIL_CONTRAT 4
#DEFINE FIL_SUPERV  5
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190A
	Rotina para mesa operacional - chama a rotina que constr�i com mensagem para o usu�rio
aguardar 

@sample 	TECA190A

@since		29/04/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function TECA190A()
		 teca190d()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190ALegen
	Monta janela de exibi��o das legendas conforme a refer�ncia informada

@sample		AT190ALegen(cConsulta)
	
@since		24/04/2014 
@version 	P12

@param		cConsulta, Caracter, identifica��o da legenda a ser apresentada
     
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT190ALegen(cConsulta)

Local oLegenda  :=  FWLegend():New()

If cConsulta=='AGENDA1'
	oLegenda:Add( '', 'BR_VERDE'	, STR0028 )  // 'Agenda Ativa'
	oLegenda:Add( '', 'BR_AMARELO'	, STR0029 )  // 'Agenda Alterada'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0030 )  // 'Agenda Cancelada'
	oLegenda:Add( '', 'BR_PRETO'	, STR0031 )  // 'Agenda Atendida'

ElseIf cConsulta=='AGENDA2'
	oLegenda:Add( '', 'BR_VERDE'	, STR0032 )  // 'Efetivo'
	oLegenda:Add( '', 'BR_AMARELO'	, STR0033 )  // 'Cobertura'
	oLegenda:Add( '', 'BR_LARANJA'	, STR0034 )  // 'Apoio'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0035 )  // 'Excedente'
	oLegenda:Add( '', 'BR_AZUL'		, STR0036 )  // 'Treinamento'
	oLegenda:Add( '', 'BR_PRETO'	, STR0037 )  // 'Curso'
	oLegenda:Add( '', 'BR_BRANCO'	, STR0038 )  // 'Cortesia'
	oLegenda:Add( '', 'BR_PINK'		, STR0039 )  // 'Outros Tipos'

ElseIf cConsulta=='ITRH'
	oLegenda:Add( '', 'BR_AZUL' 	, STR0040 )  // 'Item n�o iniciado'
	oLegenda:Add( '', 'BR_PRETO'	, STR0041 )  // 'Item encerrado'
	oLegenda:Add( '', 'BR_VERDE'	, STR0042 )  // 'Opera��o: Atendido'
	oLegenda:Add( '', 'BR_AMARELO'	, STR0043 )  // 'Opera��o: Parcialmente Atendido'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0044 )  // 'Opera��o: N�o Atendido'
 
ElseIf cConsulta=='ITMI'
	oLegenda:Add( '', 'BR_AZUL' 	, STR0040 )  // 'Item n�o iniciado'
	oLegenda:Add( '', 'BR_PRETO'	, STR0041 )  // 'Item encerrado'
	oLegenda:Add( '', 'BR_VERDE'	, STR0042 )  // 'Opera��o: Atendido'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0044 )  // 'Opera��o: N�o Atendido'

ElseIf cConsulta=='ITMC'
	oLegenda:Add( '', 'BR_AZUL' 	, STR0040 )  // 'Item n�o iniciado'
	oLegenda:Add( '', 'BR_PRETO'	, STR0041 )  // 'Item encerrado'
	oLegenda:Add( '', 'BR_VERDE'	, STR0042 )  // 'Opera��o: Atendido'
	oLegenda:Add( '', 'BR_AMARELO'	, STR0043 )  // 'Opera��o: Parcialmente Atendido'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0044 )  // 'Opera��o: N�o Atendido'

ElseIf cConsulta=='LOCGER'
	oLegenda:Add( '', 'BR_AZUL' 	, STR0045 )  // 'Vig�ncia n�o iniciada'
	oLegenda:Add( '', 'BR_VERDE'	, STR0046 )  // 'Em opera��o'
	oLegenda:Add( '', 'BR_PRETO'	, STR0047 )  // 'Vig�ncia encerrada'

ElseIf cConsulta=='LOCRH'
	oLegenda:Add( '', 'BR_BRANCO'	, STR0048 )  // 'N�o existe Recurso Humano'
	oLegenda:Add( '', 'BR_AZUL' 	, STR0040 )  // 'Item n�o iniciado'
	oLegenda:Add( '', 'BR_PRETO'	, STR0041 )  // 'Item encerrado'
	oLegenda:Add( '', 'BR_VERDE'	, STR0042 )  // 'Opera��o: Atendido'
	oLegenda:Add( '', 'BR_AMARELO'	, STR0043 )  // 'Opera��o: Parcialmente Atendido'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0044 )  // 'Opera��o: N�o Atendido'

ElseIf cConsulta=='LOCMI'
	oLegenda:Add( '', 'BR_BRANCO'	, STR0049 )  // 'N�o existe Material de Implanta��o'
	oLegenda:Add( '', 'BR_AZUL' 	, STR0040 )  // 'Item n�o iniciado'
	oLegenda:Add( '', 'BR_PRETO'	, STR0041 )  // 'Item encerrado'
	oLegenda:Add( '', 'BR_VERDE'	, STR0042 )  // 'Opera��o: Atendido'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0044 )  // 'Opera��o: N�o Atendido'


ElseIf cConsulta=='LOCMC'
	oLegenda:Add( '', 'BR_BRANCO'	, STR0050 )  // 'N�o existe Material de Consumo'
	oLegenda:Add( '', 'BR_AZUL' 	, STR0040 )  // 'Item n�o iniciado'
	oLegenda:Add( '', 'BR_PRETO'	, STR0041 )  // 'Item encerrado'
	oLegenda:Add( '', 'BR_VERDE'	, STR0042 )  // 'Opera��o: Atendido'
	oLegenda:Add( '', 'BR_AMARELO'	, STR0043 )  // 'Opera��o: Parcialmente Atendido'
	oLegenda:Add( '', 'BR_VERMELHO'	, STR0044 )  // 'Opera��o: N�o Atendido'

EndIf

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190ASAg2
	Identifica o status para a ABB considerando o tipo de aloca��o

@sample		At190ASAg2( cTab )
	
@since		24/04/2014 
@version 	P12

@param		cTab, Caracter, tabela de dados a ter o conte�do dos campos avaliados
@return		cStatus, Caracter, c�digo da cor a ser atribu�do no campo de status

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190ASAg2( cTab )

Local cStatus   := 'BR_PINK' 
Local cConteudo := (cTab)->ABB_TIPOMV

If cConteudo = '001'
	cStatus := 'BR_VERDE'    // Efetivo 
ElseIf cConteudo = '002'
	cStatus := 'BR_AMARELO'  // Cobertura
ElseIf cConteudo = '003'
	cStatus := 'BR_LARANJA'  // Apoio
ElseIf cConteudo = '004'
	cStatus := 'BR_VERMELHO' // Excedente 
ElseIf cConteudo = '005'
	cStatus := 'BR_AZUL'     // Treinamento
ElseIf cConteudo = '006'
	cStatus := 'BR_PRETO'    // Curso
ElseIf cConteudo = '007'
	cStatus := 'BR_WHITE'    // Cortesia
EndIf

Return cStatus
