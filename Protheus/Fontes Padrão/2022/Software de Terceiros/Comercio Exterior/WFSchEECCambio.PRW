/*
Funcao      : WFSchEECCambio
Parametros  : Nil
Retorno     : Envio de Workflow
Objetivos   : Função responsavel pela chamada de workflow de Cambio via Schedule
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 26/09/2012 :: 18:39
*/
*-----------------------------*
Function WFSchEECCambio(aParams) 
*-----------------------------*
Return EASYGROUPWF('CAMBIO_SCH_EEC',,.T.,aParams[1],aParams[2],.T.) 