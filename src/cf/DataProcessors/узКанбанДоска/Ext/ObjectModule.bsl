﻿#Область ПрограммныйИнтерфейс

Процедура ЗаполнитьЗадачи() Экспорт
	пНастройкиКомпоновщика = ПолучитьИзВременногоХранилища(АдресВременногоХранилища);	
	
	ТЗЗадачи = ПолучитьТЗЗадачи(пНастройкиКомпоновщика);
	ЕстьКолонкаЧекЛистВыполнено = ТЗЗадачи.Колонки.Найти("ЧекЛистВыполнено") <> Неопределено;
	ТЗЗадачи.Колонки.Добавить("ЧекЛистВыполнение",Новый ОписаниеТипов("Строка"));
	//+ #108 Дзеса Ігор (capitoshko) 05.10.2018
	ТЗЗадачи.Колонки.Добавить("ЧекЛистВыполнениеПроцент",Новый ОписаниеТипов("Строка"));
	ЕстьКолонкаЧекЛистВыполненоПроцент = ТЗЗадачи.Колонки.Найти("ЧекЛистВыполнениеПроцент") <> Неопределено;
	//- #108 Дзеса Ігор (capitoshko) 05.10.2018 
	
	Для каждого СтрокаТЗЗадачи из ТЗЗадачи цикл
		СтрокаТЗЗадачи.ОсновнаяЗадачаПредставление = СокрЛП(СтрокаТЗЗадачи.ОсновнаяЗадачаПредставление);		
		Если ЕстьКолонкаЧекЛистВыполнено
			И ЗначениеЗаполнено(СтрокаТЗЗадачи.ЧекЛистВыполнено)
			И ЗначениеЗаполнено(СтрокаТЗЗадачи.ЧекЛистВсего) Тогда
			СтрокаТЗЗадачи.ЧекЛистВыполнение = "" + СтрокаТЗЗадачи.ЧекЛистВыполнено 
			+ "/" + СтрокаТЗЗадачи.ЧекЛистВсего;
		Конецесли;
		//+ #108 Дзеса Ігор (capitoshko) 05.10.2018
		Если ЕстьКолонкаЧекЛистВыполненоПроцент
			И ЗначениеЗаполнено(СтрокаТЗЗадачи.ЧекЛистВыполнено)
			И ЗначениеЗаполнено(СтрокаТЗЗадачи.ЧекЛистВсего) Тогда
			//+ #181 Хадиятов Алексей (xan333) 09.07.2019
			//ЧекЛистВыполнениеПроцент = СтрокаТЗЗадачи.ЧекЛистВыполнено/СтрокаТЗЗадачи.ЧекЛистВсего * 100;
			ЧекЛистВыполнениеПроцент = Окр(СтрокаТЗЗадачи.ЧекЛистВыполнено/СтрокаТЗЗадачи.ЧекЛистВсего * 100,1);
			//- #181 Хадиятов Алексей (xan333) 09.07.2019
			СтрокаТЗЗадачи.ЧекЛистВыполнениеПроцент = Формат(ЧекЛистВыполнениеПроцент, "ЧГ=0") + " %";
		Конецесли;
		//- #108 Дзеса Ігор (capitoshko) 05.10.2018 
	Конеццикла;
	ТЧЗадачи.Загрузить(ТЗЗадачи);
КонецПроцедуры 

