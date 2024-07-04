#include 'protheus.ch'

/*/{Protheus.doc} CTBA800A
Funcao de integracao para envio e recebimento do
cadastro de conta gerencial utilizando o conceito de mensagem unica.
A conta gerencial � um entidade cont�bil que no protheus ser� representado por uma entidade adicional, informada
pelo usu�rio no par�metro MV_CTBCGER

@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015
/*/
Function CTBA800A()
Return FwIntegDef('CTBA800A',,,, 'CTBA800A')


/*/{Protheus.doc} IntegDef
Fun��o para a intera��o com EAI

@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015
/*/
STATIC FUNCTION IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return CTBI800A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
