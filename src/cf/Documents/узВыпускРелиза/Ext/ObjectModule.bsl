﻿
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	ОчиститьСвязанныеТЧ();
	СформироватьСписокЗадач();
	
	ТЗСобытия = ПолучитьТЗСобытия(РежимЗаписи);
	ДополнительныеСвойства.Вставить("ТЗСобытия",ТЗСобытия);
	
КонецПроцедуры

Процедура СформироватьСписокЗадач() Экспорт
	пСписокЗадач = "";
	Для каждого СтрокаТЧЗадачи из ТЧЗадачи цикл
		пСписокЗадач = пСписокЗадач + "#"+Формат(СтрокаТЧЗадачи.Задача.Код,"ЧГ=0") + ", ";		
	Конеццикла;
	пСписокЗадач = Лев(пСписокЗадач, СтрДлина(пСписокЗадач) - 2);
	СписокЗадач = пСписокЗадач;
КонецПроцедуры 

Процедура ОчиститьСвязанныеТЧ() Экспорт
	
	МассивЗадач = ТЧЗадачи.ВыгрузитьКолонку("Задача");
	
	МассивОбрабатываемыхТЧ = Новый Массив();
	МассивОбрабатываемыхТЧ.Добавить("ИсторияХранилища");
	МассивОбрабатываемыхТЧ.Добавить("ИзмененныеОбъекты");
	
	Для каждого ИмяТЧ из МассивОбрабатываемыхТЧ цикл
		СтрокиКУдалению = Новый Массив();
		
		Для каждого СтрокаТЧ из ЭтотОбъект[ИмяТЧ] цикл
			пЗадача = СтрокаТЧ.Задача;
			Если МассивЗадач.Найти(пЗадача) = Неопределено Тогда
				СтрокиКУдалению.Добавить(СтрокаТЧ);
			Конецесли;
		Конеццикла;	
		
		Для каждого СтрокаКУдалению из СтрокиКУдалению цикл
			ЭтотОбъект[ИмяТЧ].Удалить(СтрокаКУдалению);		
		Конеццикла;
	Конеццикла;
КонецПроцедуры 

Функция ПолучитьТЗСобытия(РежимЗаписи)
	ТЗСобытия = Новый ТаблицаЗначений();
	ТЗСобытия.Колонки.Добавить("ВидСобытия",Новый ОписаниеТипов("ПеречислениеСсылка.узВидыСобытий"));
	
	Если ЭтоНовый() Тогда
		СтрокаТЗСобытия = ТЗСобытия.Добавить();
		СтрокаТЗСобытия.ВидСобытия = ПредопределенноеЗначение("Перечисление.узВидыСобытий.СозданДокументВыпускРелиза");
		Возврат ТЗСобытия;
	Конецесли;
	
	Если НЕ Ссылка.Проведен
		И РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		СтрокаТЗСобытия = ТЗСобытия.Добавить();
		СтрокаТЗСобытия.ВидСобытия = ПредопределенноеЗначение("Перечисление.узВидыСобытий.ПроведенДокументВыпускРелиза");
	Конецесли;
	
	Возврат ТЗСобытия;
КонецФункции

Процедура ПриЗаписи(Отказ)
	Если ДополнительныеСвойства.Свойство("узЭтоОбработка") Тогда
		Возврат;
	Конецесли;
	
	РегистрацияАктивностиПользователя(ДополнительныеСвойства.ТЗСобытия,Отказ);
	
	ДополнительныеСвойства.Удалить("ТЗСобытия");
КонецПроцедуры

Процедура РегистрацияАктивностиПользователя(ТЗСобытия,Отказ)
	ВТДопПараметры = Новый Структура();
	ВТДопПараметры.Вставить("ТЗСобытия",ТЗСобытия);
	РегистрыСведений.узАктивностиПользователей.ДобавитьАктивностьПользователя(ЭтотОбъект,ВТДопПараметры,Отказ);
КонецПроцедуры 