Функция ПолучитьТЗЗадачи(НастройкиКомпоновщика) Экспорт 
	ТЗЗадачи = Новый ТаблицаЗначений;
	СхемаКомпоновкиДанныхКонсоли = ПолучитьМакет("СхемаКомпоновкиДанных");
	
	ИсполняемыеНастройки = НастройкиКомпоновщика;
	
	СписокВыбранныхСтатусов = Новый СписокЗначений;
	Для каждого СтрокаТЧНастройкиКолонок из ТЧНастройкиКолонок цикл
		Если НЕ СтрокаТЧНастройкиКолонок.Видимость Тогда
			Продолжить;
		Конецесли;
		СписокВыбранныхСтатусов.Добавить(СтрокаТЧНастройкиКолонок.Статус);		
	Конеццикла;

	ЗначениеПараметра = ИсполняемыеНастройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Наблюдатель"));
	Если ЗначениеПараметра <> Неопределено Тогда
		ЗначениеПараметра.Использование = Истина;
		ЗначениеПараметра.Значение = Наблюдатель;
	Конецесли;	
	
	ЗначениеПараметра = ИсполняемыеНастройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ИспользоватьОтборПоНаблюдателю"));
	Если ЗначениеПараметра <> Неопределено Тогда
		ЗначениеПараметра.Значение = ЗначениеЗаполнено(Наблюдатель);
		ЗначениеПараметра.Использование=Истина;	
	Конецесли;
	
	ЗначениеПараметра = ИсполняемыеНастройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ТекущаяДата"));
	Если ЗначениеПараметра <> Неопределено Тогда
		ЗначениеПараметра.Значение = ТекущаяДата();
		ЗначениеПараметра.Использование=Истина;	
	Конецесли;
	
	
	МассивВыбранныхСтатусовКолонок = Новый Массив();
	Для каждого СтрокаТЧНастройкиКолонок из ТЧНастройкиКолонок цикл
		Если НЕ СтрокаТЧНастройкиКолонок.Видимость Тогда
			Продолжить;
		Конецесли;
		МассивВыбранныхСтатусовКолонок.Добавить(СтрокаТЧНастройкиКолонок.Статус);
	Конеццикла;
	
	ЗначениеПараметра = ИсполняемыеНастройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("МассивВыбранныхСтатусовКолонок"));
	Если ЗначениеПараметра <> Неопределено Тогда
		ЗначениеПараметра.Значение = МассивВыбранныхСтатусовКолонок;
		ЗначениеПараметра.Использование=Истина;	
	Конецесли;	
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанныхКонсоли, ИсполняемыеНастройки,,,Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных);
	ПроцессорВывода.УстановитьОбъект(ТЗЗадачи);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);	
	
	Возврат ТЗЗадачи;
КонецФункции 

Процедура СменитьСтатусЗадачи(ДопПараметры) Экспорт
	НовыйСтатус = ДопПараметры.НовыйСтатус;
	МассивЗадач = ДопПараметры.МассивЗадач;
	
	Для каждого ЭлМассиваЗадач из МассивЗадач цикл
		СпрОбъект = ЭлМассиваЗадач.ПолучитьОбъект();		
		СпрОбъект.Статус = НовыйСтатус;
		СпрОбъект.Записать();
	Конеццикла;	
	ЗаполнитьЗадачи();
КонецПроцедуры 

Процедура ЗаполнитьТЧНастройкиКолонок() Экспорт
	
	//+ #106 Дзеса Ігор (capitoshko)
	ТЧНастройкиКолонок.Очистить();
	//- #106 Дзеса Ігор (capitoshko) 
	
	пРодитель = ПредопределенноеЗначение("Справочник.узСтатусыЗадачи.ПустаяСсылка");
	ЗагрузитьПодчиненныеЭлементы(пРодитель);
	
КонецПроцедуры 

Процедура ЗагрузитьПодчиненныеЭлементы(пРодитель)
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	узСтатусыЗадачи.Ссылка КАК Статус,
	|	узСтатусыЗадачи.ВидимостьПоУмолчанию КАК Видимость,
	|	узСтатусыЗадачи.ИмяПредопределенныхДанных
	|ИЗ
	|	Справочник.узСтатусыЗадачи КАК узСтатусыЗадачи
	|ГДЕ
	|	узСтатусыЗадачи.НеИспользуется = ЛОЖЬ
	|	И узСтатусыЗадачи.Родитель = &Родитель
	|
	|УПОРЯДОЧИТЬ ПО
	|	узСтатусыЗадачи.РеквизитДопУпорядочивания";
	
	Запрос.УстановитьПараметр("Родитель",пРодитель);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	Конецесли;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		СтрокаТЧНастройкиКолонок = ТЧНастройкиКолонок.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТЧНастройкиКолонок,Выборка);
		
		ЗагрузитьПодчиненныеЭлементы(Выборка.Статус);
	Конеццикла;
	
	
КонецПроцедуры 

#КонецОбласти


